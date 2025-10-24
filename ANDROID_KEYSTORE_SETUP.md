# Android Keystore Setup Guide

This guide explains how to create and configure an Android keystore for release builds of the DishaAjyoti app.

## Prerequisites

- Java Development Kit (JDK) installed
- Android Studio or Flutter SDK installed

## Step 1: Create a Keystore

Run the following command in your terminal from the `android` directory:

```bash
cd android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias dishaajyoti-release
```

You will be prompted to enter:
- **Keystore password**: Choose a strong password (remember this!)
- **Key password**: Choose a strong password (can be same as keystore password)
- **First and last name**: Your name or organization name
- **Organizational unit**: Your department or team name
- **Organization**: Your company name
- **City or Locality**: Your city
- **State or Province**: Your state
- **Country code**: Your two-letter country code (e.g., IN for India)

**IMPORTANT**: Store these passwords securely! You'll need them for every release build.

## Step 2: Create key.properties File

1. Copy the template file:
   ```bash
   cp key.properties.template key.properties
   ```

2. Edit `key.properties` and fill in your actual values:
   ```properties
   storePassword=YOUR_ACTUAL_KEYSTORE_PASSWORD
   keyPassword=YOUR_ACTUAL_KEY_PASSWORD
   keyAlias=dishaajyoti-release
   storeFile=../upload-keystore.jks
   ```

## Step 3: Secure Your Keystore

1. **Add to .gitignore**: Ensure these files are in your `.gitignore`:
   ```
   android/key.properties
   android/upload-keystore.jks
   android/*.jks
   ```

2. **Backup your keystore**: Store `upload-keystore.jks` and passwords in a secure location:
   - Password manager (recommended)
   - Encrypted cloud storage
   - Secure company vault

3. **Never commit**: Never commit the keystore or key.properties to version control!

## Step 4: Verify Configuration

1. Build a release APK:
   ```bash
   flutter build apk --release
   ```

2. Build a release App Bundle (for Play Store):
   ```bash
   flutter build appbundle --release
   ```

3. Verify the signing:
   ```bash
   keytool -list -v -keystore android/upload-keystore.jks -alias dishaajyoti-release
   ```

## Step 5: Play Store Upload

When uploading to Google Play Store:

1. **First-time upload**: Use the `upload-keystore.jks` to sign your app
2. **Play App Signing**: Enable Google Play App Signing for additional security
3. **Upload key certificate**: Google Play will ask for your upload certificate

To get your upload certificate:
```bash
keytool -export -rfc -keystore android/upload-keystore.jks -alias dishaajyoti-release -file upload_certificate.pem
```

## Troubleshooting

### "Keystore file not found"
- Ensure `upload-keystore.jks` is in the `android` directory
- Check the `storeFile` path in `key.properties`

### "Wrong password"
- Verify passwords in `key.properties` match what you entered during keystore creation
- Passwords are case-sensitive

### "Key alias not found"
- Ensure the `keyAlias` in `key.properties` matches the alias used during keystore creation
- List all aliases: `keytool -list -keystore android/upload-keystore.jks`

## Security Best Practices

1. **Use strong passwords**: Minimum 12 characters with mixed case, numbers, and symbols
2. **Separate passwords**: Use different passwords for keystore and key
3. **Regular backups**: Keep multiple secure backups of your keystore
4. **Access control**: Limit who has access to the keystore and passwords
5. **Rotation policy**: Consider rotating keys every few years (requires Play Store migration)

## Lost Keystore Recovery

If you lose your keystore:
- **Google Play**: Contact Google Play support for key reset (one-time only)
- **Other stores**: You may need to publish as a new app
- **Prevention**: Always maintain secure backups!

## Additional Resources

- [Android App Signing Documentation](https://developer.android.com/studio/publish/app-signing)
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)
