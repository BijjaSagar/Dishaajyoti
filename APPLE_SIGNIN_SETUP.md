# Apple Sign-In Configuration Guide

This guide explains how to configure Apple Sign-In for the DishaAjyoti app.

## Prerequisites

- Apple Developer Account (paid membership required)
- Xcode installed on macOS
- Physical iOS device for testing (Apple Sign-In doesn't work on simulator)

## Firebase Console Configuration

### 1. Enable Apple Sign-In Provider

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `vagdishaajyoti`
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Apple** provider
5. Enable the provider
6. Click **Save**

## Apple Developer Portal Configuration

### 1. Enable Sign in with Apple Capability

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click on **Identifiers**
4. Select your app identifier: `com.dishaajyoti.app`
5. Scroll down and check **Sign in with Apple**
6. Click **Save**

### 2. Create Service ID (Optional - for web)

If you plan to support Apple Sign-In on web:

1. In Apple Developer Portal, go to **Identifiers**
2. Click the **+** button
3. Select **Services IDs** and click **Continue**
4. Fill in:
   - Description: DishaAjyoti Web
   - Identifier: `com.dishaajyoti.app.web`
5. Check **Sign in with Apple**
6. Click **Configure**
7. Add your domain and return URLs
8. Click **Save** and **Continue**

## Xcode Configuration

### 1. Open Project in Xcode

```bash
cd Dishaajyoti/ios
open Runner.xcworkspace
```

### 2. Add Sign in with Apple Capability

1. Select the **Runner** target in Xcode
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Search for and add **Sign in with Apple**
5. The capability should appear with no errors

### 3. Verify Bundle Identifier

1. In **Signing & Capabilities** tab
2. Verify **Bundle Identifier** is: `com.dishaajyoti.app`
3. Ensure it matches the identifier in Apple Developer Portal

### 4. Configure Signing

1. Select your **Team** from the dropdown
2. Choose **Automatically manage signing** (recommended)
3. Or manually select a provisioning profile that includes Sign in with Apple

## iOS Info.plist Configuration

The Info.plist is already configured with necessary permissions. No additional changes needed for Apple Sign-In.

## Testing Apple Sign-In

### Important Notes

- Apple Sign-In **ONLY works on physical iOS devices**
- Simulator will fail with authentication errors
- Device must be running iOS 13.0 or later
- User must be signed in to iCloud on the device

### Test on Physical Device

1. Connect your iOS device via USB
2. Build and run the app:
   ```bash
   cd Dishaajyoti
   flutter run -d <device-id>
   ```

3. Navigate to the login screen
4. Tap "Sign in with Apple"
5. Authenticate with Face ID/Touch ID or device passcode
6. Choose to share or hide your email
7. Verify successful sign-in

### First-Time Sign-In Behavior

On first sign-in, Apple provides:
- User's full name (if user chooses to share)
- User's email (real or private relay email)

On subsequent sign-ins:
- Only the user ID is provided
- Name and email are NOT provided again
- Your app should store this information on first sign-in

## Handling Email Privacy

Apple allows users to hide their email address. In this case:
- Apple provides a private relay email: `xyz@privaterelay.appleid.com`
- Emails sent to this address are forwarded to the user's real email
- Your app should handle both real and private relay emails

## Code Implementation

The Apple Sign-In implementation in `FirebaseAuthService` handles:

1. **Sign In**: `signInWithApple()`
   - Requests email and full name scopes
   - Creates OAuth credential
   - Signs in to Firebase
   - Creates/updates user profile in Firestore

2. **Account Linking**: `linkWithApple()`
   - Links Apple account to existing Firebase user
   - Allows users to sign in with multiple providers

3. **Error Handling**:
   - User cancellation
   - Invalid credentials
   - Network errors
   - Authorization errors

## Troubleshooting

### Error: "Sign in with Apple is not available"

**Solution:**
- Verify you're testing on a physical device (not simulator)
- Check device is running iOS 13.0 or later
- Ensure device is signed in to iCloud

### Error: "Invalid client ID" or "Invalid request"

**Solution:**
- Verify Bundle Identifier matches Apple Developer Portal
- Check Sign in with Apple capability is enabled in Xcode
- Rebuild the app after making changes

### Error: "User cancelled the authorization"

**Solution:**
- This is normal behavior when user taps "Cancel"
- Handle gracefully in your UI
- No action needed

### Error: "The operation couldn't be completed"

**Solution:**
- Check Apple Developer Portal configuration
- Verify app identifier has Sign in with Apple enabled
- Ensure provisioning profile includes the capability
- Try signing out of iCloud and signing back in on device

### Name/Email Not Provided on Subsequent Sign-Ins

**Solution:**
- This is expected behavior
- Apple only provides name/email on first sign-in
- Store this information in Firestore on first sign-in
- Use stored data for subsequent sign-ins

### Testing with Multiple Accounts

To test with different Apple IDs:

1. Go to device **Settings** → **Apple ID** → **Password & Security**
2. Tap **Apps Using Apple ID**
3. Find **DishaAjyoti**
4. Tap **Stop Using Apple ID**
5. Sign in again with a different Apple ID

## Privacy Considerations

### App Store Review

When submitting to App Store:
- If you offer Google Sign-In, you MUST also offer Apple Sign-In
- Apple requires this for apps that use third-party sign-in
- Ensure Apple Sign-In button is prominently displayed

### User Data

- Store user's name and email on first sign-in
- Respect user's choice to hide email
- Handle private relay emails properly
- Don't request unnecessary permissions

## Current Configuration Status

- ✅ Firebase Authentication service implemented
- ✅ Apple Sign-In package added to pubspec.yaml
- ✅ iOS Info.plist configured with necessary permissions
- ⚠️ **TODO**: Enable Sign in with Apple in Apple Developer Portal
- ⚠️ **TODO**: Add Sign in with Apple capability in Xcode
- ⚠️ **TODO**: Configure signing with appropriate team and provisioning profile
- ⚠️ **TODO**: Test on physical iOS device

## Next Steps

1. Enable Sign in with Apple for app identifier in Apple Developer Portal
2. Open project in Xcode and add Sign in with Apple capability
3. Configure signing with your Apple Developer team
4. Build and test on a physical iOS device
5. Verify user profile creation in Firestore
6. Test account linking functionality
7. Test with multiple Apple IDs

## Additional Resources

- [Apple Sign-In Documentation](https://developer.apple.com/sign-in-with-apple/)
- [Firebase Apple Sign-In Guide](https://firebase.google.com/docs/auth/ios/apple)
- [sign_in_with_apple Package](https://pub.dev/packages/sign_in_with_apple)
