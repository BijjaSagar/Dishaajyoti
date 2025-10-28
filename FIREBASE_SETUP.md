# Firebase Setup Documentation

## Project Information

- **Project ID**: `vagdishaajyoti`
- **Project Name**: vagdishaajyoti
- **Firebase Console**: https://console.firebase.google.com/project/vagdishaajyoti/overview

## Enabled Services

### 1. Firebase Authentication
- **Status**: ✅ Enabled
- **Supported Methods**: 
  - Email/Password
  - Phone Number (OTP)
  - Google Sign-In (to be configured)
  - Apple Sign-In (to be configured)

### 2. Cloud Firestore
- **Status**: ✅ Enabled
- **Location**: nam5 (North America)
- **Rules File**: `firestore.rules`
- **Indexes File**: `firestore.indexes.json`
- **Offline Persistence**: Enabled

### 3. Cloud Storage
- **Status**: ✅ Enabled
- **Rules File**: `storage.rules`
- **Buckets**:
  - `/uploads/{userId}/` - User uploaded files (palmistry images, etc.)
  - `/reports/{userId}/` - Generated reports (PDFs, charts)
  - `/kundalis/{userId}/` - Kundali files
  - `/palmistry/{userId}/` - Palmistry analysis results
  - `/numerology/{userId}/` - Numerology reports

### 4. Cloud Functions
- **Status**: ✅ Enabled
- **Language**: TypeScript
- **Location**: `functions/`
- **Runtime**: Node.js 22

### 5. Firebase Data Connect
- **Status**: ✅ Enabled
- **Location**: us-east4
- **Service Name**: dishaajyoti
- **Schema**: `dataconnect/schema/schema.gql`

## Configuration Files

### Android
- **File**: `android/app/google-services.json`
- **Status**: ✅ Present
- **Package Name**: com.dishaajyoti.app

### iOS
- **File**: `ios/Runner/GoogleService-Info.plist`
- **Status**: ✅ Present
- **Bundle ID**: com.dishaajyoti.app

### Flutter
- **Firebase Core**: ✅ Initialized in `lib/main.dart`
- **Service Manager**: ✅ Created at `lib/services/firebase/firebase_service_manager.dart`

## Firebase CLI Setup

### Installation
```bash
npm install -g firebase-tools
```

### Login
```bash
firebase login
```

### Current Project
```bash
firebase use vagdishaajyoti
```

## Deployment Commands

### Deploy All
```bash
firebase deploy
```

### Deploy Specific Services
```bash
# Deploy Firestore rules and indexes
firebase deploy --only firestore

# Deploy Cloud Functions
firebase deploy --only functions

# Deploy Storage rules
firebase deploy --only storage
```

## Local Development

### Start Emulators
```bash
firebase emulators:start
```

### Available Emulators
- Authentication: http://localhost:9099
- Firestore: http://localhost:8080
- Cloud Functions: http://localhost:5001
- Cloud Storage: http://localhost:9199

## Security Rules

### Firestore Rules
- Users can only read/write their own data
- Cloud Functions have admin access
- See `firestore.rules` for details

### Storage Rules
- Users can only access their own files
- 10MB limit for image uploads
- 50MB limit for PDF uploads
- See `storage.rules` for details

## Next Steps

1. ✅ Firebase project created
2. ✅ Services enabled (Auth, Firestore, Functions, Storage)
3. ✅ Configuration files added
4. ✅ Firebase SDK initialized in Flutter app
5. ✅ Firebase CLI set up
6. ⏳ Configure Google Sign-In (Task 4.2)
7. ⏳ Configure Apple Sign-In (Task 4.3)
8. ⏳ Implement authentication service (Task 4.1)
9. ⏳ Deploy security rules (Task 15)
10. ⏳ Implement Cloud Functions (Tasks 9-11)

## Useful Links

- [Firebase Console](https://console.firebase.google.com/project/vagdishaajyoti/overview)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Cloud Functions Documentation](https://firebase.google.com/docs/functions)

## Troubleshooting

### Issue: Firebase not initialized
**Solution**: Ensure `FirebaseServiceManager.instance.initialize()` is called in `main()` before `runApp()`

### Issue: Platform-specific configuration missing
**Solution**: 
- Android: Ensure `google-services.json` is in `android/app/`
- iOS: Ensure `GoogleService-Info.plist` is in `ios/Runner/`

### Issue: Emulator connection failed
**Solution**: Check if emulators are running with `firebase emulators:start`

## Environment Variables

For Cloud Functions, set environment variables:
```bash
firebase functions:config:set someservice.key="THE API KEY"
```

## Billing

- Current Plan: Spark (Free)
- To enable advanced features, upgrade to Blaze (Pay as you go)
- Billing Console: https://console.firebase.google.com/project/vagdishaajyoti/usage/details
