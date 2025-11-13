# notesheet_tracker

# Notesheet Tracker

A comprehensive Flutter application for managing and reviewing notesheets with PDF attachments, built with Supabase backend.

## Features

- **User Authentication**: Email/password authentication with role-based access
- **Notesheet Management**: Create, manage, and track notesheets with PDF attachments
- **Review Workflow**: Multi-reviewer approval system with status tracking
- **Admin Dashboard**: User management and system analytics
- **Dark Mode**: Toggle between light and dark themes
- **Responsive Design**: Works on mobile, tablet, and desktop

## Architecture

- **Frontend**: Flutter with Material Design 3
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **State Management**: Provider pattern
- **Authentication**: Supabase Auth with Row Level Security
- **File Storage**: Supabase Storage for PDF documents
- **Database**: PostgreSQL with proper indexing and constraints

## User Roles

- **User**: Can create and manage their own notesheets
- **Reviewer**: Can review assigned notesheets and provide feedback
- **Admin**: Full system access including user management

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Supabase account
- VS Code or Android Studio

### Installation

1. Clone the repository:
```bash
git clone https://github.com/LusmicSam/notesheet_tracker.git
cd notesheet_tracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up Supabase:
   - Create a new project at [Supabase](https://supabase.com)
   - Follow the [Database Setup Guide](DATABASE_SETUP.md)
   - Update `lib/utils/supabase_config.dart` with your credentials

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── models/          # Data models
│   ├── user.dart
│   ├── notesheet.dart
│   └── review.dart
├── services/        # API services
│   ├── auth_service.dart
│   ├── notesheet_service.dart
│   └── review_service.dart
├── providers/       # State management
│   ├── auth_provider.dart
│   ├── notesheet_provider.dart
│   └── theme_provider.dart
├── screens/         # UI screens
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── dashboard_screen.dart
│   ├── create_notesheet_screen.dart
│   └── profile_screen.dart
├── widgets/         # Reusable widgets
│   ├── notesheet_card.dart
│   └── stats_card.dart
├── utils/           # Utilities
│   └── supabase_config.dart
└── main.dart
```

## Configuration

### Supabase Configuration

Update `lib/utils/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // ... rest of the code
}
```

### Database Setup

Follow the detailed instructions in [DATABASE_SETUP.md](DATABASE_SETUP.md) to:
1. Create the required tables
2. Set up Row Level Security policies
3. Configure storage buckets
4. Create necessary functions and triggers

## Usage

### For Users
1. **Sign Up**: Create an account with email and password
2. **Create Notesheet**: Add title, description, and PDF attachment
3. **Select Reviewers**: Choose from available reviewers
4. **Track Status**: Monitor review progress and feedback

### For Reviewers
1. **Review Queue**: View assigned notesheets
2. **Provide Feedback**: Approve, reject, or request revisions
3. **Add Comments**: Provide detailed feedback

### For Admins
1. **User Management**: Manage user roles and permissions
2. **System Overview**: View all notesheets and reviews
3. **Analytics**: Monitor system usage and performance

## API Documentation

### Authentication
- `POST /auth/signup` - Create new user account
- `POST /auth/signin` - User login
- `POST /auth/signout` - User logout
- `POST /auth/reset-password` - Reset password

### Notesheets
- `GET /notesheets` - Get user's notesheets
- `POST /notesheets` - Create new notesheet
- `PUT /notesheets/:id` - Update notesheet
- `DELETE /notesheets/:id` - Delete notesheet
- `POST /notesheets/:id/submit` - Submit for review

### Reviews
- `GET /reviews` - Get reviews for user
- `POST /reviews` - Create review
- `PUT /reviews/:id` - Update review
- `DELETE /reviews/:id` - Delete review

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Security

- All database operations use Row Level Security (RLS)
- User authentication required for all operations
- File uploads restricted to authenticated users
- Role-based access control implemented
- SQL injection prevention through parameterized queries

## Performance Optimization

- Efficient database queries with proper indexing
- Image optimization for avatars
- Lazy loading for large lists
- Caching for frequently accessed data
- Pagination for large datasets

## Testing

Run tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test/
```

## Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Troubleshooting

### Common Issues

1. **Supabase Connection Error**
   - Check your URL and API key
   - Verify network connectivity
   - Ensure RLS policies are correctly set

2. **File Upload Issues**
   - Check storage bucket permissions
   - Verify file size limits
   - Ensure proper file types

3. **Authentication Problems**
   - Clear app data and try again
   - Check user roles and permissions
   - Verify email confirmation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@example.com or create an issue in the repository.

## Acknowledgments

- Flutter team for the amazing framework
- Supabase for the excellent backend service
- Material Design team for the design system
- Contributors and testers

---

Built with ❤️ using Flutter and Supabase

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
