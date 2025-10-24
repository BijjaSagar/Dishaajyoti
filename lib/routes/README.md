# Routing and Navigation System

This directory contains the complete routing and navigation system for the DishaAjyoti application.

## Files

### app_routes.dart
Central routing configuration with all named routes and route generation logic.

**Features:**
- Named route definitions
- Dynamic route generation with arguments
- Helper methods for common navigation patterns
- Error route handling

**Usage:**
```dart
// Navigate to a named route
Navigator.pushNamed(context, AppRoutes.dashboard);

// Navigate with arguments
AppRoutes.navigateToPayment(context, service);

// Navigate and clear stack
AppRoutes.navigateAndClearStack(context, AppRoutes.login);
```

### route_guard.dart
Authentication middleware for protecting routes.

**Features:**
- Protects authenticated routes
- Redirects unauthenticated users to login
- Validates session before navigation
- Updates activity timestamp
- Handles guest-only routes

**Usage:**
```dart
// Check if navigation is allowed
final canNavigate = await RouteGuard.canNavigate(context, AppRoutes.dashboard);

// Wrap a widget with route guard
RouteGuard.guard(
  context: context,
  routeName: AppRoutes.dashboard,
  child: DashboardScreen(),
);
```

### navigation_service.dart
Global navigation service for navigating without BuildContext.

**Features:**
- Navigate from anywhere (services, providers, etc.)
- Show dialogs and bottom sheets
- Display snackbars
- Pop and push operations

**Usage:**
```dart
// Navigate from a service or provider
NavigationService().navigateTo(AppRoutes.login);

// Show snackbar
NavigationService().showSnackBar('Login successful');

// Pop current route
NavigationService().pop();
```

### deep_link_handler.dart
Deep linking support for app links and universal links.

**Features:**
- Parse deep link URIs
- Handle navigation from external sources
- Create shareable links
- Support for dynamic routes

**Usage:**
```dart
// Parse a deep link
final route = DeepLinkHandler.parseDeepLink(uri);

// Handle deep link navigation
await DeepLinkHandler.handleDeepLink(context, uri);

// Create shareable link
final link = DeepLinkHandler.getReportShareLink(reportId);
```

## Route Structure

### Public Routes (No Authentication Required)
- `/` - Splash screen
- `/onboarding` - Onboarding slides
- `/login` - Login screen
- `/signup` - Signup screen
- `/forgot-password` - Password reset

### Protected Routes (Authentication Required)
- `/profile-setup` - Profile setup wizard
- `/dashboard` - Main dashboard
- `/payment` - Payment processing
- `/report-processing` - Report generation status
- `/report-detail` - View generated report

## Navigation Patterns

### 1. Simple Navigation
```dart
Navigator.pushNamed(context, AppRoutes.login);
```

### 2. Navigation with Arguments
```dart
// For payment screen
AppRoutes.navigateToPayment(context, service);

// For report detail
AppRoutes.navigateToReportDetail(
  context,
  report: report,
  service: service,
);
```

### 3. Replace Current Route
```dart
AppRoutes.navigateAndReplace(context, AppRoutes.dashboard);
```

### 4. Clear Navigation Stack
```dart
AppRoutes.navigateAndClearStack(context, AppRoutes.login);
```

### 5. Navigation from Services/Providers
```dart
// In a service or provider
NavigationService().navigateAndClearStack(AppRoutes.login);
```

## Deep Linking

### Supported Deep Link Patterns

**App Links:**
- `dishaajyoti://app/login`
- `dishaajyoti://app/dashboard`
- `dishaajyoti://app/service/{serviceId}`
- `dishaajyoti://app/report/{reportId}`

**Universal Links:**
- `https://dishaajyoti.com/login`
- `https://dishaajyoti.com/reset-password?token=xxx`
- `https://dishaajyoti.com/service/{serviceId}`
- `https://dishaajyoti.com/report/{reportId}`

### Configuration

**Android (AndroidManifest.xml):**
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="dishaajyoti" android:host="app" />
    <data android:scheme="https" android:host="dishaajyoti.com" />
</intent-filter>
```

**iOS (Info.plist):**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>dishaajyoti</string>
        </array>
    </dict>
</array>
```

## Route Guards

### Protected Routes
Routes that require authentication are automatically guarded. If a user tries to access a protected route without being authenticated, they will be redirected to the login screen.

### Guest-Only Routes
Routes like login and signup will redirect authenticated users to the dashboard.

### Session Validation
Before navigating to protected routes, the system validates that the user's session is still active. Expired sessions trigger automatic logout and redirect to login.

## Error Handling

### Unknown Routes
If a user navigates to an unknown route, they will see an error screen with an option to return to the home screen.

### Missing Arguments
Routes that require arguments (like payment or report detail) will show an error if the required data is missing.

## Best Practices

1. **Always use named routes** instead of direct widget navigation
2. **Use AppRoutes helper methods** for common navigation patterns
3. **Pass arguments through route arguments** instead of constructor parameters for deep linking support
4. **Update activity timestamp** when navigating to protected routes (handled automatically by route guard)
5. **Use NavigationService** for navigation from services or providers
6. **Handle deep links** in the app's main entry point

## Testing

### Test Navigation
```dart
// Test navigation to a route
await tester.pumpWidget(MaterialApp(
  routes: AppRoutes.getRoutes(),
  onGenerateRoute: AppRoutes.onGenerateRoute,
));

await tester.tap(find.byType(ElevatedButton));
await tester.pumpAndSettle();

expect(find.byType(DashboardScreen), findsOneWidget);
```

### Test Route Guards
```dart
// Test that unauthenticated users are redirected
final authProvider = MockAuthProvider();
when(authProvider.isAuthenticated).thenReturn(false);

// Attempt to navigate to protected route
// Should redirect to login
```

## Requirements Coverage

This routing system satisfies the following requirements:
- **1.1, 1.2**: App launch and initial access with proper navigation
- **2.4, 2.5**: Onboarding navigation and completion
- **3.6**: Registration navigation to profile setup
- **4.2**: Login navigation to dashboard
- **5.4**: Profile setup navigation to dashboard
- **6.1**: Dashboard access and navigation
