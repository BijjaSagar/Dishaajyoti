# Google Sign-In Configuration Guide

This guide explains how to configure Google Sign-In for the DishaAjyoti app.

## Firebase Console Configuration

### 1. Enable Google Sign-In Provider

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `vagdishaajyoti`
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. Enable the provider
6. Set the project support email
7. Click **Save**

### 2. Configure OAuth Consent Screen (Google Cloud Console)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: `vagdishaajyoti`
3. Navigate to **APIs & Services** → **OAuth consent screen**
4. Configure the consent screen:
   - App name: DishaAjyoti
   - User support email: your-email@example.com
   - Developer contact information: your-email@example.com
5. Add scopes (if needed):
   - `email`
   - `profile`
6. Save and continue

## Android Configuration

### 1. Get SHA-1 Fingerprint

For **Debug** builds:
```bash
cd Dishaajyoti/android
./gradlew signingReport
```

Look for the SHA-1 fingerprint under `Variant: debug` → `Config: debug`

For **Release** builds (if you have a keystore):
```bash
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias
```

### 2. Add SHA-1 to Firebase

1. Go to Firebase Console → Project Settings
2. Scroll down to **Your apps** section
3. Click on your Android app
4. Click **Add fingerprint**
5. Paste the SHA-1 fingerprint
6. Click **Save**

### 3. Download Updated google-services.json

1. After adding SHA-1, download the updated `google-services.json`
2. Replace the file at: `Dishaajyoti/android/app/google-services.json`
3. The file should now contain OAuth client information

## iOS Configuration

### 1. Get Reversed Client ID

1. Open `Dishaajyoti/ios/Runner/GoogleService-Info.plist`
2. Look for the `REVERSED_CLIENT_ID` key
3. Copy the value (format: `com.googleusercontent.apps.XXXXXXXXX-YYYYYYYY`)

### 2. Update Info.plist

The `Info.plist` has been pre-configured with a placeholder. Update it:

1. Open `Dishaajyoti/ios/Runner/Info.plist`
2. Find the `CFBundleURLSchemes` array
3. Replace `com.googleusercontent.apps.260749666922-REVERSED_CLIENT_ID` with your actual reversed client ID from step 1

Example:
```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.260749666922-abc123xyz456</string>
</array>
```

### 3. Configure Xcode Project (if needed)

1. Open `Dishaajyoti/ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target
3. Go to **Info** tab
4. Verify the URL Types section contains the reversed client ID

## Testing Google Sign-In

### Test on Android

1. Build and run the app:
   ```bash
   cd Dishaajyoti
   flutter run
   ```

2. Navigate to the login screen
3. Tap "Sign in with Google"
4. Select a Google account
5. Verify successful sign-in

### Test on iOS

1. Build and run on a physical device (simulator may have limitations):
   ```bash
   cd Dishaajyoti
   flutter run -d <device-id>
   ```

2. Navigate to the login screen
3. Tap "Sign in with Google"
4. Select a Google account
5. Verify successful sign-in

## Troubleshooting

### Android Issues

**Error: "Developer Error" or "Sign-in failed"**
- Verify SHA-1 fingerprint is correctly added to Firebase
- Download and replace `google-services.json`
- Clean and rebuild the project:
  ```bash
  cd Dishaajyoti/android
  ./gradlew clean
  cd ..
  flutter clean
  flutter pub get
  ```

**Error: "API not enabled"**
- Go to Google Cloud Console
- Enable **Google Sign-In API**

### iOS Issues

**Error: "Sign-in failed" or "Invalid client ID"**
- Verify `REVERSED_CLIENT_ID` is correctly added to `Info.plist`
- Check that the URL scheme matches exactly
- Rebuild the app

**Error: "The operation couldn't be completed"**
- Ensure you're testing on a physical device
- Check that Google Sign-In is enabled in Firebase Console

## Current Configuration Status

- ✅ Firebase Authentication service implemented
- ✅ Google Sign-In package added to pubspec.yaml
- ✅ iOS Info.plist configured with URL scheme placeholder
- ⚠️ **TODO**: Add SHA-1 fingerprint to Firebase Console
- ⚠️ **TODO**: Download updated google-services.json with OAuth client
- ⚠️ **TODO**: Update iOS Info.plist with actual REVERSED_CLIENT_ID

## Next Steps

1. Generate SHA-1 fingerprint for debug and release builds
2. Add SHA-1 to Firebase Console
3. Download updated google-services.json
4. Get REVERSED_CLIENT_ID from GoogleService-Info.plist
5. Update iOS Info.plist with actual reversed client ID
6. Test Google Sign-In on both platforms
