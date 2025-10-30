# Firebase Storage Security Rules - Deployment and Testing

## Overview

This document describes the Firebase Storage security rules implementation for DishaAjyoti, including deployment procedures and testing guidelines.

## Requirements Addressed

- **Requirement 11.4**: Users can read and write their own uploaded files, and read their own generated reports
- **Requirement 11.5**: File size limit of 10MB for user uploads
- **Requirement 11.6**: Access restrictions are properly enforced

## Storage Rules Structure

### File Paths

```
storage/
├── uploads/{userId}/          # User uploads (read/write own, 10MB limit)
├── reports/{userId}/          # Generated reports (read own, no write)
├── kundalis/{userId}/         # Kundali charts and PDFs (read own, no write)
├── palmistry/{userId}/        # Palmistry analysis (read own, no write)
├── numerology/{userId}/       # Numerology reports (read own, no write)
├── compatibility/{userId}/    # Compatibility reports (read own, no write)
└── panchang/{userId}/         # Panchang reports (read own, no write)
```

### Security Rules Summary

1. **User Uploads** (`/uploads/{userId}/`)
   - ✅ Authenticated users can read their own files
   - ✅ Authenticated users can write their own files
   - ✅ Authenticated users can delete their own files
   - ✅ File size limited to 10MB
   - ❌ Cannot access other users' files

2. **Generated Reports** (all other paths)
   - ✅ Authenticated users can read their own reports
   - ❌ Users cannot write (only Cloud Functions)
   - ❌ Users cannot delete (only Cloud Functions)
   - ❌ Cannot access other users' reports

## Deployment

### Prerequisites

1. Firebase CLI installed: `npm install -g firebase-tools`
2. Authenticated with Firebase: `firebase login`
3. Project configured: Check `.firebaserc` for project ID

### Deploy Storage Rules

```bash
# Navigate to project directory
cd Dishaajyoti

# Deploy only storage rules
firebase deploy --only storage

# Deploy storage rules to specific project
firebase deploy --only storage --project vagdishaajyoti
```

### Verify Deployment

After deployment, verify in Firebase Console:
1. Go to https://console.firebase.google.com/project/vagdishaajyoti/storage
2. Click on "Rules" tab
3. Verify the rules match the content of `storage.rules`

## Testing

### Manual Testing

#### Test 1: Upload File as Authenticated User

```dart
// Should succeed
final ref = FirebaseStorage.instance.ref('uploads/${userId}/test.jpg');
await ref.putFile(imageFile);
```

#### Test 2: Upload File Exceeding 10MB

```dart
// Should fail with permission denied
final largeFile = File('large_file.jpg'); // > 10MB
final ref = FirebaseStorage.instance.ref('uploads/${userId}/large.jpg');
await ref.putFile(largeFile); // Throws FirebaseException
```

#### Test 3: Read Own Report

```dart
// Should succeed
final ref = FirebaseStorage.instance.ref('reports/${userId}/report.pdf');
final url = await ref.getDownloadURL();
```

#### Test 4: Write to Reports Folder

```dart
// Should fail with permission denied
final ref = FirebaseStorage.instance.ref('reports/${userId}/fake.pdf');
await ref.putData(data); // Throws FirebaseException
```

#### Test 5: Access Another User's File

```dart
// Should fail with permission denied
final ref = FirebaseStorage.instance.ref('uploads/other_user_id/file.jpg');
await ref.getDownloadURL(); // Throws FirebaseException
```

### Automated Testing

Run the automated test suite:

```bash
cd Dishaajyoti
flutter test test/storage_rules_test.dart
```

**Note**: Automated tests require either:
- Firebase Emulator Suite running locally
- A test Firebase project with test data

### Using Firebase Emulator

For local testing without affecting production:

```bash
# Install emulators
firebase init emulators

# Start storage emulator
firebase emulators:start --only storage

# Run tests against emulator
flutter test test/storage_rules_test.dart
```

## Common Issues and Solutions

### Issue 1: Permission Denied on Upload

**Symptom**: `FirebaseException: [firebase_storage/unauthorized]`

**Solutions**:
- Verify user is authenticated: `FirebaseAuth.instance.currentUser != null`
- Check file path matches pattern: `uploads/{userId}/...`
- Verify userId in path matches authenticated user's UID
- Check file size is under 10MB

### Issue 2: Cannot Read Generated Report

**Symptom**: `FirebaseException: [firebase_storage/object-not-found]` or `unauthorized`

**Solutions**:
- Verify file exists in Storage Console
- Check userId in path matches authenticated user's UID
- Ensure Cloud Function successfully uploaded the file
- Verify download URL hasn't expired

### Issue 3: Rules Not Taking Effect

**Symptom**: Old rules still active after deployment

**Solutions**:
- Wait 1-2 minutes for rules to propagate
- Clear app cache and restart
- Verify deployment succeeded: `firebase deploy --only storage`
- Check Firebase Console for active rules

### Issue 4: File Size Limit Not Working

**Symptom**: Large files (>10MB) upload successfully

**Solutions**:
- Verify rules deployed correctly
- Check file path - size limit only applies to `/uploads/` path
- Test with actual file, not mock data
- Verify `request.resource.size` in rules

## Security Best Practices

1. **Never expose service account credentials** in client code
2. **Always validate file types** on the client before upload
3. **Implement client-side size checks** for better UX
4. **Use signed URLs** with expiration for sensitive files
5. **Monitor Storage usage** in Firebase Console
6. **Set up billing alerts** to prevent unexpected costs
7. **Regularly audit access logs** for suspicious activity

## File Size Limits

| Path | Read | Write | Delete | Size Limit |
|------|------|-------|--------|------------|
| `/uploads/{userId}/` | Own | Own | Own | 10MB |
| `/reports/{userId}/` | Own | ❌ | ❌ | N/A |
| `/kundalis/{userId}/` | Own | ❌ | ❌ | N/A |
| `/palmistry/{userId}/` | Own | ❌ | ❌ | N/A |
| `/numerology/{userId}/` | Own | ❌ | ❌ | N/A |
| `/compatibility/{userId}/` | Own | ❌ | ❌ | N/A |
| `/panchang/{userId}/` | Own | ❌ | ❌ | N/A |

## Cloud Functions Access

Cloud Functions have full read/write access to all Storage paths through the Firebase Admin SDK, which uses a service account with elevated privileges. This allows functions to:

- Upload generated reports to any user's folder
- Delete expired or invalid files
- Move files between folders
- Update file metadata

## Monitoring and Maintenance

### Monitor Storage Usage

```bash
# View storage metrics
firebase projects:list
firebase storage:usage
```

### Check Recent Deployments

```bash
# View deployment history
firebase deploy:history
```

### Rollback Rules (if needed)

```bash
# Rollback to previous version
firebase deploy:rollback storage
```

## Next Steps

After successful deployment and testing:

1. ✅ Storage rules deployed
2. ✅ Manual testing completed
3. ✅ Automated tests passing
4. ⏭️ Proceed to Phase 8: Data Migration (Task 17)

## References

- [Firebase Storage Security Rules Documentation](https://firebase.google.com/docs/storage/security)
- [Firebase Storage Best Practices](https://firebase.google.com/docs/storage/best-practices)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)

## Deployment Status

- **Deployed**: ✅ Yes
- **Project**: vagdishaajyoti
- **Date**: 2025-10-28
- **Rules Version**: 2
- **Status**: Active and enforced
