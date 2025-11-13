# Supabase Database Setup

## 1. Create Supabase Project
1. Go to [Supabase](https://supabase.com)
2. Create a new project
3. Copy your project URL and anon key
4. Update `lib/utils/supabase_config.dart` with your credentials

## 2. Database Schema

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  avatar_url TEXT,
  role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'reviewer', 'admin')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all users" ON users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

### Notesheets Table
```sql
CREATE TABLE notesheets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  pdf_url TEXT,
  pdf_path TEXT,
  status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'underReview', 'needsRevision', 'approved', 'rejected')),
  created_by_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reviewer_ids UUID[] DEFAULT '{}',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  submitted_at TIMESTAMP WITH TIME ZONE,
  reviewed_at TIMESTAMP WITH TIME ZONE
);

-- Enable RLS
ALTER TABLE notesheets ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own notesheets" ON notesheets
  FOR SELECT USING (created_by_id = auth.uid());

CREATE POLICY "Users can create notesheets" ON notesheets
  FOR INSERT WITH CHECK (created_by_id = auth.uid());

CREATE POLICY "Users can update own notesheets" ON notesheets
  FOR UPDATE USING (created_by_id = auth.uid());

CREATE POLICY "Users can delete own notesheets" ON notesheets
  FOR DELETE USING (created_by_id = auth.uid());

CREATE POLICY "Reviewers can view assigned notesheets" ON notesheets
  FOR SELECT USING (
    auth.uid() = ANY(reviewer_ids) OR
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('reviewer', 'admin')
    )
  );

CREATE POLICY "Reviewers can update assigned notesheets" ON notesheets
  FOR UPDATE USING (
    auth.uid() = ANY(reviewer_ids) OR
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('reviewer', 'admin')
    )
  );

CREATE POLICY "Admins can view all notesheets" ON notesheets
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

### Reviews Table
```sql
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  notesheet_id UUID NOT NULL REFERENCES notesheets(id) ON DELETE CASCADE,
  reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'needsRevision')),
  comments TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(notesheet_id, reviewer_id)
);

-- Enable RLS
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Reviewers can view own reviews" ON reviews
  FOR SELECT USING (reviewer_id = auth.uid());

CREATE POLICY "Reviewers can create reviews" ON reviews
  FOR INSERT WITH CHECK (reviewer_id = auth.uid());

CREATE POLICY "Reviewers can update own reviews" ON reviews
  FOR UPDATE USING (reviewer_id = auth.uid());

CREATE POLICY "Notesheet owners can view reviews" ON reviews
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM notesheets 
      WHERE id = notesheet_id AND created_by_id = auth.uid()
    )
  );

CREATE POLICY "Admins can view all reviews" ON reviews
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

## 3. Storage Setup

### Create Storage Bucket
```sql
-- Create documents bucket
INSERT INTO storage.buckets (id, name, public) VALUES ('documents', 'documents', true);

-- Storage policies
CREATE POLICY "Users can upload documents" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view documents" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'documents' AND (
      auth.uid()::text = (storage.foldername(name))[1] OR
      EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() AND role IN ('reviewer', 'admin')
      )
    )
  );

CREATE POLICY "Users can delete own documents" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
```

## 4. Functions and Triggers

### Update timestamp trigger
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notesheets_updated_at BEFORE UPDATE ON notesheets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Auth trigger for user profile
```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, first_name, last_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'first_name',
    NEW.raw_user_meta_data->>'last_name',
    COALESCE(NEW.raw_user_meta_data->>'role', 'user')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

## 5. Sample Data (Optional)

### Create sample admin user
```sql
-- First, sign up through your app or Supabase auth, then update the role
UPDATE users SET role = 'admin' WHERE email = 'admin@example.com';

-- Create sample reviewers
UPDATE users SET role = 'reviewer' WHERE email IN ('reviewer1@example.com', 'reviewer2@example.com');
```

## 6. Environment Setup

1. Update `lib/utils/supabase_config.dart` with your actual credentials:
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';
  
  // ... rest of the code
}
```

2. Run the SQL scripts in your Supabase SQL editor in the following order:
   - Users table and policies
   - Notesheets table and policies  
   - Reviews table and policies
   - Storage bucket and policies
   - Functions and triggers

3. Test the authentication and basic functionality

## 7. Security Considerations

- All tables use Row Level Security (RLS)
- Users can only access their own data unless they're reviewers/admins
- Reviewers can only access notesheets they're assigned to
- Admins have full access to all data
- File uploads are restricted to authenticated users
- All API calls go through Supabase's built-in authentication
