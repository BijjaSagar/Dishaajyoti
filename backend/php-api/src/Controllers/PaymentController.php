<?php

namespace App\Controllers;

use App\Config\Database;
use App\Middleware\AuthMiddleware;
use PDO;

class PaymentController extends BaseController
{
    private PDO $db;

    public function __construct()
    {
        parent::__construct();
        $this->db = Database::getConnection();
    }

    public function createOrder(): void
    {
        $authUser = AuthMiddleware::getAuthUser();
        $data = $this->getRequestData();

        if (empty($data['service_id'])) {
            $this->sendError('service_id is required', 400);
            return;
        }

        try {
            // Get service details
            $stmt = $this->db->prepare("
                SELECT id, name, price, currency
                FROM services
                WHERE id = ? AND is_active = 1
            ");
            $stmt->execute([$data['service_id']]);
            $service = $stmt->fetch();

            if (!$service) {
                $this->sendError('Service not found', 404);
                return;
            }

            // Create payment record
            $transactionId = 'TXN_' . strtoupper(uniqid());

            $stmt = $this->db->prepare("
                INSERT INTO payments (
                    user_id, service_id, amount, currency, transaction_id,
                    payment_gateway, status, created_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
            ");
            $stmt->execute([
                $authUser['user_id'],
                $data['service_id'],
                $service['price'],
                $service['currency'],
                $transactionId,
                'razorpay',
                'pending'
            ]);

            $paymentId = $this->db->lastInsertId();

            // In production, integrate with Razorpay or other payment gateway
            // For now, return order details

            $this->sendSuccess([
                'payment_id' => $paymentId,
                'transaction_id' => $transactionId,
                'amount' => (float)$service['price'],
                'currency' => $service['currency'],
                'service' => [
                    'id' => $service['id'],
                    'name' => $service['name']
                ]
            ], 'Payment order created', 201);

        } catch (\Exception $e) {
            error_log("Create order error: " . $e->getMessage());
            $this->sendError('Failed to create payment order', 500);
        }
    }

    public function verifyPayment(): void
    {
        $authUser = AuthMiddleware::getAuthUser();
        $data = $this->getRequestData();

        if (empty($data['payment_id']) || empty($data['transaction_id'])) {
            $this->sendError('payment_id and transaction_id are required', 400);
            return;
        }

        try {
            // Verify payment with gateway (Razorpay, etc.)
            // For now, just mark as completed

            $stmt = $this->db->prepare("
                UPDATE payments
                SET status = 'completed', paid_at = NOW(), gateway_payment_id = ?
                WHERE id = ? AND user_id = ? AND transaction_id = ?
            ");
            $stmt->execute([
                $data['gateway_payment_id'] ?? '',
                $data['payment_id'],
                $authUser['user_id'],
                $data['transaction_id']
            ]);

            if ($stmt->rowCount() === 0) {
                $this->sendError('Payment not found or already processed', 404);
                return;
            }

            $this->sendSuccess([], 'Payment verified successfully');

        } catch (\Exception $e) {
            error_log("Verify payment error: " . $e->getMessage());
            $this->sendError('Failed to verify payment', 500);
        }
    }

    public function getPaymentHistory(): void
    {
        $authUser = AuthMiddleware::getAuthUser();

        try {
            $stmt = $this->db->prepare("
                SELECT p.id, p.amount, p.currency, p.transaction_id, p.status,
                       p.paid_at, p.created_at, s.name as service_name
                FROM payments p
                INNER JOIN services s ON p.service_id = s.id
                WHERE p.user_id = ?
                ORDER BY p.created_at DESC
            ");
            $stmt->execute([$authUser['user_id']]);
            $payments = $stmt->fetchAll();

            foreach ($payments as &$payment) {
                $payment['amount'] = (float)$payment['amount'];
            }

            $this->sendSuccess(['payments' => $payments]);

        } catch (\Exception $e) {
            error_log("Get payment history error: " . $e->getMessage());
            $this->sendError('Failed to fetch payment history', 500);
        }
    }
}
