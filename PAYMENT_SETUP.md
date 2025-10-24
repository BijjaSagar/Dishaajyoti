# Payment Screen Setup Guide

## Overview
The payment screen has been implemented using Razorpay Flutter SDK for processing payments. This document provides setup instructions and testing guidelines.

## Features Implemented
✅ Order summary card with service details (icon, name, price)
✅ Payment method information display
✅ Razorpay SDK integration
✅ Payment success handling with dialog
✅ Payment failure handling with retry option
✅ External wallet support
✅ Loading states during payment processing
✅ Security notice for users
✅ Navigation from dashboard to payment screen

## Razorpay Configuration

### Current Setup
- **Test Key**: `rzp_test_1DP5mmOlF5G5ag` (placeholder)
- **Environment**: Test mode

### Production Setup Required
Before deploying to production, you must:

1. **Get Razorpay Account**
   - Sign up at https://razorpay.com
   - Complete KYC verification
   - Get your production API keys

2. **Update API Key**
   - Replace the test key in `lib/screens/payment_screen.dart` (line ~82)
   - Use environment variables for key management

3. **Backend Integration**
   - Implement payment order creation API
   - Implement payment verification webhook
   - Store payment records in database
   - Trigger report generation after verification

4. **Android Configuration**
   Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

5. **iOS Configuration**
   No additional configuration needed for iOS.

## Testing the Payment Screen

### Test Flow
1. Launch the app and navigate to Dashboard
2. Go to Services tab or tap "Explore Services" on Home tab
3. Select any service (Palmistry, Vedic Jyotish, or Numerology)
4. Payment screen will open showing:
   - Service icon and name
   - Price breakdown
   - Payment methods supported
   - Security notice
5. Tap "Proceed to Payment"
6. Razorpay payment sheet will open
7. Use test card details (see below)

### Razorpay Test Cards
For testing in test mode, use these card details:

**Successful Payment:**
- Card Number: `4111 1111 1111 1111`
- CVV: Any 3 digits
- Expiry: Any future date
- Name: Any name

**Failed Payment:**
- Card Number: `4000 0000 0000 0002`
- CVV: Any 3 digits
- Expiry: Any future date

**UPI Test:**
- UPI ID: `success@razorpay`

### Expected Behavior

**On Success:**
- Loading indicator appears
- Success dialog shows with:
  - Green checkmark icon
  - "Payment Successful!" message
  - Payment ID
  - "View Report Status" button
- Navigates back to dashboard

**On Failure:**
- Loading indicator appears
- Error dialog shows with:
  - Red error icon
  - Error message
  - Cancel and Retry buttons
- User can retry payment or cancel

## Payment Methods Supported
- Credit Cards (Visa, Mastercard, Amex, etc.)
- Debit Cards
- UPI (Google Pay, PhonePe, Paytm, etc.)
- Net Banking
- Digital Wallets (Paytm, PhonePe, etc.)

## Security Features
- All payment data is handled by Razorpay (PCI DSS compliant)
- No card details stored in the app
- Secure HTTPS communication
- Payment verification on backend (to be implemented)

## Next Steps
1. Implement backend payment verification API
2. Create payment records in database
3. Integrate with report generation service (Task 18)
4. Add payment history in profile section
5. Implement refund handling for failed report generation

## Files Modified
- `lib/screens/payment_screen.dart` - New payment screen
- `lib/screens/dashboard_screen.dart` - Added navigation to payment screen
- `pubspec.yaml` - Added razorpay_flutter dependency

## Dependencies Added
```yaml
razorpay_flutter: ^1.3.7
```

## Notes
- The payment screen uses the app's theme colors (blue and orange)
- All UI components follow the design system
- Error handling includes user-friendly messages
- The screen is responsive and works on all screen sizes
