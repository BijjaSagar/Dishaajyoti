# Platform Configuration Summary

This document provides an overview of the iOS and Android platform configurations for the DishaAjyoti app.

## App Identity

- **App Name**: DishaAjyoti
- **Display Name**: DishaAjyoti
- **Package Name (Android)**: `com.dishaajyoti.app`
- **Bundle Identifier (iOS)**: `com.dishaajyoti.app`
- **Version**: 1.0.0+1

## Android Configuration

### Package Information
- **Application ID**: `com.dishaajyoti.app`
- **Min SDK Version**: 21 (Android 5.0 Lollipop)
- **Target SDK Version**: Latest (configured via Flutter)
- **Compile SDK Version**: Latest (configured via Flutter)

### Permissions Configured

#### Network Permissions
- `INTERNET` - Required for API calls and data sync
- `ACCESS_NETWORK_STATE` - Check network connectivity

#### Notification Permissions
- `POST_NOTIFICATIONS` - Send push notifications (Android 13+)
- `VIBRATE` - Vibrate device for notifications

#### Storage Permissions
- `READ_EXTERNAL_STORAGE` - Read files (Android 12 and below)
- `WRITE_EXTERNAL_STORAGE` - Write files (Android 12 and below)
- `READ_MEDIA_IMAGES` - Read images (Android 13+)

#### Camera Permission
- `CAMERA` - Access camera for document scanning
- Hardware feature: `android.hardware.camera` (not required)

#### Location Permissions
- `ACCESS_COARSE_LOCATION` - Approximate location
- `ACCESS_FINE_LOCATION` - Precise location

#### Security Permissions
- `USE_BIOMETRIC` - Biometric authentication (Android 9+)
- `USE_FINGERPRINT` - Fingerprint authentication (legacy)

#### Background Processing
- `WAKE_LOCK` - Keep device awake for background tasks

### Build Configuration

#### Debug Build
- Application ID Suffix: `.debug`
- Debuggable: Yes
- Signing: Debug keystore

#### Release Build
- Minify Enabled: Yes
- Shrink Resources: Yes
- ProGuard: Enabled
- Signing: Release keystore (when configured)
- Supported ABIs: armeabi-v7a, arm64-v8a, x86_64

### Firebase Integration
- Firebase Cloud Messaging configured
- Firebase BOM version: 32.7.0
- Google Services plugin: 4.4.0

### Keystore Setup
See [ANDROID_KEYSTORE_SETUP.md](./ANDROID_KEYSTORE_SETUP.md) for detailed instructions.

**Quick Setup**:
1. Generate keystore: `keytool -genkey -v -keystore upload-keystore.jks ...`
2. Copy `key.properties.template` to `key.properties`
3. Fill in keystore credentials
4. Build release: `flutter build appbundle --release`

## iOS Configuration

### Bundle Information
- **Bundle Identifier**: `com.dishaajyoti.app`
- **Display Name**: DishaAjyoti
- **Minimum iOS Version**: 12.0
- **Development Region**: English

### Permissions Configured (Info.plist)

#### Camera Permission
- **Key**: `NSCameraUsageDescription`
- **Purpose**: Scan documents for palmistry analysis

#### Photo Library Permissions
- **Key**: `NSPhotoLibraryUsageDescription`
- **Purpose**: Upload images for analysis
- **Key**: `NSPhotoLibraryAddUsageDescription`
- **Purpose**: Save reports and images

#### Location Permission
- **Key**: `NSLocationWhenInUseUsageDescription`
- **Purpose**: Help select birth place accurately

#### Biometric Authentication
- **Key**: `NSFaceIDUsageDescription`
- **Purpose**: Secure authentication with Face ID

#### Background Modes
- **Remote Notifications**: Enabled for push notifications

### App Transport Security
- **NSAllowsArbitraryLoads**: false (HTTPS only)

### App Capabilities
- **ITSAppUsesNonExemptEncryption**: false (no custom encryption)

### UI Configuration
- **Status Bar Style**: Light content
- **View Controller Based Status Bar**: false
- **Supported Orientations (iPhone)**:
  - Portrait
  - Landscape Left
  - Landscape Right
- **Supported Orientations (iPad)**:
  - Portrait
  - Portrait Upside Down
  - Landscape Left
  - Landscape Right

### Code Signing
See [IOS_CODE_SIGNING_SETUP.md](./IOS_CODE_SIGNING_SETUP.md) for detailed instructions.

**Quick Setup**:
1. Enroll in Apple Developer Program
2. Create App ID: `com.dishaajyoti.app`
3. Create certificates (Development & Distribution)
4. Create provisioning profiles
5. Configure in Xcode
6. Build: `flutter build ipa --release`

## Security Configuration

