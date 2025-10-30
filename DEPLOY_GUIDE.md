# Firebase Deployment Guide

## ✅ Dependencies Installed

All npm dependencies in the `functions` folder have been successfully installed and built.

## 🔐 Authentication Required

To deploy to Firebase, you need to authenticate first. Follow these steps:

### Step 1: Login to Firebase

```bash
firebase login
```

This will open a browser window for you to authenticate with your Google account.

### Step 2: Verify Project

```bash
firebase use dishajyoti
```

This ensures you're deploying to the correct project (`vagdishaajyoti`).

### Step 3: Deploy Everything

```bash
# Deploy all services at once
firebase deploy

# OR deploy individually:

# Deploy Cloud Functions only
firebase deploy --only functions

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage

# Deploy Firestore indexes
firebase deploy --only firestore:indexes
```

## 📋 Deployment Checklist

- [x] Install npm dependencies (`functions/node_modules`)
- [x] Build TypeScript functions (`functions/lib/`)
- [ ] Login to Firebase CLI (`firebase login`)
- [ ] Deploy Firestore security rules
- [ ] Deploy Storage security rules
- [ ] Deploy Firestore indexes
- [ ] Deploy Cloud Functions:
  - `healthCheck` - Health check endpoint
  - `generateKundali` - Instant Kundali generation
  - `requestPalmistryAnalysis` - Palmistry (24h delay)
  - `requestNumerologyReport` - Numerology (12h delay)
  - `processPayment` - Payment processing
  - `processScheduledReports` - Scheduled report processing
  - `onOrderCreated` - Order creation trigger

## 🚀 Quick Deploy Command

After logging in, run:

```bash
cd /home/user/Dishaajyoti
firebase deploy --only firestore:rules,storage,functions
```

## 🔍 Verify Deployment

After deployment, test the health check endpoint:

```bash
curl https://us-central1-vagdishaajyoti.cloudfunctions.net/healthCheck
```

Expected response:
```json
{
  "status": "ok",
  "message": "DishaAjyoti Cloud Functions are running",
  "timestamp": "2025-...",
  "version": "1.0.0"
}
```

## ⚠️ Important Notes

1. **First-time deployment may take 5-10 minutes**
2. **Function cold starts may take 10-20 seconds** for the first invocation
3. **Maximum concurrent instances set to 10** for cost control
4. **Memory allocation**: 256MB-512MB depending on function
5. **Timeout**: Most functions have 60-300 second timeout

## 📊 Monitor Deployment

After deployment, monitor your functions:

```bash
# View function logs
firebase functions:log

# View specific function logs
firebase functions:log --only generateKundali
```

Or visit Firebase Console:
- Functions: https://console.firebase.google.com/project/vagdishaajyoti/functions
- Firestore: https://console.firebase.google.com/project/vagdishaajyoti/firestore
- Storage: https://console.firebase.google.com/project/vagdishaajyoti/storage

##Issues Found and Fixed

### ✅ Fixed: Missing Dependencies
All npm packages have been installed successfully.

### ✅ Fixed: TypeScript Compilation
Functions have been compiled to JavaScript successfully.

### ⏳ Pending: Firebase Authentication
You need to run `firebase login` to authenticate before deployment.

### 🐛 Identified: Kundali Display Issue
The Kundali is generating successfully but not showing in the app. This is being fixed in the code.
