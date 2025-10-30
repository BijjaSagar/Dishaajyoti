# Firestore Security Rules Testing Guide

## Overview

The Firestore security rules have been successfully deployed to the Firebase project. This document provides guidance on testing and verifying the security rules.

## Deployed Rules Summary

The security rules implement the following access controls:

### Users Collection
- ✅ Users can read their own profile
- ✅ Users can create their own profile during signup
- ✅ Users can update their own profile
- ❌ Users cannot delete their profile
- ✅ Users can read/write their own kundalis subcollection
- ✅ Users can read/write their own profiles subcollection

### Reports Collection
- ✅ Users can read their own reports
- ❌ Users cannot create reports (only Cloud Functions)
- ❌ Users cannot update reports (only Cloud Functions)
- ❌ Users cannot delete reports

### Orders Collection
- ✅ Users can read their own orders
- ✅ Users can create orders for themselves (with status='pending')
- ❌ Users cannot update orders (only Cloud Functions)
- ❌ Users cannot delete orders

### Service-Specific Collections
- ✅ Users can read their own kundalis, palmistry_reports, numerology_reports, matchmaking_reports
- ❌ Users cannot create/update these collections (only Cloud Functions)

### Notifications Collection
- ✅ Users can read their own notifications
- ✅ Users can update notification read status
- ✅ Users can delete their own notifications
- ❌ Users cannot create notifications (only Cloud Functions)

## Testing Methods

### Method 1: Firebase Console Rules Playground

1. Open Firebase Console: https://console.firebase.google.com/project/vagdishaajyoti/firestore
2. Navigate to Firestore Database → Rules
3. Click "Rules Playground" tab
4. Test various scenarios:

**Test Case 1: User Reading Own Profile**
```
Location: /users/test-user-123
Authenticated: Yes
Auth UID: test-user-123
Operation: get
Expected: Allow
```

**Test Case 2: User Reading Another User's Profile**
```
Location: /users/other-user-456
Authenticated: Yes
Auth UID: test-user-123
Operation: get
Expected: Deny
```

**Test Case 3: User Creating Report**
```
Location: /reports/new-report-123
Authenticated: Yes
Auth UID: test-user-123
Operation: create
Expected: Deny (only Cloud Functions can create)
```

**Test Case 4: User Creating Order**
```
Location: /orders/new-order-123
Authenticated: Yes
Auth UID: test-user-123
Operation: create
Data: { userId: "test-user-123", status: "pending", createdAt: <timestamp> }
Expected: Allow
```

### Method 2: Firebase Emulator Suite

To test with the Firebase Emulator Suite:

1. Install Firebase Emulator:
```bash
firebase setup:emulators:firestore
```

2. Start the emulator:
```bash
cd Dishaajyoti
firebase emulators:start --only firestore
```

3. The emulator will start at http://localhost:4000
4. Use the Emulator UI to test security rules

### Method 3: Integration Testing in Flutter App

Test the security rules by attempting various operations in the app:

1. **Test User Profile Access:**
   - Sign in as User A
   - Verify you can read/update your profile
   - Verify you cannot access User B's profile

2. **Test Report Access:**
   - Sign in as User A
   - Generate a report
   - Verify you can read your report
   - Verify you cannot create/update reports directly (only through Cloud Functions)

3. **Test Order Creation:**
   - Sign in as User A
   - Create an order
   - Verify the order is created successfully
   - Verify you cannot update the order status directly

4. **Test Notifications:**
   - Sign in as User A
   - Receive a notification
   - Mark it as read
   - Delete the notification
   - Verify all operations work correctly

### Method 4: Manual Testing with Firebase SDK

Create a simple test script to verify rules:

```dart
// Test reading own profile
final userId = FirebaseAuth.instance.currentUser!.uid;
final userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();
print('Can read own profile: ${userDoc.exists}');

// Test reading another user's profile (should fail)
try {
  final otherDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc('other-user-id')
      .get();
  print('ERROR: Should not be able to read other user profile');
} catch (e) {
  print('Correctly denied access to other user profile');
}

// Test creating report (should fail)
try {
  await FirebaseFirestore.instance.collection('reports').add({
    'userId': userId,
    'serviceType': 'kundali',
  });
  print('ERROR: Should not be able to create report');
} catch (e) {
  print('Correctly denied report creation');
}

// Test creating order (should succeed)
try {
  await FirebaseFirestore.instance.collection('orders').add({
    'userId': userId,
    'serviceType': 'kundali',
    'amount': 99.0,
    'status': 'pending',
    'createdAt': FieldValue.serverTimestamp(),
  });
  print('Successfully created order');
} catch (e) {
  print('ERROR: Should be able to create order: $e');
}
```

## Verification Checklist

- [x] Security rules deployed successfully
- [ ] Users can only access their own data
- [ ] Users cannot write to reports collection
- [ ] Users can create orders for themselves
- [ ] Cloud Functions can write to all collections
- [ ] Notifications can be marked as read by users
- [ ] All unauthorized access is denied

## Deployment Information

- **Deployed Date:** October 28, 2025
- **Firebase Project:** vagdishaajyoti
- **Rules File:** `Dishaajyoti/firestore.rules`
- **Deployment Command:** `firebase deploy --only firestore:rules --project vagdishaajyoti`

## Next Steps

1. Test the security rules using one of the methods above
2. Verify that all access controls work as expected
3. Monitor Firebase Console for any security rule violations
4. Update rules as needed based on testing results

## Troubleshooting

### Common Issues

**Issue: Permission Denied Errors**
- Verify the user is authenticated
- Check that the user ID matches the document owner
- Review the security rules for the specific collection

**Issue: Cloud Functions Cannot Write**
- Ensure Cloud Functions are using the Firebase Admin SDK
- Verify the service account has proper permissions

**Issue: Rules Not Taking Effect**
- Wait a few minutes for rules to propagate
- Clear app cache and restart
- Verify rules were deployed successfully

## Additional Resources

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Rules Playground Guide](https://firebase.google.com/docs/firestore/security/test-rules-emulator)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
