/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'DishaAjyoti';
  static const String appTagline = 'Career & Life Guidance';
  static const String appVersion = '1.0.0';

  // API Configuration
  // For development, use: 'http://localhost:8000' or 'http://10.0.2.2:8000' (Android emulator)
  // For production, use: 'https://api.dishaajyoti.com'
  static const String baseUrl = 'http://localhost:8000';  // Change to your server URL
  static const String apiVersion = 'v1';
  static const String apiBaseUrl = '$baseUrl/api/$apiVersion';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String registerEndpoint = '$authEndpoint/register';
  static const String logoutEndpoint = '$authEndpoint/logout';
  static const String refreshTokenEndpoint = '$authEndpoint/refresh';
  static const String resetPasswordEndpoint = '$authEndpoint/reset-password';

  static const String profileEndpoint = '/profile';
  static const String servicesEndpoint = '/services';
  static const String paymentsEndpoint = '/payments';
  static const String reportsEndpoint = '/reports';
  static const String notificationsEndpoint = '/notifications';

  // AI Endpoints (New)
  static const String aiEndpoint = '/ai';
  static const String aiQueryEndpoint = '$aiEndpoint/query';
  static const String aiChatEndpoint = '$aiEndpoint/chat';

  // Timeout Configuration (in seconds)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  // Session Configuration
  static const int sessionTimeoutMinutes = 30;
  static const int sessionPersistenceDays = 7;
  static const int maxFailedLoginAttempts = 5;
  static const int accountLockoutMinutes = 15;

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String tokenExpiryKey = 'token_expiry';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String lastActivityKey = 'last_activity';
  static const String languageKey = 'language';
  static const String notificationsEnabledKey = 'notifications_enabled';

  // Validation Limits
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int minAgeYears = 13;
  static const int phoneNumberLength = 10;

  // UI Configuration
  static const int splashScreenDurationSeconds = 3;
  static const int onboardingSlideCount = 6;
  static const int profileSetupSteps = 3;

  // Animation Durations (in milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;
  static const int splashAnimationDuration = 1500;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload Limits
  static const int maxFileUploadSizeMB = 10;
  static const int maxImageUploadSizeMB = 5;

  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 2;

  // Cache Configuration
  static const int imageCacheDurationDays = 7;
  static const int apiCacheDurationMinutes = 5;

  // Payment Configuration
  static const String currencyCode = 'INR';
  static const String currencySymbol = '₹';

  // Service IDs (these would typically come from backend)
  static const String palmistryServiceId = 'palmistry';
  static const String vedicJyotishServiceId = 'vedic-jyotish';
  static const String numerologyServiceId = 'numerology';

  // Service Prices (in rupees)
  static const int palmistryPrice = 299;
  static const int vedicJyotishPrice = 499;
  static const int numerologyPrice = 199;

  // Report Generation
  static const int reportGenerationTimeoutMinutes = 10;
  static const int reportPollingIntervalSeconds = 5;

  // Notification Configuration
  static const String fcmTopicGeneral = 'general';
  static const String fcmTopicReports = 'reports';
  static const String fcmTopicPromotions = 'promotions';

  // Deep Link Configuration
  static const String deepLinkScheme = 'dishaajyoti';
  static const String deepLinkHost = 'app';

  // Error Messages
  static const String networkErrorMessage =
      'Network error. Please check your connection and try again.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String unknownErrorMessage =
      'An unexpected error occurred. Please try again.';
  static const String sessionExpiredMessage =
      'Your session has expired. Please log in again.';
  static const String paymentFailedMessage =
      'Payment failed. Please try again.';

  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String registrationSuccessMessage = 'Registration successful!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  static const String paymentSuccessMessage = 'Payment successful!';
  static const String reportGeneratedMessage = 'Your report is ready!';

  // Regex Patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^(\+91)?[6-9]\d{9}$';
  static const String namePattern = r"^[a-zA-Z\s\-']+$";

  // Date/Time Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  // Supported Languages
  static const String languageEnglish = 'en';
  static const String languageHindi = 'hi';
  static const List<String> supportedLanguages = [
    languageEnglish,
    languageHindi
  ];

  // Terms and Privacy URLs
  static const String termsOfServiceUrl = 'https://dishaajyoti.com/terms';
  static const String privacyPolicyUrl = 'https://dishaajyoti.com/privacy';
  static const String supportEmail = 'support@dishaajyoti.com';
  static const String supportPhone = '+91-1234567890';

  // Social Media URLs
  static const String facebookUrl = 'https://facebook.com/dishaajyoti';
  static const String instagramUrl = 'https://instagram.com/dishaajyoti';
  static const String twitterUrl = 'https://twitter.com/dishaajyoti';

  // Feature Flags (for gradual rollout)
  static const bool enableBiometricAuth = false;
  static const bool enableDarkMode = false;
  static const bool enableSocialLogin = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;

  // Debug Configuration
  static const bool enableDebugLogging = true;
  static const bool enablePerformanceMonitoring = true;
}