### Android Security
- **ProGuard**: Enabled for code obfuscation
- **Minify**: Enabled to reduce APK size
- **Shrink Resources**: Enabled to remove unused resources
- **Multi-DEX**: Enabled for large app support

### iOS Security
- **HTTPS Only**: App Transport Security enforced
- **Keychain**: Secure storage for sensitive data
- **Code Signing**: Required for all builds

### Data Protection
- **Flutter Secure Storage**: Used for tokens and sensitive data
- **Encrypted Storage**: All sensitive data encrypted at rest
- **HTTPS**: All API communications over HTTPS
- **Certificate Pinning**: Recommended for production

## Firebase Configuration

### Android
- File: `android/app/google-services.json`
- Package name must match: `com.dishaajyoti.app`

### iOS
- File: `ios/Runner/GoogleService-Info.plist`
- Bundle ID must match: `com.dishaajyoti.app`

**Note**: These files contain sensitive information and should not be committed to public repositories.

## Build Commands

### Development Builds

#### Android
```bash
# Debug APK
flutter build apk --debug

# Debug on device
flutter run --debug
```

#### iOS
```bash
# Debug on simulator
flutter run --debug

# Debug on device
flutter run --debug -d <device-id>
```

### Release Builds

#### Android
```bash
# Release APK (for testing)
flutter build apk --release

# Release App Bundle (for Play Store)
flutter build appbundle --release

# Output locations:
# APK: build/app/outputs/flutter-apk/app-release.apk
# AAB: build/app/outputs/bundle/release/app-release.aab
```

#### iOS
```bash
# Release IPA
flutter build ipa --release

# Output location:
# IPA: build/ios/ipa/dishaajyoti.ipa

# Or build in Xcode:
# Product → Archive → Distribute App
```

## Testing Builds

### Android
```bash
# Install release APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Check app info
adb shell dumpsys package com.dishaajyoti.app

# View logs
adb logcat | grep DishaAjyoti
```

### iOS
```bash
# List devices
flutter devices

# Run on specific device
flutter run --release -d <device-id>

# View logs in Xcode
# Window → Devices and Simulators → Select device → View Device Logs
```

## Store Submission Checklist

### Google Play Store (Android)

- [ ] Release App Bundle built and signed
- [ ] App tested on multiple devices
- [ ] Screenshots prepared (phone & tablet)
- [ ] Feature graphic created (1024x500)
- [ ] App icon finalized (512x512)
- [ ] Privacy policy URL ready
- [ ] App description written (short & full)
- [ ] Content rating completed
- [ ] Pricing and distribution set
- [ ] Release notes prepared

### Apple App Store (iOS)

- [ ] Release IPA built and signed
- [ ] App tested on multiple devices
- [ ] Screenshots prepared (all required sizes)
- [ ] App preview video (optional)
- [ ] App icon finalized (1024x1024)
- [ ] Privacy policy URL ready
- [ ] App description written
- [ ] Keywords selected
- [ ] Age rating completed
- [ ] Pricing and availability set
- [ ] App Store Connect metadata complete

## Troubleshooting

### Common Android Issues

**Build fails with "Execution failed for task ':app:processReleaseResources'"**
- Clean build: `flutter clean && flutter pub get`
- Check `google-services.json` is present
- Verify package name matches in all files

**"Keystore file not found"**
- Ensure `key.properties` exists and paths are correct
- Check keystore file location

**"Duplicate class found"**
- Check for conflicting dependencies in `build.gradle`
- Run `./gradlew app:dependencies` to analyze

### Common iOS Issues

**"Code signing error"**
- Verify Bundle ID matches App ID
- Check certificates are valid and not expired
- Download provisioning profiles in Xcode

**"Build input file cannot be found"**
- Clean build folder: Product → Clean Build Folder
- Delete DerivedData
- Run `flutter clean`

**"Archive not showing in Organizer"**
- Select "Generic iOS Device" before archiving
- Ensure scheme is set to "Release"

## Environment Variables

For sensitive configuration, consider using environment variables:

```dart
// lib/config/environment.dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.dishaajyoti.com',
  );
  
  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: '',
  );
}
```

Build with environment variables:
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.dishaajyoti.com
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build appbundle --release
      
  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build ipa --release
```

## Support and Resources

- **Flutter Documentation**: https://docs.flutter.dev
- **Android Developer**: https://developer.android.com
- **Apple Developer**: https://developer.apple.com
- **Firebase Console**: https://console.firebase.google.com

## Maintenance

### Regular Tasks
- [ ] Renew iOS certificates annually
- [ ] Update Android keystore backup
- [ ] Review and update permissions
- [ ] Update Firebase configuration
- [ ] Test on latest OS versions
- [ ] Update dependencies regularly
- [ ] Monitor crash reports
- [ ] Review security best practices

---

**Last Updated**: October 24, 2025
**Version**: 1.0.0
