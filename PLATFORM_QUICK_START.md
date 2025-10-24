# Platform Configuration Quick Start

Quick reference for setting up iOS and Android builds for DishaAjyoti.

## ⚡ Quick Setup

### Android Release Build

1. **Create Keystore** (one-time):
   ```bash
   cd android
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias dishaajyoti-release
   ```

2. **Configure Signing**:
   ```bash
   cp key.properties.template key.properties
   # Edit key.properties with your passwords
   ```

3. **Build**:
   ```bash
   flutter build appbundle --release
   ```

### iOS Release Build

1. **Setup Apple Developer Account** (one-time):
   - Enroll at developer.apple.com ($99/year)
   - Create App ID: `com.dishaajyoti.app`

2. **Configure Xcode**:
   ```bash
   cd ios
   open Runner.xcworkspace
   # Select your team in Signing & Capabilities
   ```

3. **Build**:
   ```bash
   flutter build ipa --release
   ```

## 📱 App Identity

| Platform | Identifier |
|----------|------------|
| Android Package | `com.dishaajyoti.app` |
| iOS Bundle ID | `com.dishaajyoti.app` |
| App Name | DishaAjyoti |
| Version | 1.0.0+1 |

## 🔐 Permissions Summary

### Android
- ✅ Internet & Network State
- ✅ Notifications & Vibrate
- ✅ Storage (Read/Write)
- ✅ Camera
- ✅ Location (Coarse/Fine)
- ✅ Biometric Authentication
- ✅ Wake Lock

### iOS
- ✅ Camera Usage
- ✅ Photo Library (Read/Write)
- ✅ Location (When In Use)
- ✅ Face ID
- ✅ Remote Notifications

## 🛠️ Common Commands

### Development
```bash
# Run debug build
flutter run --debug

# Hot reload
r (in terminal)

# Hot restart
R (in terminal)
```

### Testing
```bash
# Run tests
flutter test

# Run integration tests
flutter test integration_test/

# Analyze code
flutter analyze
```

### Building
```bash
# Android APK (testing)
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS IPA (App Store)
flutter build ipa --release
```

### Cleaning
```bash
# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Full clean rebuild
flutter clean && flutter pub get && flutter build apk --release
```

## 📦 Build Outputs

### Android
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **AAB**: `build/app/outputs/bundle/release/app-release.aab`

### iOS
- **IPA**: `build/ios/ipa/dishaajyoti.ipa`
- **Archive**: Xcode Organizer

## 🚨 Troubleshooting

### Android Build Fails
```bash
# Clean and rebuild
flutter clean
cd android && ./gradlew clean
cd .. && flutter build apk --release

# Check dependencies
cd android && ./gradlew app:dependencies
```

### iOS Build Fails
```bash
# Clean Flutter
flutter clean

# Clean Xcode
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Clean DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData

# Rebuild
flutter build ios --release
```

### Keystore Issues
```bash
# List keystore contents
keytool -list -v -keystore android/upload-keystore.jks

# Verify signing
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

## 📚 Detailed Documentation

- **Android Keystore**: [ANDROID_KEYSTORE_SETUP.md](./ANDROID_KEYSTORE_SETUP.md)
- **iOS Code Signing**: [IOS_CODE_SIGNING_SETUP.md](./IOS_CODE_SIGNING_SETUP.md)
- **Full Configuration**: [PLATFORM_CONFIGURATION.md](./PLATFORM_CONFIGURATION.md)

## ✅ Pre-Release Checklist

### Before Building
- [ ] Update version in `pubspec.yaml`
- [ ] Run `flutter analyze` (no errors)
- [ ] Run `flutter test` (all pass)
- [ ] Test on physical devices
- [ ] Update release notes

### Android
- [ ] Keystore configured
- [ ] `google-services.json` present
- [ ] ProGuard rules tested
- [ ] Signed with release key

### iOS
- [ ] Code signing configured
- [ ] `GoogleService-Info.plist` present
- [ ] Certificates valid
- [ ] Provisioning profiles valid

## 🔒 Security Reminders

### Never Commit
- ❌ `android/key.properties`
- ❌ `android/*.jks`
- ❌ `android/google-services.json` (if contains sensitive data)
- ❌ `ios/GoogleService-Info.plist` (if contains sensitive data)
- ❌ `ios/*.mobileprovision`
- ❌ `ios/*.p12`

### Always Backup
- ✅ Android keystore (`upload-keystore.jks`)
- ✅ Keystore passwords
- ✅ iOS certificates
- ✅ Provisioning profiles

## 🆘 Getting Help

1. **Check documentation** in this directory
2. **Flutter docs**: https://docs.flutter.dev
3. **Android docs**: https://developer.android.com
4. **iOS docs**: https://developer.apple.com
5. **Stack Overflow**: Tag with `flutter`, `android`, or `ios`

## 📞 Support Contacts

- **Flutter Issues**: https://github.com/flutter/flutter/issues
- **Firebase Support**: https://firebase.google.com/support
- **Apple Developer**: https://developer.apple.com/support
- **Google Play Support**: https://support.google.com/googleplay/android-developer

---

**Quick Tip**: Bookmark this page for fast reference during development! 🚀
