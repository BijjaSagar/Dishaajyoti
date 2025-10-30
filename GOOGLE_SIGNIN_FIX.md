# Google Sign-In Fix Guide

## Problem
Google Sign-In is failing with error: `PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10:, null, null)`

## Root Cause
Error code 10 means the SHA-1 certificate fingerprint is not configured in Firebase Console, or the OAuth client ID is not properly set up.

## Solution

### Step 1: Get Your SHA-1 Certificate Fingerprint

#### For Debug Build:
```bash
cd Dishaajyoti/android
./gradlew signingReport
```

Or use keytool:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### For Release Build:
```bash
keytool -list -v -keystore /path/to/your/release.keystore -alias your-key-alias
```

Copy the SHA-1 fingerprint (looks like: `AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD`)

### Step 2: Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click on **Project Settings** (gear icon)
4. Scroll down to **Your apps** section
5. Select your Android app
6. Click **Add fingerprint**
7. Paste your SHA-1 fingerprint
8. Click **Save**

### Step 3: Download Updated google-services.json

1. After adding SHA-1, download the updated `google-services.json`
2. Replace the file at: `Dishaajyoti/android/app/google-services.json`

### Step 4: Verify OAuth Client ID

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to **APIs & Services** > **Credentials**
4. You should see an **OAuth 2.0 Client ID** for Android
5. Verify the **Package name** matches: `com.dishaajyoti.app`
6. Verify the **SHA-1** matches your certificate fingerprint

### Step 5: Clean and Rebuild

```bash
cd Dishaajyoti
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

### Step 6: Test Google Sign-In

1. Launch the app
2. Go to Login screen
3. Click "Continue with Google"
4. Select your Google account
5. Should sign in successfully

## Alternative: Manual OAuth Client ID Configuration

If automatic configuration doesn't work, you can manually configure the OAuth client:

### 1. Get Web Client ID from Firebase

1. Go to Firebase Console > Project Settings
2. Scroll to **Your apps** section
3. Find **Web API Key** or **Web client ID**
4. Copy the client ID (looks like: `123456789-abcdefghijklmnop.apps.googleusercontent.com`)

### 2. Update GoogleSignIn Configuration

In `firebase_auth_service.dart`, update the GoogleSignIn initialization:

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  clientId: 'YOUR_WEB_CLIENT_ID_HERE.apps.googleusercontent.com',
);
```

## Common Issues

### Issue 1: "Developer Error" or "Error 10"
**Solution**: SHA-1 not configured. Follow Step 1-3 above.

### Issue 2: "Sign-in failed" with no specific error
**Solution**: 
- Check internet connection
- Verify Google Play Services is installed and updated
- Clear app data and try again

### Issue 3: "Account already exists with different credential"
**Solution**: 
- User already signed up with email/password
- Use email/password login instead
- Or link Google account to existing account

### Issue 4: Works on emulator but not on physical device
**Solution**: 
- Get SHA-1 for release build
- Add release SHA-1 to Firebase Console
- Rebuild app with release configuration

## Verification Checklist

- [ ] SHA-1 fingerprint added to Firebase Console
- [ ] google-services.json downloaded and replaced
- [ ] Package name matches in Firebase and build.gradle
- [ ] OAuth client ID created in Google Cloud Console
- [ ] Google Sign-In enabled in Firebase Authentication
- [ ] App cleaned and rebuilt
- [ ] Google Play Services installed on device/emulator

## Testing

After completing the steps above:

1. **Test on Emulator**:
   ```bash
   flutter run
   ```

2. **Test on Physical Device**:
   ```bash
   flutter run --release
   ```

3. **Check Logs**:
   ```bash
   flutter logs
   ```
   Look for any Google Sign-In related errors

## Additional Resources

- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase Authentication](https://firebase.google.com/docs/auth/android/google-signin)

## Support

If you continue to experience issues:

1. Check Firebase Console > Authentication > Sign-in method
2. Ensure Google is enabled
3. Verify OAuth consent screen is configured
4. Check Google Cloud Console for any API restrictions

---

**Note**: For production apps, you MUST add both debug and release SHA-1 fingerprints to Firebase Console.
