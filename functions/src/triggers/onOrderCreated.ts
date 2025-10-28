/**
 * Firestore Trigger: onOrderCreated
 * Automatically processes orders when they are created
 * Handles test mode orders by auto-completing them
 *
 * Requirements: 8.2, 12.1, 12.2
 */

import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Trigger service processing based on order details
 */
async function triggerServiceProcessing(
  orderId: string,
  orderData: any
): Promise<void> {
  try {
    const {userId, serviceType, reportId, serviceData} = orderData;

    logger.info("Triggering service processing from order trigger", {
      orderId,
      serviceType,
      reportId,
    });

    // Get or create report document
    const reportRef = admin.firestore().collection("reports").doc(reportId);
    const reportDoc = await reportRef.get();

    if (!reportDoc.exists) {
      // Create new report document
      await reportRef.set({
        userId,
        serviceType,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        data: serviceData || {},
        orderId,
        testMode: orderData.testMode || false,
      });

      logger.info("Report document created", {reportId});
    } else {
      // Update existing report
      await reportRef.update({
        status: "pending",
        orderId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        testMode: orderData.testMode || false,
      });

      logger.info("Report document updated", {reportId});
    }

    // Handle different service types
    if (serviceType === "kundali") {
      // Kundali is processed immediately
      // The report is now in 'pending' state and ready for processing
      logger.info("Kundali service ready for immediate processing", {reportId});

      // Optionally, you could trigger the generateKundali function here
      // by calling it directly or using a task queue
    } else if (serviceType === "palmistry" || serviceType === "numerology") {
      // Set scheduled time for async services
      const delayHours = serviceType === "palmistry" ? 24 : 12;
      const scheduledFor = new Date(Date.now() + delayHours * 60 * 60 * 1000);

      await reportRef.update({
        status: "scheduled",
        scheduledFor: admin.firestore.Timestamp.fromDate(scheduledFor),
      });

      logger.info("Async service scheduled", {
        serviceType,
        reportId,
        scheduledFor: scheduledFor.toISOString(),
      });
    } else {
      // For other service types, just mark as pending
      logger.info("Service marked as pending", {serviceType, reportId});
    }

    // Send notification to user about order confirmation
    try {
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .get();
      const fcmToken = userDoc.data()?.fcmToken;

      if (fcmToken) {
        const isTestMode = orderData.testMode || false;
        const notificationBody = isTestMode ?
          `Your test order for ${serviceType} has been created.` :
          `Your order for ${serviceType} has been confirmed!`;

        await admin.messaging().send({
          token: fcmToken,
          notification: {
            title: "Order Confirmed",
            body: notificationBody,
          },
          data: {
            type: "order_confirmed",
            orderId,
            serviceType,
            reportId,
            testMode: isTestMode.toString(),
          },
        });

        logger.info("Order confirmation notification sent", {userId, orderId});
      }
    } catch (notificationError: any) {
      // Log but don't fail if notification fails
      logger.warn("Failed to send order confirmation notification", {
        error: notificationError.message,
        orderId,
      });
    }
  } catch (error: any) {
    logger.error("Failed to trigger service processing", {
      error: error.message,
      stack: error.stack,
      orderId,
    });
    throw error;
  }
}

/**
 * Firestore Trigger: onOrderCreated
 * Triggered when a new order document is created
 */
export const onOrderCreated = onDocumentCreated(
  {
    document: "orders/{orderId}",
    region: "us-central1",
    memory: "256MiB",
  },
  async (event) => {
    const orderId = event.params.orderId;
    const orderData = event.data?.data();

    if (!orderData) {
      logger.error("Order data is missing", {orderId});
      return;
    }

    logger.info("Order created trigger fired", {
      orderId,
      userId: orderData.userId,
      serviceType: orderData.serviceType,
      testMode: orderData.testMode || false,
    });

    try {
      // Check if this is a test mode order
      const isTestMode = orderData.testMode === true;

      if (isTestMode) {
        logger.info("Processing test mode order", {orderId});

        // Auto-complete the order for testing
        await event.data?.ref.update({
          status: "paid",
          paidAt: admin.firestore.FieldValue.serverTimestamp(),
          paymentId: `TEST_${orderId}`,
          paymentGateway: "test",
          paymentDetails: {
            amount: orderData.amount || 0,
            currency: orderData.currency || "INR",
            verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
            testMode: true,
          },
        });

        logger.info("Test order auto-completed", {orderId});

        // Trigger service processing
        await triggerServiceProcessing(orderId, orderData);

        logger.info("Test order processing triggered", {orderId});
      } else {
        // For production orders, just log and wait for payment
        logger.info("Production order created, waiting for payment", {
          orderId,
          amount: orderData.amount,
          currency: orderData.currency,
        });

        // Optionally, you could send a notification to the user
        // to remind them to complete the payment
        try {
          const userDoc = await admin
            .firestore()
            .collection("users")
            .doc(orderData.userId)
            .get();
          const fcmToken = userDoc.data()?.fcmToken;

          if (fcmToken) {
            await admin.messaging().send({
              token: fcmToken,
              notification: {
                title: "Complete Your Payment",
                body: `Please complete payment for your ${orderData.serviceType} order.`,
              },
              data: {
                type: "payment_pending",
                orderId,
                serviceType: orderData.serviceType,
                amount: orderData.amount?.toString() || "0",
              },
            });

            logger.info("Payment reminder notification sent", {
              userId: orderData.userId,
              orderId,
            });
          }
        } catch (notificationError: any) {
          logger.warn("Failed to send payment reminder notification", {
            error: notificationError.message,
            orderId,
          });
        }
      }
    } catch (error: any) {
      logger.error("Error processing order creation", {
        error: error.message,
        stack: error.stack,
        orderId,
      });

      // Update order status to failed
      try {
        await event.data?.ref.update({
          status: "failed",
          failedAt: admin.firestore.FieldValue.serverTimestamp(),
          error: {
            message: error.message || "Unknown error",
            code: error.code || "unknown",
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
          },
        });

        logger.info("Order status updated to failed", {orderId});
      } catch (updateError: any) {
        logger.error("Failed to update order status", {
          error: updateError.message,
          orderId,
        });
      }
    }
  }
);
