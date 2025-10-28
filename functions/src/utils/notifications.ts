/**
 * Notifications Utility
 * Handles Firebase Cloud Messaging (FCM) notifications
 *
 * Requirements: 4.1, 4.2
 */

import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

export interface NotificationPayload {
  title: string;
  body: string;
  imageUrl?: string;
  data?: Record<string, string>;
}

export interface NotificationOptions {
  priority?: "high" | "normal";
  sound?: string;
  badge?: number;
  clickAction?: string;
}

/**
 * Send notification to a specific user by their FCM token
 */
export async function sendNotificationToUser(
  userId: string,
  payload: NotificationPayload,
  options?: NotificationOptions
): Promise<boolean> {
  try {
    // Get user's FCM token from Firestore
    const userDoc = await admin.firestore().collection("users").doc(userId).get();

    if (!userDoc.exists) {
      logger.warn(`User ${userId} not found`);
      return false;
    }

    const userData = userDoc.data();
    const fcmToken = userData?.fcmToken;

    if (!fcmToken) {
      logger.warn(`No FCM token found for user ${userId}`);
      return false;
    }

    // Send notification
    return await sendNotificationToToken(fcmToken, payload, options);
  } catch (error) {
    logger.error(`Error sending notification to user ${userId}:`, error);
    return false;
  }
}

/**
 * Send notification to a specific FCM token
 */
export async function sendNotificationToToken(
  token: string,
  payload: NotificationPayload,
  options?: NotificationOptions
): Promise<boolean> {
  try {
    const message: admin.messaging.Message = {
      token,
      notification: {
        title: payload.title,
        body: payload.body,
        imageUrl: payload.imageUrl,
      },
      data: payload.data || {},
      android: {
        priority: options?.priority || "high",
        notification: {
          sound: options?.sound || "default",
          clickAction: options?.clickAction,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: options?.sound || "default",
            badge: options?.badge,
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    logger.info(`Successfully sent notification: ${response}`);
    return true;
  } catch (error) {
    logger.error("Error sending notification:", error);
    return false;
  }
}

/**
 * Send notification to multiple users
 */
export async function sendNotificationToMultipleUsers(
  userIds: string[],
  payload: NotificationPayload,
  options?: NotificationOptions
): Promise<{ success: number; failure: number }> {
  const results = await Promise.allSettled(
    userIds.map((userId) => sendNotificationToUser(userId, payload, options))
  );

  const success = results.filter((r) => r.status === "fulfilled" && r.value === true).length;
  const failure = results.length - success;

  return {success, failure};
}

/**
 * Send notification when Kundali is ready
 */
export async function sendKundaliReadyNotification(
  userId: string,
  reportId: string
): Promise<boolean> {
  return sendNotificationToUser(userId, {
    title: "Your Kundali is Ready! 🌟",
    body: "Your personalized Kundali report has been generated and is ready to view.",
    data: {
      type: "kundali_ready",
      reportId,
      action: "view_report",
    },
  });
}

/**
 * Send notification when Palmistry analysis is ready
 */
export async function sendPalmistryReadyNotification(
  userId: string,
  reportId: string
): Promise<boolean> {
  return sendNotificationToUser(userId, {
    title: "Your Palmistry Analysis is Ready! 🤚",
    body: "Your detailed palm reading has been completed and is ready to view.",
    data: {
      type: "palmistry_ready",
      reportId,
      action: "view_report",
    },
  });
}

/**
 * Send notification when Numerology report is ready
 */
export async function sendNumerologyReadyNotification(
  userId: string,
  reportId: string
): Promise<boolean> {
  return sendNotificationToUser(userId, {
    title: "Your Numerology Report is Ready! 🔢",
    body: "Your personalized numerology analysis has been completed.",
    data: {
      type: "numerology_ready",
      reportId,
      action: "view_report",
    },
  });
}

/**
 * Send notification when payment is confirmed
 */
export async function sendPaymentConfirmationNotification(
  userId: string,
  orderId: string,
  serviceName: string
): Promise<boolean> {
  return sendNotificationToUser(userId, {
    title: "Payment Confirmed ✅",
    body: `Your payment for ${serviceName} has been confirmed. Processing your request...`,
    data: {
      type: "payment_confirmed",
      orderId,
      action: "view_order",
    },
  });
}

/**
 * Send notification when report processing fails
 */
export async function sendReportFailureNotification(
  userId: string,
  reportId: string,
  serviceName: string
): Promise<boolean> {
  return sendNotificationToUser(userId, {
    title: "Report Generation Failed ⚠️",
    body: `We encountered an issue generating your ${serviceName} report. Please contact support.`,
    data: {
      type: "report_failed",
      reportId,
      action: "contact_support",
    },
  });
}

/**
 * Send scheduled report reminder
 */
export async function sendScheduledReportReminder(
  userId: string,
  reportId: string,
  serviceName: string,
  estimatedTime: string
): Promise<boolean> {
  return sendNotificationToUser(userId, {
    title: `${serviceName} Report Scheduled ⏰`,
    body: `Your report will be ready by ${estimatedTime}. We'll notify you when it's complete.`,
    data: {
      type: "report_scheduled",
      reportId,
      estimatedTime,
    },
  });
}

/**
 * Send topic notification to all subscribed users
 */
export async function sendTopicNotification(
  topic: string,
  payload: NotificationPayload
): Promise<boolean> {
  try {
    const message: admin.messaging.Message = {
      topic,
      notification: {
        title: payload.title,
        body: payload.body,
        imageUrl: payload.imageUrl,
      },
      data: payload.data || {},
    };

    const response = await admin.messaging().send(message);
    logger.info(`Successfully sent topic notification to ${topic}: ${response}`);
    return true;
  } catch (error) {
    logger.error(`Error sending topic notification to ${topic}:`, error);
    return false;
  }
}
