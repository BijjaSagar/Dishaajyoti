# Firebase Cloud Messaging Setup

This document provides instructions for setting up Firebase Cloud Messaging (FCM) for the DishaAjyoti application.

## Prerequisites

- Firebase account (https://console.firebase.google.com)
- Flutter SDK installed
- Android Studio (for Android) or Xcode (for iOS)

## Setup Steps

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project" or select existing project
3. Enter project name: `dishaajyoti-app`
4. Follow the setup wizard

### 2. Android Setup

#### 2.1 Register Android App

1. In Firebase Console, click "Add app" and select Android
2. Enter package name: `com.dishaajyoti.app`
3. Download `google-services.json`
4. Replace the placeholder file at `android/app/google-services.json` with the downloaded file

#### 2.2 Verify Configuration

The following files have already been configured:
- `android/build.gradle` - Added Google Services plugin
- `android/app/build.gradle` - Added Firebase dependencies and plugin

#### 2.3 Update AndroidManifest.xml

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application>
        <!-- Add this service for background notifications -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        
        <!-- Add this meta-data for notification icon -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification" />
        
        <!-- Add this meta-data for notification color -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/notification_color" />
    </application>
</manifest>
```

### 3. iOS Setup

#### 3.1 Register iOS App

1. In Firebase Console, click "Add app" and select iOS
2. Enter bundle ID: `com.dishaajyoti.app`
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into the Runner folder in Xcode

#### 3.2 Enable Push Notifications

1. In Xcode, select Runner target
2. Go to "Signing & Capabilities"
3. Click "+ Capability" and add "Push Notifications"
4. Click "+ Capability" and add "Background Modes"
5. Check "Remote notifications" under Background Modes

#### 3.3 Update Info.plist

Add the following to `ios/Runner/Info.plist`:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

#### 3.4 Update AppDelegate.swift

The Firebase initialization is handled in the Flutter app's main.dart file, so no additional changes are needed in AppDelegate.swift.

### 4. Testing Notifications

#### 4.1 Get FCM Token

When you run the app, the FCM token will be printed in the console:
```
FCM Token: <your-token-here>
```

Copy this token for testing.

#### 4.2 Send Test Notification

1. Go to Firebase Console > Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and text
4. Click "Send test message"
5. Paste the FCM token
6. Click "Test"

#### 4.3 Test Notification Types

The app supports different notification types:
- `general` - General notifications
- `reportReady` - Report generation complete
- `paymentSuccess` - Payment successful
- `paymentFailed` - Payment failed
- `promotional` - Promotional offers

To test different types, send a notification with custom data:
```json
{
  "notification": {
    "title": "Your Report is Ready!",
    "body": "Your palmistry report has been generated."
  },
  "data": {
    "type": "reportReady",
    "reportId": "report123"
  }
}
```

### 5. Backend Integration

To send notifications from your backend:

#### 5.1 Get Server Key

1. Go to Firebase Console > Project Settings
2. Go to "Cloud Messaging" tab
3. Copy the "Server key"

#### 5.2 Send Notification via API

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "USER_FCM_TOKEN",
    "notification": {
      "title": "Notification Title",
      "body": "Notification Body"
    },
    "data": {
      "type": "reportReady",
      "reportId": "report123"
    }
  }'
```

#### 5.3 Send to Multiple Users

Use topic subscription or send to multiple tokens:

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "registration_ids": ["token1", "token2", "token3"],
    "notification": {
      "title": "Notification Title",
      "body": "Notification Body"
    }
  }'
```

### 6. Notification Handling

The app handles notifications in three states:

1. **Foreground** - App is open and active
   - Notification is saved to history
   - Unread count is incremented
   - No system notification is shown (handled by app)

2. **Background** - App is in background
   - System notification is shown
   - Tapping notification opens the app
   - Notification is marked as read

3. **Terminated** - App is closed
   - System notification is shown
   - Tapping notification launches the app
   - Notification is marked as read

### 7. Notification Navigation

When a user taps a notification, the app can navigate to specific screens based on the notification data:

- If `reportId` is present, navigate to report detail screen
- If `serviceId` is present, navigate to service detail screen
- Otherwise, open notifications screen

### 8. Troubleshooting

#### Android Issues

1. **Notifications not received**
   - Check if `google-services.json` is properly configured
   - Verify package name matches Firebase configuration
   - Check if app has notification permissions

2. **Build errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Rebuild the app

#### iOS Issues

1. **Notifications not received**
   - Check if `GoogleService-Info.plist` is added to Xcode project
   - Verify bundle ID matches Firebase configuration
   - Check if Push Notifications capability is enabled
   - Ensure you're testing on a physical device (not simulator)

2. **Permission denied**
   - Check if user granted notification permissions
   - Request permissions again if needed

### 9. Production Considerations

1. **APNs Certificate (iOS)**
   - Upload APNs authentication key or certificate to Firebase Console
   - Go to Project Settings > Cloud Messaging > iOS app configuration

2. **Server Key Security**
   - Never expose server key in client code
   - Store server key securely on backend
   - Use Firebase Admin SDK for backend integration

3. **Token Management**
   - Store FCM tokens in your database
   - Update tokens when they refresh
   - Remove tokens when users logout

4. **Notification Analytics**
   - Track notification delivery and open rates
   - Use Firebase Analytics for insights
   - Monitor notification performance

## Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/messaging/overview)
- [Firebase Console](https://console.firebase.google.com)
