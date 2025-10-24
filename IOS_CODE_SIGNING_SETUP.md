# iOS Code Signing Setup Guide

This guide explains how to configure code signing for iOS builds of the DishaAjyoti app.

## Prerequisites

- macOS computer
- Xcode installed (latest stable version)
- Apple Developer Account ($99/year for App Store distribution)
- Flutter SDK installed

## Step 1: Apple Developer Account Setup

1. **Enroll in Apple Developer Program**:
   - Visit [developer.apple.com](https://developer.apple.com)
   - Sign in with your Apple ID
   - Enroll in the Apple Developer Program ($99/year)
   - Complete the enrollment process (may take 24-48 hours)

2. **Verify your account**:
   - Log in to [App Store Connect](https://appstoreconnect.apple.com)
   - Ensure your account is active

## Step 2: Configure Bundle Identifier

1. **Register App ID**:
   - Go to [Apple Developer Portal](https://developer.apple.com/account)
   - Navigate to Certificates, Identifiers & Profiles
   - Click on Identifiers → App IDs
   - Click the "+" button to create a new App ID
   - Select "App" and click Continue
   - Fill in the details:
     - Description: DishaAjyoti
     - Bundle ID: `com.dishaajyoti.app` (Explicit)
   - Select capabilities:
     - ✓ Push Notifications
     - ✓ Sign in with Apple (optional)
     - ✓ Associated Domains (for deep linking)
   - Click Continue and Register

## Step 3: Create Certificates

### Development Certificate

1. Open Xcode
2. Go to Xcode → Preferences → Accounts
3. Click "+" to add your Apple ID
4. Select your team
5. Click "Manage Certificates"
6. Click "+" and select "Apple Development"
7. Certificate will be created automatically

### Distribution Certificate

1. In Xcode Preferences → Accounts → Manage Certificates
2. Click "+" and select "Apple Distribution"
3. Certificate will be created automatically

**Alternative (Manual Method)**:
```bash
# Generate Certificate Signing Request (CSR)
# Open Keychain Access → Certificate Assistant → Request a Certificate from a Certificate Authority
# Save the CSR file

# Then upload CSR to Apple Developer Portal:
# Certificates, Identifiers & Profiles → Certificates → "+" button
# Select "iOS Distribution" → Upload CSR → Download certificate
# Double-click downloaded certificate to install in Keychain
```

## Step 4: Create Provisioning Profiles

### Development Provisioning Profile

1. Go to Apple Developer Portal
2. Navigate to Profiles
3. Click "+" to create new profile
4. Select "iOS App Development"
5. Select your App ID: `com.dishaajyoti.app`
6. Select your development certificate
7. Select test devices (register devices first if needed)
8. Name it: "DishaAjyoti Development"
9. Download and double-click to install

### Distribution Provisioning Profile (App Store)

1. In Profiles, click "+" to create new profile
2. Select "App Store"
3. Select your App ID: `com.dishaajyoti.app`
4. Select your distribution certificate
5. Name it: "DishaAjyoti App Store"
6. Download and double-click to install

## Step 5: Configure Xcode Project

1. **Open iOS project in Xcode**:
   ```bash
   cd Dishaajyoti/ios
   open Runner.xcworkspace
   ```

2. **Select Runner target** in the project navigator

3. **Configure Signing & Capabilities**:
   - Select your Team from the dropdown
   - Bundle Identifier: `com.dishaajyoti.app`
   - Ensure "Automatically manage signing" is checked for Development
   - For Release builds, you may want to manually manage signing

4. **Add Capabilities** (if needed):
   - Click "+ Capability"
   - Add:
     - Push Notifications
     - Background Modes (Remote notifications)
     - Sign in with Apple (optional)
     - Associated Domains (for deep linking)

5. **Configure Build Settings**:
   - Select Runner target → Build Settings
   - Search for "Code Signing Identity"
   - Debug: iOS Developer
   - Release: iOS Distribution
   - Search for "Development Team"
   - Set your Team ID for all configurations

## Step 6: Update Info.plist

The Info.plist has already been configured with required permissions. Verify these entries exist:

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSLocationWhenInUseUsageDescription`
- `NSFaceIDUsageDescription`
- `UIBackgroundModes` (remote-notification)

## Step 7: Build and Test

### Development Build

1. **Connect your iOS device**
2. **Select your device** in Xcode
3. **Build and run**:
   ```bash
   flutter run --release
   ```

### Archive for App Store

1. **In Xcode**:
   - Product → Scheme → Edit Scheme
   - Set Build Configuration to "Release"
   - Product → Archive
   - Wait for archive to complete
   - Click "Distribute App"
   - Select "App Store Connect"
   - Follow the wizard

2. **Using Flutter CLI**:
   ```bash
   flutter build ipa --release
   ```
   
   The IPA will be in: `build/ios/ipa/dishaajyoti.ipa`

## Step 8: Upload to App Store Connect

### Method 1: Xcode Organizer

1. Window → Organizer
2. Select your archive
3. Click "Distribute App"
4. Select "App Store Connect"
5. Select "Upload"
6. Follow the prompts

### Method 2: Transporter App

1. Download Transporter from Mac App Store
2. Open Transporter
3. Drag and drop your IPA file
4. Click "Deliver"

### Method 3: Command Line

```bash
xcrun altool --upload-app --type ios --file build/ios/ipa/dishaajyoti.ipa \
  --username "your-apple-id@email.com" \
  --password "app-specific-password"
```

## Step 9: App Store Connect Configuration

1. **Create App**:
   - Log in to [App Store Connect](https://appstoreconnect.apple.com)
   - Click "My Apps" → "+" → "New App"
   - Platform: iOS
   - Name: DishaAjyoti
   - Primary Language: English
   - Bundle ID: com.dishaajyoti.app
   - SKU: dishaajyoti-ios

2. **Fill in App Information**:
   - App Privacy: Configure privacy details
   - Pricing: Set pricing tier
   - App Information: Description, keywords, screenshots
   - Age Rating: Complete questionnaire

3. **Submit for Review**:
   - Select your uploaded build
   - Complete all required fields
   - Submit for review

## Troubleshooting

### "No signing certificate found"
- Ensure you've created certificates in Step 3
- Check Xcode → Preferences → Accounts → Download Manual Profiles

### "Provisioning profile doesn't match"
- Verify Bundle ID matches exactly: `com.dishaajyoti.app`
- Regenerate provisioning profile if needed
- Download and install the new profile

### "Code signing entitlements error"
- Check that capabilities in Xcode match those in App ID
- Clean build folder: Product → Clean Build Folder
- Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### "Archive not showing in Organizer"
- Ensure you selected "Generic iOS Device" before archiving
- Check that scheme is set to "Release"
- Verify code signing is configured correctly

### "Upload failed"
- Check that app version/build number is unique
- Ensure all required metadata is filled in App Store Connect
- Verify your Apple ID has proper permissions

## Fastlane Automation (Optional)

For automated builds and uploads, consider using Fastlane:

```bash
# Install Fastlane
sudo gem install fastlane

# Initialize Fastlane
cd ios
fastlane init

# Configure Fastfile for automated builds
```

## Security Best Practices

1. **Protect your certificates**: Store in Keychain with strong password
2. **Use App-Specific Passwords**: For command-line uploads
3. **Enable Two-Factor Authentication**: On your Apple ID
4. **Limit team access**: Only give necessary permissions
5. **Regular certificate renewal**: Certificates expire after 1 year
6. **Backup certificates**: Export and store securely

## Certificate Expiration

- **Development certificates**: Valid for 1 year
- **Distribution certificates**: Valid for 1 year
- **Provisioning profiles**: Valid for 1 year

Set reminders to renew before expiration!

## Additional Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Xcode Help](https://help.apple.com/xcode/)
- [Fastlane Documentation](https://docs.fastlane.tools/)

## Support

If you encounter issues:
1. Check Apple Developer Forums
2. Review Flutter iOS deployment docs
3. Contact Apple Developer Support
4. Check Xcode console for detailed error messages
