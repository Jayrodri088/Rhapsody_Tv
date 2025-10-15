# RhapsodyTV Authentication & Backend Integration Setup

This document provides a complete overview of the authentication system and backend integration implemented for the RhapsodyTV Flutter app.

## Overview

The app now includes:
- Full authentication flow (register, login, logout)
- User profile management with editing capabilities
- Token-based session management
- PHP REST API backend with JSON file storage
- State management using Provider pattern

## Architecture

### Flutter App Structure

```
lib/
├── models/
│   └── user_model.dart          # User data model
├── providers/
│   └── auth_provider.dart       # Authentication state management
├── services/
│   └── api_service.dart         # API communication layer
├── screens/
│   ├── sign_in_screen.dart      # Login screen
│   ├── sign_up_screen.dart      # Registration screen
│   ├── profile_screen.dart      # User profile management
│   └── discover_screen.dart     # Main app screen
└── main.dart                     # App entry with providers
```

### Backend Structure

```
rtv-backend/api/
├── config.php                    # Configuration and helper functions
├── auth/
│   ├── register.php             # User registration endpoint
│   ├── login.php                # User login endpoint
│   └── logout.php               # User logout endpoint
├── users/
│   └── profile.php              # Get/Update profile endpoint
├── comments/
│   ├── add.php                  # Add comment endpoint
│   └── get.php                  # Get comments endpoint
└── database/
    ├── users.json               # User data storage
    └── comments.json            # Comments data storage
```

## API Endpoints

### Authentication Endpoints

#### 1. Register User
**Endpoint:** `POST /api/auth/register.php`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "confirm_password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user": {
      "id": "user_xxxxx",
      "email": "user@example.com",
      "token": "generated_token",
      "created_at": "2025-10-15 12:00:00"
    }
  }
}
```

#### 2. Login User
**Endpoint:** `POST /api/auth/login.php`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "user_xxxxx",
      "email": "user@example.com",
      "token": "generated_token",
      "last_login": "2025-10-15 12:30:00"
    }
  }
}
```

#### 3. Logout User
**Endpoint:** `POST /api/auth/logout.php`

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

### User Profile Endpoints

#### 1. Get User Profile
**Endpoint:** `GET /api/users/profile.php`

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "user": {
      "id": "user_xxxxx",
      "email": "user@example.com",
      "username": "JohnDoe",
      "phone_number": "+1234567890",
      "profile_image": null,
      "created_at": "2025-10-15 12:00:00",
      "last_login": "2025-10-15 12:30:00"
    }
  }
}
```

#### 2. Update User Profile
**Endpoint:** `PUT /api/users/profile.php`

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "username": "JohnDoe",
  "phone_number": "+1234567890",
  "profile_image": "https://example.com/image.jpg"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "user": {
      "id": "user_xxxxx",
      "email": "user@example.com",
      "username": "JohnDoe",
      "phone_number": "+1234567890",
      "updated_at": "2025-10-15 13:00:00"
    }
  }
}
```

## Setup Instructions

### Backend Setup

1. **Start XAMPP:**
   - Start Apache server from XAMPP control panel
   - Ensure the backend is accessible at `http://localhost/rtv/rtv-backend/api`

2. **Verify Database Files:**
   - Check that `rtv-backend/api/database/users.json` exists
   - Check that `rtv-backend/api/database/comments.json` exists
   - Both files should have proper write permissions

3. **Test API:**
   ```bash
   curl -X POST http://localhost/rtv/rtv-backend/api/auth/register.php \
   -H "Content-Type: application/json" \
   -d '{"email":"test@test.com","password":"test123","confirm_password":"test123"}'
   ```

### Flutter App Setup

1. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure API URL:**
   Edit `lib/services/api_service.dart` and update the `baseUrl`:
   - For iOS Simulator: `http://localhost/rtv/rtv-backend/api`
   - For Android Emulator: `http://10.0.2.2/rtv/rtv-backend/api`
   - For Physical Device: `http://{YOUR_COMPUTER_IP}/rtv/rtv-backend/api`

3. **Run the App:**
   ```bash
   flutter run
   ```

## Features Implemented

### 1. User Registration
- Email validation
- Password strength check (minimum 6 characters)
- Password confirmation
- Terms and conditions acceptance
- Automatic login after registration
- Token generation for session management

### 2. User Login
- Email and password authentication
- Password verification using bcrypt
- Token generation on successful login
- Session persistence using SharedPreferences
- Automatic navigation to Discover screen

### 3. User Profile
- View user information (email, username, phone)
- Edit profile with inline validation
- Real-time updates
- Account information display (member since, last login)
- Profile avatar placeholder
- Logout functionality

