/**
 * Payment Service Cloud Function
 * Handles payment processing, verification, and order status updates
 *
 * Requirements: 8.1, 8.2, 8.3
 */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import * as crypto from "crypto";

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Payment gateway configuration
 * Environment variables are loaded from .env file or Cloud Functions environment
 * For local development: Create .env file in functions directory
 * For production: Set in Firebase Console or use .env file
 */
const PAYMENT_CONFIG = {
  razorpay: {
    keyId: process.env.RAZORPAY_KEY_ID || "",
    keySecret: process.env.RAZORPAY_KEY_SECRET || "",
  },
  stripe: {
    secretKey: process.env.STRIPE_SECRET_KEY || "",
    webhookSecret: process.env.STRIPE_WEBHOOK_SECRET || "",
  },
};

/**
 * Payment input data structure
 */
interface PaymentInput {
  orderId: string;
  paymentId: string;
  paymentGateway: "razorpay" | "stripe";
  amount: number;
  currency: string;
  signature?: string; // For Razorpay signature verification
  paymentIntentId?: string; // For Stripe payment intent
}

/**
 * Validate payment input data
 */
function validatePaymentInput(data: any): PaymentInput {
  const errors: string[] = [];

  if (!data.orderId || typeof data.orderId !== "string") {
    errors.push("Order ID is required");
  }

  if (!data.paymentId || typeof data.paymentId !== "string") {
    errors.push("Payment ID is required");
  }

  if (!data.paymentGateway || !["razorpay", "stripe"].includes(data.paymentGateway)) {
    errors.push("Payment gateway must be either 'razorpay' or 'stripe'");
  }

  if (typeof data.amount !== "number" || data.amount <= 0) {
    errors.push("Amount must be a positive number");
  }

  if (!data.currency || typeof data.currency !== "string") {
    errors.push("Currency is required");
  }

  // Razorpay requires signature
  if (data.paymentGateway === "razorpay" && !data.signature) {
    errors.push("Razorpay signature is required for verification");
  }

  // Stripe requires payment intent ID
  if (data.paymentGateway === "stripe" && !data.paymentIntentId) {
    errors.push("Stripe payment intent ID is required");
  }

  if (errors.length > 0) {
    throw new HttpsError("invalid-argument", errors.join("; "));
  }

  return {
    orderId: data.orderId,
    paymentId: data.paymentId,
    paymentGateway: data.paymentGateway,
    amount: data.amount,
    currency: data.currency,
    signature: data.signature,
    paymentIntentId: data.paymentIntentId,
  };
}

/**
 * Verify Razorpay payment signature
 */
function verifyRazorpaySignature(
  orderId: string,
  paymentId: string,
  signature: string
): boolean {
  try {
    const keySecret = PAYMENT_CONFIG.razorpay.keySecret;

    if (!keySecret) {
      logger.error("Razorpay key secret not configured");
      return false;
    }

    // Generate expected signature
    const body = `${orderId}|${paymentId}`;
    const expectedSignature = crypto
      .createHmac("sha256", keySecret)
      .update(body)
      .digest("hex");

    // Compare signatures
    return crypto.timingSafeEqual(
      Buffer.from(signature),
      Buffer.from(expectedSignature)
    );
  } catch (error: any) {
    logger.error("Error verifying Razorpay signature", {error: error.message});
    return false;
  }
}

/**
 * Verify Stripe payment intent
 * In a real implementation, this would call Stripe API to verify the payment
 */
async function verifyStripePayment(
  paymentIntentId: string,
  amount: number
): Promise<boolean> {
  try {
    // Note: In production, you would use the Stripe SDK here
    // const stripe = require('stripe')(PAYMENT_CONFIG.stripe.secretKey);
    // const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
    // return paymentIntent.status === 'succeeded' && paymentIntent.amount === amount * 100;

    // For now, we'll do basic validation
    if (!PAYMENT_CONFIG.stripe.secretKey) {
      logger.error("Stripe secret key not configured");
      return false;
    }

    // Placeholder: In production, implement actual Stripe API call
    logger.info("Stripe payment verification (placeholder)", {
      paymentIntentId,
      amount,
    });

    return true;
  } catch (error: any) {
    logger.error("Error verifying Stripe payment", {error: error.message});
    return false;
  }
}

/**
 * Trigger service processing based on order details
 */
