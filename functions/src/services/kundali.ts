/**
 * Kundali Service Cloud Function
 * Generates comprehensive Kundali analysis with chart and PDF report
 *
 * Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 8.2, 8.3
 */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {
  calculatePlanetaryPositions,
  calculateHouses,
  calculateAllNakshatras,
  calculateVimshottariDasha,
  calculateLagna,
  calculateMoonSign,
  calculateSunSign,
} from "../utils/calculations";
import {generateKundaliChart, ChartStyle} from "../utils/image-processor";
import {generateKundaliPDF, KundaliData} from "../utils/pdf-generator";

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Retry configuration for transient failures
 */
const RETRY_CONFIG = {
  maxRetries: 3,
  initialDelay: 1000, // 1 second
  maxDelay: 10000, // 10 seconds
  backoffMultiplier: 2,
};

/**
 * Sleep utility for retry delays
 */
function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Retry wrapper for operations that may fail transiently
 */
async function retryOperation<T>(
  operation: () => Promise<T>,
  operationName: string,
  retries: number = RETRY_CONFIG.maxRetries
): Promise<T> {
  let lastError: Error | null = null;
  let delay = RETRY_CONFIG.initialDelay;

  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      return await operation();
    } catch (error: any) {
      lastError = error;

      // Check if error is retryable
      const isRetryable = isRetryableError(error);

      if (!isRetryable || attempt === retries) {
        logger.error(`${operationName} failed after ${attempt} attempts`, {
          error: error.message,
          isRetryable,
        });
        throw error;
      }

      logger.warn(`${operationName} failed, retrying (attempt ${attempt}/${retries})`, {
        error: error.message,
        nextRetryIn: delay,
      });

      await sleep(delay);
      delay = Math.min(delay * RETRY_CONFIG.backoffMultiplier, RETRY_CONFIG.maxDelay);
    }
  }

  throw lastError || new Error(`${operationName} failed after ${retries} retries`);
}

/**
 * Determine if an error is retryable
 */
function isRetryableError(error: any): boolean {
  // Network errors
  if (error.code === "ECONNRESET" || error.code === "ETIMEDOUT" || error.code === "ENOTFOUND") {
    return true;
  }

  // Firestore errors
  if (error.code === "unavailable" || error.code === "deadline-exceeded") {
    return true;
  }

  // Storage errors
  if (error.code === 503 || error.code === 429) {
    return true;
  }

  // Generic timeout or temporary errors
  if (error.message && (error.message.includes("timeout") || error.message.includes("temporary"))) {
    return true;
  }

  return false;
}

/**
 * Input data structure for Kundali generation
 */
interface KundaliInput {
  name: string;
  dateOfBirth: string; // YYYY-MM-DD format
  timeOfBirth: string; // HH:MM format (24-hour)
  placeOfBirth: string;
  latitude: number;
  longitude: number;
  timezone?: string;
  chartStyle?: ChartStyle;
}

/**
 * Validate Kundali input data
 */
function validateKundaliInput(data: any): KundaliInput {
  const errors: string[] = [];

  // Validate required fields
  if (!data.name || typeof data.name !== "string" || data.name.trim().length === 0) {
    errors.push("Name is required and must be a non-empty string");
  }

  if (!data.dateOfBirth || typeof data.dateOfBirth !== "string") {
    errors.push("Date of birth is required (format: YYYY-MM-DD)");
  } else {
    // Validate date format
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateRegex.test(data.dateOfBirth)) {
      errors.push("Date of birth must be in YYYY-MM-DD format");
    } else {
      const date = new Date(data.dateOfBirth);
      if (isNaN(date.getTime())) {
        errors.push("Invalid date of birth");
      }
    }
  }

  if (!data.timeOfBirth || typeof data.timeOfBirth !== "string") {
    errors.push("Time of birth is required (format: HH:MM)");
  } else {
    // Validate time format
    const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
    if (!timeRegex.test(data.timeOfBirth)) {
      errors.push("Time of birth must be in HH:MM format (24-hour)");
    }
  }

  if (!data.placeOfBirth || typeof data.placeOfBirth !== "string" || data.placeOfBirth.trim().length === 0) {
    errors.push("Place of birth is required and must be a non-empty string");
  }

  if (typeof data.latitude !== "number" || data.latitude < -90 || data.latitude > 90) {
    errors.push("Latitude must be a number between -90 and 90");
  }

  if (typeof data.longitude !== "number" || data.longitude < -180 || data.longitude > 180) {
    errors.push("Longitude must be a number between -180 and 180");
  }

  // Validate optional fields
  if (data.chartStyle && !["northIndian", "southIndian", "eastIndian", "western"].includes(data.chartStyle)) {
    errors.push("Chart style must be one of: northIndian, southIndian, eastIndian, western");
  }

  if (errors.length > 0) {
    throw new HttpsError("invalid-argument", errors.join("; "));
  }

  return {
    name: data.name.trim(),
    dateOfBirth: data.dateOfBirth,
    timeOfBirth: data.timeOfBirth,
    placeOfBirth: data.placeOfBirth.trim(),
    latitude: data.latitude,
    longitude: data.longitude,
    timezone: data.timezone || "Asia/Kolkata",
    chartStyle: data.chartStyle || "northIndian",
  };
}

