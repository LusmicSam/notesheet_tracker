# Deployment Guide

## Prerequisites

Before deploying, ensure you have:
- Completed the database setup (see [DATABASE_SETUP.md](DATABASE_SETUP.md))
- Updated Supabase credentials in `lib/utils/supabase_config.dart`
- Tested the application locally

## Environment Setup

### 1. Update Supabase Configuration

Replace the placeholder values in `lib/utils/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
  
  // ... rest of the code
}
```

### 2. Database Configuration

Ensure your Supabase database is properly configured:
- All tables created with proper schemas
- Row Level Security policies implemented
- Storage bucket configured for documents
- Auth triggers set up for user management

## Platform-Specific Deployment

### Android Deployment

1. **Build APK for testing:**
```bash
flutter build apk --release
```

2. **Build App Bundle for Play Store:**
```bash
flutter build appbundle --release
```

3. **Configure app signing:**
   - Create a keystore file
   - Update `android/app/build.gradle`
   - Add signing configuration

4. **Update app information:**
   - Edit `android/app/src/main/AndroidManifest.xml`
   - Set proper app name, permissions, and metadata

### iOS Deployment

1. **Build for iOS:**
```bash
flutter build ios --release
```

2. **Configure signing:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Set up provisioning profiles
   - Configure team and bundle identifier

3. **Archive and upload:**
   - Use Xcode to archive and upload to App Store Connect

### Web Deployment

1. **Build for web:**
```bash
flutter build web --release
```

2. **Deploy to hosting service:**
   - **Netlify**: Drag and drop `build/web` folder
   - **Vercel**: Connect GitHub repository
   - **Firebase Hosting**: Use Firebase CLI
   - **GitHub Pages**: Use GitHub Actions

#### Example GitHub Actions for Web Deployment:

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.8.1'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Build web
      run: flutter build web --release --base-href="/notesheet_tracker/"
    
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build/web
```

### Desktop Deployment

#### Windows:
```bash
flutter build windows --release
```

#### macOS:
```bash
flutter build macos --release
```

#### Linux:
```bash
flutter build linux --release
```

## Production Checklist

### Security
- [ ] Remove all debug/test credentials
- [ ] Enable Row Level Security on all tables
- [ ] Implement proper API rate limiting
- [ ] Set up SSL certificates
- [ ] Configure CORS properly
- [ ] Review and test all user permissions

### Performance
- [ ] Optimize images and assets
- [ ] Enable caching where appropriate
- [ ] Test with large datasets
- [ ] Monitor database performance
- [ ] Set up proper indexing

### Monitoring
- [ ] Set up error tracking (Sentry, Bugsnag)
- [ ] Configure analytics (Google Analytics, Firebase)
- [ ] Monitor API usage and costs
- [ ] Set up uptime monitoring
- [ ] Configure backup strategies

### User Experience
- [ ] Test on different devices and screen sizes
- [ ] Verify offline functionality
- [ ] Test push notifications (if implemented)
- [ ] Ensure proper error handling
- [ ] Test accessibility features

## Environment Variables

For production deployment, consider using environment variables:

```dart
class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  
  // ... rest of the code
}
```

Build with environment variables:
```bash
flutter build web --release --dart-define=SUPABASE_URL=your-url --dart-define=SUPABASE_ANON_KEY=your-key
```

## CI/CD Pipeline

### GitHub Actions Example

Create `.github/workflows/ci.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.8.1'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test
    
    - name: Analyze code
      run: flutter analyze

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v2
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.8.1'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v2
      with:
        name: app-release.apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

## Monitoring and Maintenance

### Application Monitoring

1. **Set up Sentry for error tracking:**
```bash
flutter pub add sentry_flutter
```

2. **Implement analytics:**
```bash
flutter pub add firebase_analytics
```

3. **Monitor performance:**
```bash
flutter pub add firebase_performance
```

### Database Maintenance

1. **Regular backups:**
   - Set up automated backups in Supabase
   - Test backup restoration procedures

2. **Performance monitoring:**
   - Monitor query performance
   - Optimize slow queries
   - Review and update indexes

3. **Security audits:**
   - Regular security reviews
   - Update dependencies
   - Monitor for vulnerabilities

### Updates and Versioning

1. **Semantic versioning:**
   - Use semantic versioning for releases
   - Maintain a changelog
   - Tag releases in Git

2. **Update strategy:**
   - Regular dependency updates
   - Security patch management
   - Breaking change migration guides

## Troubleshooting Deployment Issues

### Common Problems:

1. **Build failures:**
   - Check Flutter version compatibility
   - Verify all dependencies are compatible
   - Clear build cache: `flutter clean`

2. **Authentication issues:**
   - Verify Supabase credentials
   - Check network connectivity
   - Ensure proper CORS configuration

3. **Database connection problems:**
   - Check database URL and credentials
   - Verify network settings
   - Review RLS policies

4. **File upload issues:**
   - Check storage bucket configuration
   - Verify file size limits
   - Ensure proper permissions

### Debug Commands:

```bash
# Check Flutter installation
flutter doctor

# Clear cache
flutter clean
flutter pub get

# Run in debug mode
flutter run --debug

# Check for issues
flutter analyze
```

## Support and Documentation

- Keep deployment documentation updated
- Document any custom configurations
- Maintain troubleshooting guides
- Provide contact information for support

Remember to test thoroughly in a staging environment before deploying to production!
