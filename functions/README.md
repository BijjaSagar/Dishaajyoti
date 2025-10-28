# DishaAjyoti Cloud Functions

This directory contains Firebase Cloud Functions for the DishaAjyoti astrology application.

## Setup Complete ✅

Task 8 "Set up Cloud Functions project" has been completed with the following:

### 8.1 Initialize Cloud Functions ✅
- Firebase Cloud Functions already initialized with TypeScript
- ESLint configured with Google style guide
- Prettier added for code formatting
- All required npm packages installed:
  - `firebase-admin@12.7.0`
  - `firebase-functions@6.6.0`
  - `firebase-functions-test@3.4.1`
  - `prettier` (dev dependency)

### 8.2 Create Utility Modules ✅

Four utility modules have been created to support Cloud Functions:

#### 1. `src/utils/calculations.ts`
Vedic astrology calculations ported from PHP to TypeScript:
- Planetary position calculations
- House cusp calculations
- Nakshatra (lunar mansion) calculations
- Vimshottari Dasha period calculations
- Zodiac sign calculations (Lagna, Moon sign, Sun sign)
- Complete nakshatra mapping with all 27 nakshatras

**Key Functions:**
- `calculatePlanetaryPositions()` - Calculate planetary positions
- `calculateHouses()` - Calculate house cusps
- `calculateNakshatra()` - Calculate nakshatra from longitude
- `calculateVimshottariDasha()` - Calculate Mahadasha periods
- `getNakshatraMapping()` - Get complete nakshatra details

#### 2. `src/utils/pdf-generator.ts`
PDF generation utilities for astrology reports:
- Kundali PDF generation
- Palmistry PDF generation
- Numerology PDF generation
- Storage upload integration

**Key Functions:**
- `generateKundaliPDF()` - Generate Kundali report PDF
- `generatePalmistryPDF()` - Generate Palmistry analysis PDF
- `generateNumerologyPDF()` - Generate Numerology report PDF

**Note:** Currently placeholder implementations. For production, integrate with PDFKit or Puppeteer.

#### 3. `src/utils/image-processor.ts`
Chart image generation and image processing:
- Kundali chart generation (North Indian, South Indian, East Indian, Western styles)
- Image compression and optimization
- Image resizing and format conversion
- Palmistry image processing

**Key Functions:**
- `generateKundaliChart()` - Generate chart images in various styles
- `compressImage()` - Compress images for storage
- `resizeImage()` - Resize images to specified dimensions
- `convertToWebP()` - Convert images to WebP format
- `processPalmistryImage()` - Process palm images for analysis

**Note:** Currently placeholder implementations. For production, integrate with Canvas or Sharp library.

#### 4. `src/utils/notifications.ts`
Firebase Cloud Messaging (FCM) notification utilities:
- Send notifications to individual users
- Send notifications to multiple users
- Service-specific notification templates
- Topic-based notifications

**Key Functions:**
- `sendNotificationToUser()` - Send notification to specific user
- `sendNotificationToToken()` - Send notification to FCM token
- `sendKundaliReadyNotification()` - Notify when Kundali is ready
- `sendPalmistryReadyNotification()` - Notify when Palmistry is ready
- `sendNumerologyReadyNotification()` - Notify when Numerology is ready
- `sendPaymentConfirmationNotification()` - Notify payment confirmation
- `sendReportFailureNotification()` - Notify report generation failure
- `sendScheduledReportReminder()` - Send scheduled report reminder

## Project Structure

```
functions/
├── src/
│   ├── index.ts                    # Main entry point
│   └── utils/
│       ├── calculations.ts         # Vedic astrology calculations
│       ├── pdf-generator.ts        # PDF generation utilities
│       ├── image-processor.ts      # Image processing utilities
│       └── notifications.ts        # FCM notification utilities
├── lib/                            # Compiled JavaScript (generated)
├── package.json                    # Dependencies and scripts
├── tsconfig.json                   # TypeScript configuration
├── .eslintrc.js                    # ESLint configuration
└── .prettierrc                     # Prettier configuration
```

## Available Scripts

- `npm run lint` - Run ESLint to check code quality
- `npm run format` - Format code with Prettier
- `npm run format:check` - Check if code is formatted
- `npm run build` - Compile TypeScript to JavaScript
- `npm run build:watch` - Watch mode compilation
- `npm run serve` - Start Firebase emulators
- `npm run deploy` - Deploy functions to Firebase
- `npm run logs` - View function logs

## Next Steps

The following tasks are ready to be implemented:

### Task 9: Implement Kundali Generation Cloud Function
- Create `src/services/kundali.ts`
- Implement `generateKundali` HTTP callable function
- Integrate with calculation utilities
- Generate and upload chart images
- Generate and upload PDF reports
- Update Firestore with results

### Task 10: Implement Async Service Cloud Functions
- Create Palmistry service function (24h delay)
- Create Numerology service function (12h delay)
- Implement scheduled processing function
- Set up Cloud Scheduler

### Task 11: Implement Payment Processing Cloud Function
- Create payment service function
- Integrate with Razorpay/Stripe
- Implement Firestore triggers
- Handle order status updates

## Requirements Addressed

- **Requirement 4.1**: Cloud Functions infrastructure set up
- **Requirement 4.2**: Vedic calculation logic ported from PHP
- **Requirement 4.6**: ESLint and code quality tools configured

## Notes

- All utility modules are TypeScript with proper type definitions
- Code follows Google TypeScript style guide
- Placeholder implementations marked with TODO comments
- Ready for integration with actual calculation libraries (Swiss Ephemeris)
- Ready for integration with PDF generation libraries (PDFKit, Puppeteer)
- Ready for integration with image processing libraries (Canvas, Sharp)

## Testing

Unit tests will be added in future tasks. The current setup includes:
- `firebase-functions-test@3.4.1` for testing Cloud Functions
- Test files will be created in `src/**/*.test.ts`

## Deployment

Functions are configured for deployment with:
- Node.js 22 runtime
- Maximum 10 concurrent instances (cost control)
- US Central 1 region
- 256MB memory allocation

To deploy:
```bash
npm run deploy
```

## Health Check

A health check function is available at:
```
https://us-central1-<project-id>.cloudfunctions.net/healthCheck
```

This can be used to verify Cloud Functions are running correctly.