/**
 * Generate Kundali Cloud Function
 * HTTP Callable function that generates a complete Kundali report
 */
export const generateKundali = onCall(
  {
    maxInstances: 10,
    memory: "512MiB",
    timeoutSeconds: 300, // 5 minutes
  },
  async (request) => {
    const startTime = Date.now();

    try {
      // Verify authentication
      if (!request.auth) {
        logger.warn("Unauthenticated Kundali generation attempt");
        throw new HttpsError("unauthenticated", "User must be authenticated to generate Kundali");
      }

      const userId = request.auth.uid;
      logger.info("Kundali generation started", {userId});

      // Validate input data
      const input = validateKundaliInput(request.data);
      logger.info("Input validated", {name: input.name, dateOfBirth: input.dateOfBirth});

      // Create initial report document in Firestore
      const reportRef = admin.firestore().collection("reports").doc();
      const reportId = reportRef.id;

      await reportRef.set({
        userId,
        serviceType: "kundali",
        status: "processing",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        data: {
          name: input.name,
          dateOfBirth: input.dateOfBirth,
          timeOfBirth: input.timeOfBirth,
          placeOfBirth: input.placeOfBirth,
          latitude: input.latitude,
          longitude: input.longitude,
          chartStyle: input.chartStyle,
        },
      });

      logger.info("Report document created", {reportId});

      // Perform Vedic calculations
      logger.info("Starting Vedic calculations");
      const planetaryPositions = calculatePlanetaryPositions(
        input.dateOfBirth,
        input.timeOfBirth,
        input.latitude,
        input.longitude,
        input.timezone
      );

      const houses = calculateHouses(
        input.dateOfBirth,
        input.timeOfBirth,
        input.latitude,
        input.longitude
      );

      const nakshatras = calculateAllNakshatras(planetaryPositions);
      const moonNakshatra = nakshatras.Moon;
      const dashas = calculateVimshottariDasha(input.dateOfBirth, moonNakshatra);

      const lagna = calculateLagna(houses);
      const moonSign = calculateMoonSign(planetaryPositions);
      const sunSign = calculateSunSign(planetaryPositions);

      logger.info("Vedic calculations completed", {
        lagna,
        moonSign,
        sunSign,
        moonNakshatra: moonNakshatra.nakshatra,
      });

      // Generate chart image
      logger.info("Generating chart image", {style: input.chartStyle});
      const chartImageBuffer = await generateKundaliChart(
        planetaryPositions,
        houses,
        input.chartStyle
      );

      // Upload chart image to Cloud Storage with retry
      const bucket = admin.storage().bucket();
      const chartImagePath = `kundalis/${userId}/${reportId}/chart.png`;
      const chartFile = bucket.file(chartImagePath);

      await retryOperation(
        async () => {
          await chartFile.save(chartImageBuffer, {
            metadata: {
              contentType: "image/png",
              metadata: {
                userId,
                reportId,
                serviceType: "kundali",
              },
            },
          });
          await chartFile.makePublic();
        },
        "Chart image upload"
      );

      const chartImageUrl = `https://storage.googleapis.com/${bucket.name}/${chartImagePath}`;
      logger.info("Chart image uploaded", {chartImageUrl});

      // Prepare Kundali data for PDF
      const kundaliData: KundaliData = {
        name: input.name,
        dateOfBirth: input.dateOfBirth,
        timeOfBirth: input.timeOfBirth,
        placeOfBirth: input.placeOfBirth,
        latitude: input.latitude,
        longitude: input.longitude,
        planetaryPositions,
        houses,
        nakshatras,
        dashas,
        lagna,
        moonSign,
        sunSign,
      };

      // Generate PDF report
      logger.info("Generating PDF report");
      const pdfBuffer = await generateKundaliPDF(kundaliData);

      // Upload PDF to Cloud Storage with retry
      const pdfPath = `kundalis/${userId}/${reportId}/report.pdf`;
      const pdfFile = bucket.file(pdfPath);

      await retryOperation(
        async () => {
          await pdfFile.save(pdfBuffer, {
            metadata: {
              contentType: "application/pdf",
              metadata: {
                userId,
                reportId,
                serviceType: "kundali",
              },
            },
          });
          await pdfFile.makePublic();
        },
        "PDF upload"
      );

      const pdfUrl = `https://storage.googleapis.com/${bucket.name}/${pdfPath}`;
      logger.info("PDF report uploaded", {pdfUrl});

      // Update report document with results (with retry)
      await retryOperation(
        async () => {
          await reportRef.update({
            status: "completed",
            completedAt: admin.firestore.FieldValue.serverTimestamp(),
            files: {
              pdfUrl,
              imageUrls: [chartImageUrl],
            },
            calculatedData: {
              lagna,
              moonSign,
              sunSign,
              moonNakshatra: moonNakshatra.nakshatra,
              moonNakshatraPada: moonNakshatra.pada,
              planetaryPositions: Object.fromEntries(
                Object.entries(planetaryPositions).map(([planet, pos]) => [
                  planet,
                  {
                    sign: pos.sign,
                    degree: pos.degree,
                    house: pos.house,
                    retrograde: pos.retrograde,
                  },
                ])
              ),
              houses: Object.fromEntries(
                Object.entries(houses).map(([house, cusp]) => [
                  house,
                  {
                    sign: cusp.sign,
                    degree: cusp.degree_in_sign,
                  },
                ])
              ),
              dashas: dashas.slice(0, 5), // Store first 5 Mahadashas
            },
            processingTime: Date.now() - startTime,
          });
        },
        "Firestore report update"
      );

      logger.info("Kundali generation completed successfully", {
        reportId,
        processingTime: Date.now() - startTime,
      });

      // Send notification to user using notification utility
      try {
        const {sendKundaliReadyNotification} = await import("../utils/notifications.js");
        await sendKundaliReadyNotification(userId, reportId);
        logger.info("Kundali ready notification sent", {userId, reportId});
      } catch (notificationError) {
        // Log but don't fail the function if notification fails
        logger.warn("Failed to send notification", {error: notificationError});
      }

      // Return success response
      return {
        success: true,
        reportId,
        status: "completed",
        files: {
          pdfUrl,
          chartImageUrl,
        },
        data: {
          lagna,
          moonSign,
          sunSign,
          moonNakshatra: moonNakshatra.nakshatra,
        },
        processingTime: Date.now() - startTime,
      };
    } catch (error: any) {
      const errorDetails = {
        message: error.message || "Unknown error",
        code: error.code,
        stack: error.stack,
        userId: request.auth?.uid,
        processingTime: Date.now() - startTime,
      };

      logger.error("Kundali generation failed", errorDetails);

      // Try to update report status to failed if report was created
      // We need to track reportId in the scope
      try {
        // Check if we have a reportId in scope (from the try block)
        const reportDocs = await admin
          .firestore()
          .collection("reports")
          .where("userId", "==", request.auth?.uid)
          .where("status", "==", "processing")
          .orderBy("createdAt", "desc")
          .limit(1)
          .get();

        if (!reportDocs.empty) {
          const reportDoc = reportDocs.docs[0];
          await reportDoc.ref.update({
            status: "failed",
            error: {
              message: error.message || "Unknown error",
              code: error.code || "unknown",
              timestamp: admin.firestore.FieldValue.serverTimestamp(),
            },
            failedAt: admin.firestore.FieldValue.serverTimestamp(),
            processingTime: Date.now() - startTime,
          });
          logger.info("Updated report status to failed", {reportId: reportDoc.id});
        }
      } catch (updateError: any) {
        logger.error("Failed to update report status", {
          error: updateError.message,
          originalError: error.message,
        });
      }

      // Throw appropriate HttpsError with user-friendly message
      if (error instanceof HttpsError) {
        throw error;
      }

      // Categorize errors for better user feedback
      let userMessage = "Failed to generate Kundali. Please try again.";
      let errorCode = "internal";

      if (error.message?.includes("timeout")) {
        userMessage = "The request timed out. Please try again.";
        errorCode = "deadline-exceeded";
      } else if (error.message?.includes("storage") || error.message?.includes("upload")) {
        userMessage = "Failed to save the report files. Please try again.";
        errorCode = "unavailable";
      } else if (error.message?.includes("calculation")) {
        userMessage = "Failed to perform astrological calculations. Please check your birth details.";
        errorCode = "invalid-argument";
      }

      throw new HttpsError(errorCode as any, userMessage, {
        details: error.message,
      });
    }
  }
);