async function triggerServiceProcessing(order: any): Promise<void> {
  try {
    const {userId, serviceType, reportId, serviceData} = order;

    logger.info("Triggering service processing", {serviceType, reportId});

    // Create or update report document
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
        orderId: order.orderId,
      });
    } else {
      // Update existing report
      await reportRef.update({
        status: "pending",
        orderId: order.orderId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // For instant services (like Kundali), we could trigger the function directly
    // For async services (Palmistry, Numerology), they'll be picked up by scheduled function
    if (serviceType === "kundali") {
      // The report is now in 'pending' state and can be processed
      // In a real implementation, you might trigger the generateKundali function here
      logger.info("Kundali service ready for processing", {reportId});
    } else if (serviceType === "palmistry" || serviceType === "numerology") {
      // Set scheduled time for async services
      const delayHours = serviceType === "palmistry" ? 24 : 12;
      const scheduledFor = new Date(Date.now() + delayHours * 60 * 60 * 1000);

      await reportRef.update({
        status: "scheduled",
        scheduledFor: admin.firestore.Timestamp.fromDate(scheduledFor),
      });

      logger.info("Async service scheduled", {serviceType, scheduledFor});
    }
  } catch (error: any) {
    logger.error("Failed to trigger service processing", {
      error: error.message,
      orderId: order.orderId,
    });
    throw error;
  }
}

/**
 * Process Payment Cloud Function
 * HTTP Callable function that verifies payment and updates order status
 */
export const processPayment = onCall(
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
        logger.warn("Unauthenticated payment processing attempt");
        throw new HttpsError(
          "unauthenticated",
          "User must be authenticated to process payment"
        );
      }

      const userId = request.auth.uid;
      logger.info("Payment processing started", {userId});

      // Validate input data
      const input = validatePaymentInput(request.data);
      logger.info("Payment input validated", {
        orderId: input.orderId,
        paymentGateway: input.paymentGateway,
      });

      // Get order document
      const orderRef = admin.firestore().collection("orders").doc(input.orderId);
      const orderDoc = await orderRef.get();

      if (!orderDoc.exists) {
        logger.error("Order not found", {orderId: input.orderId});
        throw new HttpsError("not-found", "Order not found");
      }

      const orderData = orderDoc.data()!;

      // Verify order belongs to user
      if (orderData.userId !== userId) {
        logger.error("Order does not belong to user", {
          orderId: input.orderId,
          orderUserId: orderData.userId,
          requestUserId: userId,
        });
        throw new HttpsError(
          "permission-denied",
          "You do not have permission to process this order"
        );
      }

      // Check if order is already paid
      if (orderData.status === "paid") {
        logger.warn("Order already paid", {orderId: input.orderId});
        return {
          success: true,
          orderId: input.orderId,
          status: "paid",
          message: "Order already paid",
          alreadyPaid: true,
        };
      }

      // Verify payment amount matches order amount
      if (Math.abs(orderData.amount - input.amount) > 0.01) {
        logger.error("Payment amount mismatch", {
          orderId: input.orderId,
          orderAmount: orderData.amount,
          paymentAmount: input.amount,
        });
        throw new HttpsError(
          "invalid-argument",
          "Payment amount does not match order amount"
        );
      }

      // Verify payment based on gateway
      let paymentVerified = false;

      if (input.paymentGateway === "razorpay") {
        logger.info("Verifying Razorpay payment", {paymentId: input.paymentId});
        paymentVerified = verifyRazorpaySignature(
          input.orderId,
          input.paymentId,
          input.signature!
        );
      } else if (input.paymentGateway === "stripe") {
        logger.info("Verifying Stripe payment", {
          paymentIntentId: input.paymentIntentId,
        });
        paymentVerified = await verifyStripePayment(
          input.paymentIntentId!,
          input.amount
        );
      }

      if (!paymentVerified) {
        logger.error("Payment verification failed", {
          orderId: input.orderId,
          paymentId: input.paymentId,
          gateway: input.paymentGateway,
        });

        // Update order status to failed
        await orderRef.update({
          status: "failed",
          failedAt: admin.firestore.FieldValue.serverTimestamp(),
          error: {
            message: "Payment verification failed",
            code: "payment_verification_failed",
          },
        });

        throw new HttpsError(
          "invalid-argument",
          "Payment verification failed. Please contact support."
        );
      }

      logger.info("Payment verified successfully", {orderId: input.orderId});

      // Update order status to paid
      await orderRef.update({
        status: "paid",
        paidAt: admin.firestore.FieldValue.serverTimestamp(),
        paymentId: input.paymentId,
        paymentGateway: input.paymentGateway,
        paymentDetails: {
          amount: input.amount,
          currency: input.currency,
          verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      });

      logger.info("Order status updated to paid", {orderId: input.orderId});

      // Trigger service processing
      await triggerServiceProcessing({
        ...orderData,
        orderId: input.orderId,
      });

      logger.info("Service processing triggered", {orderId: input.orderId});

      // Send notification to user using notification utility
      try {
        const {sendPaymentConfirmationNotification} = await import("../utils/notifications");
        const serviceName = orderData.serviceType.charAt(0).toUpperCase() +
          orderData.serviceType.slice(1);
        await sendPaymentConfirmationNotification(userId, input.orderId, serviceName);
        logger.info("Payment confirmation notification sent", {userId, orderId: input.orderId});
      } catch (notificationError: any) {
        // Log but don't fail if notification fails
        logger.warn("Failed to send payment notification", {
          error: notificationError.message,
        });
      }

      const processingTime = Date.now() - startTime;
      logger.info("Payment processing completed successfully", {
        orderId: input.orderId,
        processingTime,
      });

      // Return success response
      return {
        success: true,
        orderId: input.orderId,
        status: "paid",
        message: "Payment processed successfully",
        reportId: orderData.reportId,
        serviceType: orderData.serviceType,
        processingTime,
      };
    } catch (error: any) {
      const errorDetails = {
        message: error.message || "Unknown error",
        code: error.code,
        userId: request.auth?.uid,
        processingTime: Date.now() - startTime,
      };

      logger.error("Payment processing failed", errorDetails);

      // Throw appropriate HttpsError
      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        "Failed to process payment. Please try again or contact support.",
        {details: error.message}
      );
    }
  }
);
