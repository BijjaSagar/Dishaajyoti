# Cloud Functions Deployment Guide

This guide covers the deployment process for DishaAjyoti Cloud Functions.

## Prerequisites

1. **Firebase CLI**: Install globally
   ```bash
   npm install -g firebase-tools
   ```

2. **Firebase Login**: Authenticate with Firebase
   ```bash
   firebase login
   ```

3. **Node.js**: Version 22 or higher (as specified in package.json)

## Environment Variables

Cloud Functions require the following environment variables for payment processing:

### Razorpay Configuration

```bash
firebase functions:config:set razorpay.key_id="your_razorpay_key_id"
firebase functions:config:set razorpay.key_secret="your_razorpay_key_secret"
```

### Stripe Configuration (Optional)

```bash
firebase functions:config:set stripe.secret_key="your_stripe_secret_key"
firebase functions:config:set stripe.webhook_secret="your_stripe_webhook_secret"
```

### View Current Configuration

```bash
firebase functions:config:get
```

### For Local Development

Create a `.env.local` file (copy from `.env.example`):
```bash
cp .env.example .env.local
```

Then edit `.env.local` with your actual keys.

## Deployment Methods

### Method 1: Using the Deployment Script (Recommended)

```bash
./deploy.sh
```

This script will:
1. Run linter
2. Build TypeScript
3. Prompt for environment variable confirmation
4. Deploy all functions

### Method 2: Manual Deployment

#### Step 1: Review Code

Review all Cloud Functions code for any issues:
```bash
npm run lint
```

#### Step 2: Build TypeScript

```bash
npm run build
```

#### Step 3: Deploy Functions

Deploy all functions:
```bash
firebase deploy --only functions
```

Deploy specific function:
```bash
firebase deploy --only functions:generateKundali
```

Deploy multiple specific functions:
```bash
firebase deploy --only functions:generateKundali,functions:processPayment
```

## Deployed Functions

The following Cloud Functions will be deployed:

### HTTP Callable Functions

1. **healthCheck** (HTTP Request)
   - Simple health check endpoint
   - URL: `https://us-central1-{project-id}.cloudfunctions.net/healthCheck`

2. **generateKundali** (HTTP Callable)
   - Generates Kundali reports instantly
   - Memory: 512MB
   - Timeout: 300 seconds (5 minutes)

3. **requestPalmistryAnalysis** (HTTP Callable)
   - Schedules palmistry analysis (24-hour delay)
   - Memory: 256MB
   - Timeout: 60 seconds

4. **requestNumerologyReport** (HTTP Callable)
   - Schedules numerology report (12-hour delay)
   - Memory: 256MB
   - Timeout: 60 seconds

5. **processPayment** (HTTP Callable)
   - Processes and verifies payments
   - Memory: 256MB
   - Timeout: 60 seconds

### Scheduled Functions

6. **processScheduledReports** (Scheduled)
   - Runs every hour via Cloud Scheduler
   - Processes scheduled palmistry and numerology reports

### Firestore Triggers

7. **onOrderCreated** (Firestore Trigger)
   - Triggers when new order is created
   - Auto-completes test orders

## Testing Deployed Functions

### Test Health Check

```bash
curl https://us-central1-vagdishaajyoti.cloudfunctions.net/healthCheck
```

Expected response:
```json
{
  "status": "ok",
  "message": "DishaAjyoti Cloud Functions are running",
  "timestamp": "2025-01-XX...",
  "version": "1.0.0"
}
```

### Test from Flutter App

The Flutter app should call these functions using the Firebase Functions SDK:

```dart
final functions = FirebaseFunctions.instance;

// Call generateKundali
final result = await functions.httpsCallable('generateKundali').call({
  'name': 'Test User',
  'dateOfBirth': '1990-01-01',
  'timeOfBirth': '10:30',
  'placeOfBirth': 'Mumbai',
  'latitude': 19.0760,
  'longitude': 72.8777,
  'chartStyle': 'northIndian',
});
```

## Monitoring

### View Function Logs

Real-time logs:
```bash
firebase functions:log
```

Logs for specific function:
```bash
firebase functions:log --only generateKundali
```

Last 100 log entries:
```bash
firebase functions:log --limit 100
```

### Firebase Console

Monitor functions in the Firebase Console:
1. Go to https://console.firebase.google.com
2. Select your project (vagdishaajyoti)
3. Navigate to Functions section
4. View metrics, logs, and errors

## Troubleshooting

### Build Errors

If build fails:
```bash
# Clean build artifacts
rm -rf lib/

# Reinstall dependencies
npm install

# Try building again
npm run build
```

### Deployment Errors

**Error: "Billing account not configured"**
- Solution: Enable billing in Firebase Console

**Error: "Insufficient permissions"**
- Solution: Ensure you have Owner or Editor role in Firebase project

**Error: "Function deployment timeout"**
- Solution: Try deploying functions one at a time

### Runtime Errors

**Error: "Payment verification failed"**
- Check if environment variables are set correctly
- Verify Razorpay/Stripe credentials

**Error: "Storage upload failed"**
- Check Storage rules in Firebase Console
- Verify bucket permissions

**Error: "Firestore permission denied"**
- Check Firestore security rules
- Ensure Cloud Functions have admin access

## Rollback

If deployment causes issues, rollback to previous version:

```bash
# List function versions
firebase functions:list

# Rollback specific function (not directly supported)
# Instead, redeploy previous code version
git checkout <previous-commit>
firebase deploy --only functions
```

## Cost Optimization

### Monitor Usage

Check function invocations and costs:
1. Firebase Console → Functions → Usage tab
2. Set up billing alerts

### Optimize Functions

- Use appropriate memory allocation (256MB for simple, 512MB for complex)
- Set reasonable timeouts
- Implement caching where possible
- Use Cloud Scheduler efficiently (hourly instead of every minute)

### Free Tier Limits

- 2M invocations per month
- 400K GB-seconds per month
- 200K CPU-seconds per month

## Security

### Security Rules

Ensure Firestore and Storage security rules are deployed:
```bash
firebase deploy --only firestore:rules,storage:rules
```

### API Keys

- Never commit API keys to version control
- Use Firebase Functions config for secrets
- Rotate keys regularly

### CORS

If calling functions from web:
```typescript
import { onRequest } from "firebase-functions/v2/https";

export const myFunction = onRequest({
  cors: true,  // Enable CORS
}, async (request, response) => {
  // Function code
});
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy Cloud Functions

on:
  push:
    branches:
      - main
    paths:
      - 'functions/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '22'
      - name: Install dependencies
        run: cd functions && npm install
      - name: Build
        run: cd functions && npm run build
      - name: Deploy to Firebase
        uses: w9jds/firebase-action@master
        with:
          args: deploy --only functions
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

## Support

For issues or questions:
1. Check Firebase Console logs
2. Review function code in `src/` directory
3. Check Firebase documentation: https://firebase.google.com/docs/functions
4. Contact development team

## Changelog

### Version 1.0.0 (Current)
- Initial deployment
- Health check function
- Kundali generation (instant)
- Palmistry analysis (24h delay)
- Numerology report (12h delay)
- Payment processing
- Scheduled report processing
- Order creation trigger
