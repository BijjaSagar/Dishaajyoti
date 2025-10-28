# Pre-Deployment Checklist

Complete this checklist before deploying Cloud Functions to production.

## ✅ Code Review

- [x] All Cloud Functions code reviewed
- [x] TypeScript compilation successful
- [x] No critical errors in code
- [ ] Linting warnings reviewed (style issues only, not blocking)

## ✅ Environment Configuration

- [x] `.env.example` file created with all required variables
- [x] `.env` file created (with placeholder values)
- [ ] **ACTION REQUIRED**: Update `.env` with actual Razorpay credentials
- [ ] **ACTION REQUIRED**: Update `.env` with actual Stripe credentials (if using)
- [x] `.gitignore` updated to exclude `.env` files

### Required Environment Variables

```bash
# Razorpay (Required for payment processing)
RAZORPAY_KEY_ID=your_actual_key_id
RAZORPAY_KEY_SECRET=your_actual_secret

# Stripe (Optional - only if using Stripe)
STRIPE_SECRET_KEY=your_actual_key
STRIPE_WEBHOOK_SECRET=your_actual_secret
```

## ✅ Firebase Project Setup

- [x] Firebase project exists: `vagdishaajyoti`
- [x] Firebase CLI installed and authenticated
- [x] Correct project selected
- [x] Firestore Database enabled
- [x] Cloud Storage enabled
- [x] Firebase Authentication enabled

## ✅ Build and Compilation

- [x] Dependencies installed (`npm install`)
- [x] TypeScript builds successfully (`npm run build`)
- [x] No compilation errors
- [x] Output directory `lib/` contains compiled JavaScript

## ✅ Functions to Deploy

The following functions will be deployed:

### HTTP Callable Functions
1. ✅ `healthCheck` - Health check endpoint
2. ✅ `generateKundali` - Instant Kundali generation (512MB, 5min timeout)
3. ✅ `requestPalmistryAnalysis` - Schedule palmistry (24h delay)
4. ✅ `requestNumerologyReport` - Schedule numerology (12h delay)
5. ✅ `processPayment` - Payment processing and verification

### Scheduled Functions
6. ✅ `processScheduledReports` - Hourly scheduled report processing

### Firestore Triggers
7. ✅ `onOrderCreated` - Auto-process test orders

## ✅ Security Rules

- [x] Firestore security rules exist (`firestore.rules`)
- [x] Storage security rules exist (`storage.rules`)
- [ ] **RECOMMENDED**: Deploy security rules: `firebase deploy --only firestore:rules,storage:rules`

## ✅ Testing Plan

After deployment, test the following:

### 1. Health Check
```bash
curl https://us-central1-vagdishaajyoti.cloudfunctions.net/healthCheck
```

### 2. From Flutter App
- [ ] Test user authentication
- [ ] Test Kundali generation
- [ ] Test Palmistry request (verify 24h scheduling)
- [ ] Test Numerology request (verify 12h scheduling)
- [ ] Test payment processing (test mode)

### 3. Monitor Logs
```bash
firebase functions:log --limit 50
```

## ✅ Monitoring Setup

- [ ] Set up billing alerts in Firebase Console
- [ ] Configure error notifications
- [ ] Set up performance monitoring
- [ ] Review function quotas and limits

## ✅ Rollback Plan

If deployment fails or causes issues:

1. Check function logs: `firebase functions:log`
2. Identify the problematic function
3. Rollback by redeploying previous version:
   ```bash
   git checkout <previous-commit>
   firebase deploy --only functions
   ```

## ✅ Cost Considerations

### Free Tier Limits
- 2M invocations/month
- 400K GB-seconds/month
- 200K CPU-seconds/month

### Expected Usage (1000 users/month)
- Estimated invocations: ~50K/month
- Estimated cost: $0-5/month (within free tier)

## 🚀 Deployment Commands

### Option 1: Using Deployment Script
```bash
./deploy.sh
```

### Option 2: Manual Deployment
```bash
# 1. Build
npm run build

# 2. Deploy all functions
firebase deploy --only functions

# 3. Deploy specific function
firebase deploy --only functions:generateKundali
```

## ⚠️ Important Notes

1. **Environment Variables**: The `.env` file currently contains placeholder values. Update with actual credentials before production deployment.

2. **Payment Gateway**: Functions will work but payment verification will fail without proper Razorpay/Stripe credentials.

3. **Testing Mode**: Test orders will auto-complete even without payment credentials (see `onOrderCreated` trigger).

4. **Linting Warnings**: There are style-related linting warnings (line length, JSDoc comments). These don't affect functionality and can be addressed later.

5. **First Deployment**: First deployment may take 5-10 minutes. Subsequent deployments are faster.

## ✅ Post-Deployment Verification

After successful deployment:

- [ ] All functions show "Active" status in Firebase Console
- [ ] Health check endpoint responds correctly
- [ ] Function logs show no errors
- [ ] Test Kundali generation from Flutter app
- [ ] Verify Firestore documents are created correctly
- [ ] Verify Cloud Storage files are uploaded correctly
- [ ] Test payment flow (test mode)

## 📝 Deployment Log

Record deployment details:

- **Date**: _________________
- **Deployed By**: _________________
- **Git Commit**: _________________
- **Functions Deployed**: _________________
- **Issues Encountered**: _________________
- **Resolution**: _________________

## 🆘 Support

If you encounter issues:

1. Check `DEPLOYMENT.md` for detailed troubleshooting
2. Review Firebase Console logs
3. Check function configuration in Firebase Console
4. Verify environment variables are set correctly
5. Contact development team

---

**Status**: Ready for deployment (pending environment variable configuration)
