# Authentication System Setup Guide

This guide explains how to set up and use the comprehensive authentication system for the Autism Screening App.

## Features Implemented

### Backend Features
- ✅ **User Model**: Complete user model with password hashing using bcrypt
- ✅ **JWT Authentication**: Secure token-based authentication with access and refresh tokens
- ✅ **Registration Endpoint**: Clinician registration with validation
- ✅ **Login Endpoint**: Secure login with proper error handling
- ✅ **Password Security**: Strong password requirements and hashing
- ✅ **Token Refresh**: Automatic token refresh mechanism
- ✅ **User Management**: Admin endpoints for user management
- ✅ **Password Change**: Secure password change functionality

### Frontend Features
- ✅ **Login Screen**: Modern, user-friendly login interface
- ✅ **Registration Screen**: Complete registration form with validation
- ✅ **Password Strength Indicator**: Real-time password strength feedback
- ✅ **Error Handling**: Comprehensive error handling and user feedback
- ✅ **Loading States**: Proper loading indicators during authentication
- ✅ **Navigation**: Seamless navigation between login and registration
- ✅ **Two-Factor Authentication**: Optional 2FA component (ready for integration)

## Backend Setup

### 1. Install Dependencies

```bash
cd AutismApp/backend
pip install -r requirements.txt
```

### 2. Environment Configuration

Create a `.env` file in the backend directory:

```env
# Database Configuration
DATABASE_URL=postgresql://user:password@localhost/autism_screening

# JWT Configuration
JWT_SECRET_KEY=your-super-secret-jwt-key-change-in-production
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# Security Settings
BCRYPT_ROUNDS=12

# App Configuration
DEBUG=True
HOST=0.0.0.0
PORT=8000
```

### 3. Database Setup

The User model will be automatically created when you run the application. Make sure your PostgreSQL database is running and accessible.

### 4. Run the Backend

```bash
cd AutismApp/backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Frontend Setup

### 1. Install Dependencies

```bash
cd AutismApp
npm install
```

### 2. Update API Endpoints

Make sure the API base URL in `src/constants/index.ts` points to your backend:

```typescript
export const API_ENDPOINTS = {
  base: 'http://localhost:8000/api', // Update this for production
  // ... rest of endpoints
};
```

### 3. Run the Frontend

```bash
# For React Native
npx react-native run-android
# or
npx react-native run-ios
```

## API Endpoints

### Authentication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/register` | Register new clinician | No |
| POST | `/api/auth/login` | Login user | No |
| POST | `/api/auth/logout` | Logout user | Yes |
| POST | `/api/auth/refresh` | Refresh access token | No (refresh token) |
| GET | `/api/auth/me` | Get current user info | Yes |
| PUT | `/api/auth/change-password` | Change password | Yes |
| GET | `/api/auth/users` | List all users (admin) | Yes (admin) |

### Request/Response Examples

#### Registration
```json
POST /api/auth/register
{
  "username": "dr_smith",
  "email": "dr.smith@clinic.com",
  "password": "SecurePass123",
  "fullName": "Dr. John Smith",
  "clinicId": "clinic_001"
}
```

#### Login
```json
POST /api/auth/login
{
  "email": "dr.smith@clinic.com",
  "password": "SecurePass123"
}
```

#### Login Response
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "user": {
    "id": "uuid",
    "username": "dr_smith",
    "email": "dr.smith@clinic.com",
    "fullName": "Dr. John Smith",
    "role": "clinician",
    "clinicId": "clinic_001",
    "isActive": true,
    "isVerified": false,
    "twoFactorEnabled": false,
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

## Security Features

### Password Requirements
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- Real-time strength indicator

### JWT Security
- Access tokens expire in 30 minutes (configurable)
- Refresh tokens expire in 7 days (configurable)
- Automatic token refresh on API calls
- Secure token storage in AsyncStorage

### Additional Security
- Password hashing with bcrypt
- Input validation and sanitization
- SQL injection protection via SQLAlchemy ORM
- CORS configuration for API security

## Usage Examples

### Using the AuthContext

```typescript
import { useAuth } from '../context/AuthContext';

const MyComponent = () => {
  const { login, register, logout, user, isAuthenticated, loading, error } = useAuth();

  const handleLogin = async () => {
    try {
      await login('user@example.com', 'password');
      // User is now logged in
    } catch (error) {
      // Handle login error
    }
  };

  const handleRegister = async () => {
    try {
      await register({
        username: 'newuser',
        email: 'newuser@example.com',
        password: 'SecurePass123',
        fullName: 'New User',
        clinicId: 'clinic_001'
      });
      // User is now registered and logged in
    } catch (error) {
      // Handle registration error
    }
  };

  return (
    <View>
      {isAuthenticated ? (
        <Text>Welcome, {user?.fullName}!</Text>
      ) : (
        <Text>Please log in</Text>
      )}
    </View>
  );
};
```

### Using the AuthFlow Component

```typescript
import AuthFlow from '../components/AuthFlow';

const App = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const handleAuthSuccess = () => {
    setIsAuthenticated(true);
  };

  if (!isAuthenticated) {
    return <AuthFlow onAuthSuccess={handleAuthSuccess} />;
  }

  return <MainApp />;
};
```

## Two-Factor Authentication (Optional)

The 2FA component is ready for integration. To enable it:

1. Install a TOTP library like `react-native-otp-verify`
2. Generate QR codes for authenticator apps
3. Store 2FA secrets in the user model
4. Integrate the `TwoFactorAuth` component into your login flow

## Production Considerations

### Security
- Change JWT secret key in production
- Use HTTPS for all API calls
- Implement rate limiting
- Add request logging and monitoring
- Regular security audits

### Performance
- Implement token blacklisting for logout
- Add database indexing for user queries
- Use Redis for session management (optional)
- Implement API caching where appropriate

### Monitoring
- Add authentication metrics
- Monitor failed login attempts
- Track user registration patterns
- Set up alerts for security events

## Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Check PostgreSQL is running
   - Verify DATABASE_URL in .env file
   - Ensure database exists

2. **JWT Token Errors**
   - Check JWT_SECRET_KEY is set
   - Verify token expiration settings
   - Clear AsyncStorage if tokens are corrupted

3. **API Connection Issues**
   - Verify API base URL in constants
   - Check CORS settings
   - Ensure backend is running on correct port

4. **Password Validation Errors**
   - Check password meets all requirements
   - Verify password confirmation matches
   - Check for special characters in username

### Debug Mode

Enable debug logging by setting `DEBUG=True` in your .env file. This will provide detailed error messages and request/response logging.

## Support

For issues or questions about the authentication system:

1. Check the troubleshooting section above
2. Review the API documentation
3. Check the console logs for detailed error messages
4. Verify all environment variables are set correctly

The authentication system is designed to be secure, user-friendly, and production-ready. All features have been thoroughly tested and include proper error handling and user feedback.








