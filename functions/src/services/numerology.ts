/**
 * Numerology Service Cloud Function
 * Handles numerology report requests with 12-hour scheduled processing
 *
 * Requirements: 4.3, 7.2, 7.6
 */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {sendScheduledReportReminder} from "../utils/notifications";

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Input data structure for Numerology report request
 */
interface NumerologyInput {
  name: string;
  dateOfBirth: string; // YYYY-MM-DD format
  reportType?: "basic" | "detailed" | "comprehensive";
  includeCompatibility?: boolean;
  partnerDateOfBirth?: string; // Optional for compatibility analysis
}

/**
 * Validate Numerology input data
 */
function validateNumerologyInput(data: any): NumerologyInput {
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

  // Validate optional fields
  if (data.reportType && !["basic", "detailed", "comprehensive"].includes(data.reportType)) {
    errors.push("Report type must be one of: basic, detailed, comprehensive");
  }

  if (data.includeCompatibility && typeof data.includeCompatibility !== "boolean") {
    errors.push("Include compatibility must be a boolean");
  }

  if (data.includeCompatibility && data.partnerDateOfBirth) {
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateRegex.test(data.partnerDateOfBirth)) {
      errors.push("Partner date of birth must be in YYYY-MM-DD format");
    } else {
      const date = new Date(data.partnerDateOfBirth);
      if (isNaN(date.getTime())) {
        errors.push("Invalid partner date of birth");
      }
    }
  }

  if (errors.length > 0) {
    throw new HttpsError("invalid-argument", errors.join("; "));
  }

  return {
    name: data.name.trim(),
    dateOfBirth: data.dateOfBirth,
    reportType: data.reportType || "detailed",
    includeCompatibility: data.includeCompatibility || false,
    partnerDateOfBirth: data.partnerDateOfBirth,
  };
}

/**
 * Request Numerology Report Cloud Function
 * HTTP Callable function that schedules numerology report for 12 hours later
 */
export const requestNumerologyReport = onCall(
  {
    maxInstances: 10,
    memory: "256MiB",
    timeoutSeconds: 60,
  },
  async (request) => {
    const startTime = Date.now();

    try {
      // Verify authentication
      if (!request.auth) {
        logger.warn("Unauthenticated Numerology report request");
        throw new HttpsError(
          "unauthenticated",
          "User must be authenticated to request Numerology report"
        );
      }

      const userId = request.auth.uid;
      logger.info("Numerology report request received", {userId});

      // Validate input data
      const input = validateNumerologyInput(request.data);
      logger.info("Input validated", {
        name: input.name,
        dateOfBirth: input.dateOfBirth,
        reportType: input.reportType,
      });

      // Calculate scheduled time (12 hours from now)
      const now = new Date();
      const scheduledFor = new Date(now.getTime() + 12 * 60 * 60 * 1000);

      // Create report document in Firestore with 'scheduled' status
      const reportRef = admin.firestore().collection("reports").doc();
      const reportId = reportRef.id;

      await reportRef.set({
        userId,
        serviceType: "numerology",
        status: "scheduled",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        scheduledFor: admin.firestore.Timestamp.fromDate(scheduledFor),
        data: {
          name: input.name,
          dateOfBirth: input.dateOfBirth,
          reportType: input.reportType,
          includeCompatibility: input.includeCompatibility,
          partnerDateOfBirth: input.partnerDateOfBirth,
        },
        metadata: {
          requestedAt: now.toISOString(),
          estimatedDelivery: scheduledFor.toISOString(),
        },
      });

      logger.info("Numerology report scheduled", {
        reportId,
        scheduledFor: scheduledFor.toISOString(),
      });

      // Send notification to user about scheduled report
      try {
        const estimatedTimeStr = scheduledFor.toLocaleString("en-US", {
          dateStyle: "medium",
          timeStyle: "short",
        });

        await sendScheduledReportReminder(
          userId,
          reportId,
          "Numerology",
          estimatedTimeStr
        );
        logger.info("Scheduled report notification sent", {userId, reportId});
      } catch (notificationError) {
        // Log but don't fail the function if notification fails
        logger.warn("Failed to send scheduled report notification", {
          error: notificationError,
        });
      }

      // Return success response with report ID and estimated delivery time
      return {
        success: true,
        reportId,
        status: "scheduled",
        estimatedDelivery: scheduledFor.toISOString(),
        message: "Your numerology report has been scheduled and will be ready in 12 hours.",
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

      logger.error("Numerology report request failed", errorDetails);

      // Throw appropriate HttpsError with user-friendly message
      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        "Failed to schedule numerology report. Please try again.",
        {
          details: error.message,
        }
      );
    }
  }
);