### 4. Session Management
- Token-based authentication
- Automatic session restoration on app restart
- Secure token storage using SharedPreferences
- Token invalidation on logout

### 5. State Management
- Provider pattern for global state
- Loading states for async operations
- Error handling with user feedback
- Automatic UI updates on state changes

## Security Features

1. **Password Security:**
   - Passwords hashed using PHP's `password_hash()` with bcrypt
   - Passwords never stored in plain text
   - Password verification using `password_verify()`

2. **Token Security:**
   - Randomly generated 64-character tokens
   - Tokens stored securely in SharedPreferences
   - Tokens verified on each API request
   - Tokens invalidated on logout

3. **Input Validation:**
   - Email format validation
   - Password strength requirements
   - Input sanitization in PHP backend
   - XSS protection using `htmlspecialchars()`

4. **API Security:**
   - CORS headers configured
   - Request method validation
   - Authorization token verification
   - SQL injection prevention (using JSON storage)

## User Flow

### Registration Flow
1. User opens app → Splash Screen → Sign In Screen
2. User taps "Register Now" → Sign Up Screen
3. User enters email, password, confirms password
4. User accepts terms and conditions
5. User taps "REGISTER" button
6. App sends request to `/api/auth/register.php`
7. Backend validates data and creates user
8. Backend returns user data with token
9. App stores user data and token
10. App navigates to Discover Screen

### Login Flow
1. User opens app → Splash Screen → Sign In Screen
2. User enters email and password
3. User taps "ENTER" button
4. App sends request to `/api/auth/login.php`
5. Backend verifies credentials
6. Backend returns user data with token
7. App stores user data and token
8. App navigates to Discover Screen

### Profile Update Flow
1. User navigates to Profile Screen (from Discover Screen)
2. User taps "Edit" icon
3. User modifies username and/or phone number
4. User taps "Save" button
5. App sends request to `/api/users/profile.php`
6. Backend updates user data
7. Backend returns updated user data
8. App updates local state and storage
9. Success message shown to user

### Logout Flow
1. User navigates to Profile Screen
2. User taps "Logout" button
3. App sends request to `/api/auth/logout.php`
4. Backend invalidates token
5. App clears local storage
6. App navigates to Sign In Screen

## Testing the Integration

### Manual Testing Steps

1. **Test Registration:**
   - Open the app
   - Navigate to Sign Up screen
   - Enter valid email and password
   - Confirm password
   - Accept terms
   - Tap "REGISTER"
   - Verify navigation to Discover screen
   - Check that user is logged in

2. **Test Login:**
   - Logout from profile screen
   - Enter registered email and password
   - Tap "ENTER"
   - Verify navigation to Discover screen
   - Check that username appears in header

3. **Test Profile Update:**
   - Navigate to Profile screen
   - Tap edit icon
   - Change username and phone
   - Tap "Save"
   - Verify success message
   - Check that changes persist

4. **Test Session Persistence:**
   - Close and restart the app
   - Verify user remains logged in
   - Check that Discover screen loads

5. **Test Logout:**
   - Navigate to Profile screen
   - Tap "Logout"
   - Verify navigation to Sign In screen
   - Restart app
   - Verify user is logged out

## Troubleshooting

### Common Issues

1. **Network Error:**
   - Check XAMPP Apache is running
   - Verify API URL in `api_service.dart`
   - Check firewall settings
   - For physical device, ensure computer and device are on same network

2. **Database Error:**
   - Check file permissions on `users.json` and `comments.json`
   - Ensure files have write permissions (chmod 666)
   - Verify JSON format is valid

3. **Token Issues:**
   - Clear app data and reinstall
   - Check token is being sent in Authorization header
   - Verify token format: "Bearer {token}"

4. **CORS Issues:**
   - Verify CORS headers in `config.php`
   - Check browser/device allows cross-origin requests

## Next Steps

### Recommended Enhancements

1. **Security:**
   - Implement JWT tokens instead of random strings
   - Add token expiration
   - Implement refresh tokens
   - Add rate limiting

2. **Features:**
   - Forgot password functionality
   - Email verification
   - Social media login (KingsChat integration)
   - Profile image upload
   - Change password

3. **Backend:**
   - Migrate from JSON files to MySQL database
   - Add API versioning
   - Implement proper logging
   - Add backup system

4. **UI/UX:**
   - Add loading skeletons
   - Implement pull-to-refresh
   - Add profile image picker
   - Enhanced error messages

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review the code comments
3. Test API endpoints directly using curl or Postman
4. Check XAMPP error logs

## License

This is part of the RhapsodyTV project.
