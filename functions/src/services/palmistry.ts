/**
 * Palmistry Service Cloud Function
 * Handles palmistry analysis requests with 24-hour scheduled processing
 *
 * Requirements: 4.3, 7.1, 7.6
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
 * Input data structure for Palmistry analysis request
 */
interface PalmistryInput {
  imageUrl: string;
  handType?: "left" | "right" | "both";
  analysisType?: "basic" | "detailed" | "comprehensive";
  specificQuestions?: string[];
}

/**
 * Validate Palmistry input data
 */
function validatePalmistryInput(data: any): PalmistryInput {
  const errors: string[] = [];

  // Validate required fields
  if (!data.imageUrl || typeof data.imageUrl !== "string" || data.imageUrl.trim().length === 0) {
    errors.push("Image URL is required and must be a non-empty string");
  } else {
    // Basic URL validation
    try {
      new URL(data.imageUrl);
    } catch {
      errors.push("Image URL must be a valid URL");
    }
  }

  // Validate optional fields
  if (data.handType && !["left", "right", "both"].includes(data.handType)) {
    errors.push("Hand type must be one of: left, right, both");
  }

  if (data.analysisType && !["basic", "detailed", "comprehensive"].includes(data.analysisType)) {
    errors.push("Analysis type must be one of: basic, detailed, comprehensive");
  }

  if (data.specificQuestions) {
    if (!Array.isArray(data.specificQuestions)) {
      errors.push("Specific questions must be an array");
    } else if (data.specificQuestions.length > 10) {
      errors.push("Maximum 10 specific questions allowed");
    }
  }

  if (errors.length > 0) {
    throw new HttpsError("invalid-argument", errors.join("; "));
  }

  return {
    imageUrl: data.imageUrl.trim(),
    handType: data.handType || "right",
    analysisType: data.analysisType || "detailed",
    specificQuestions: data.specificQuestions || [],
  };
}

/**
 * Request Palmistry Analysis Cloud Function
 * HTTP Callable function that schedules palmistry analysis for 24 hours later
 */
export const requestPalmistryAnalysis = onCall(
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
        logger.warn("Unauthenticated Palmistry analysis request");
        throw new HttpsError(
          "unauthenticated",
          "User must be authenticated to request Palmistry analysis"
        );
      }

      const userId = request.auth.uid;
      logger.info("Palmistry analysis request received", {userId});

      // Validate input data
      const input = validatePalmistryInput(request.data);
      logger.info("Input validated", {
        handType: input.handType,
        analysisType: input.analysisType,
      });

      // Calculate scheduled time (24 hours from now)
      const now = new Date();
      const scheduledFor = new Date(now.getTime() + 24 * 60 * 60 * 1000);

      // Create report document in Firestore with 'scheduled' status
      const reportRef = admin.firestore().collection("reports").doc();
      const reportId = reportRef.id;

      await reportRef.set({
        userId,
        serviceType: "palmistry",
        status: "scheduled",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        scheduledFor: admin.firestore.Timestamp.fromDate(scheduledFor),
        data: {
          imageUrl: input.imageUrl,
          handType: input.handType,
          analysisType: input.analysisType,
          specificQuestions: input.specificQuestions,
        },
        metadata: {
          requestedAt: now.toISOString(),
          estimatedDelivery: scheduledFor.toISOString(),
        },
      });

      logger.info("Palmistry report scheduled", {
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
          "Palmistry",
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
        message: "Your palmistry analysis has been scheduled and will be ready in 24 hours.",
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

      logger.error("Palmistry analysis request failed", errorDetails);

      // Throw appropriate HttpsError with user-friendly message
      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        "Failed to schedule palmistry analysis. Please try again.",
        {
          details: error.message,
        }
      );
    }
  }
);
