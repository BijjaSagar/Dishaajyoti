/**
 * DishaAjyoti Cloud Functions
 *
 * This file contains the entry point for all Cloud Functions used in the
 * DishaAjyoti application. Functions are organized by service type.
 *
 * Import function triggers from their respective submodules:
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions/v2";
import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

// Set global options for all functions
// For cost control, limit the maximum number of concurrent instances
setGlobalOptions({
  maxInstances: 10,
  region: "us-central1",
  memory: "256MiB",
});

/**
 * Health check function to verify Cloud Functions are working
 * This is a simple test function that can be called to verify deployment
 */
export const healthCheck = onRequest((request, response) => {
  logger.info("Health check called", {structuredData: true});
  response.json({
    status: "ok",
    message: "DishaAjyoti Cloud Functions are running",
    timestamp: new Date().toISOString(),
    version: "1.0.0",
  });
});

// Service functions
export * from "./services/kundali";
export * from "./services/palmistry";
export * from "./services/numerology";
export * from "./services/payment";

// Scheduled functions
export * from "./scheduled/processScheduledReports";

// Firestore triggers
export * from "./triggers/onOrderCreated";
