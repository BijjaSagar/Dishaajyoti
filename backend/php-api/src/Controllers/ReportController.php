<?php

namespace App\Controllers;

use App\Config\Database;
use App\Middleware\AuthMiddleware;
use App\Services\AIService;
use PDO;

class ReportController extends BaseController
{
    private PDO $db;
    private AIService $aiService;

    public function __construct()
    {
        parent::__construct();
        $this->db = Database::getConnection();
        $this->aiService = new AIService();
    }

    public function generateReport(): void
    {
        $authUser = AuthMiddleware::getAuthUser();
        $data = $this->getRequestData();

        if (empty($data['service_id']) || empty($data['payment_id'])) {
            $this->sendError('service_id and payment_id are required', 400);
            return;
        }

        try {
            // Verify payment
            $stmt = $this->db->prepare("
                SELECT id, status
                FROM payments
                WHERE id = ? AND user_id = ? AND service_id = ?
            ");
            $stmt->execute([$data['payment_id'], $authUser['user_id'], $data['service_id']]);
            $payment = $stmt->fetch();

            if (!$payment || $payment['status'] !== 'completed') {
                $this->sendError('Payment not found or not completed', 403);
                return;
            }

            // Get service details
            $stmt = $this->db->prepare("
                SELECT id, name, ai_agent_type
                FROM services
                WHERE id = ? AND is_active = 1
            ");
            $stmt->execute([$data['service_id']]);
            $service = $stmt->fetch();

            if (!$service) {
                $this->sendError('Service not found', 404);
                return;
            }

            // Get user profile for report
            $stmt = $this->db->prepare("
                SELECT u.full_name, u.email, u.phone,
                       p.date_of_birth, p.time_of_birth, p.place_of_birth,
                       p.latitude, p.longitude, p.gender, p.marital_status
                FROM users u
                LEFT JOIN user_profiles p ON u.id = p.user_id
                WHERE u.id = ?
            ");
            $stmt->execute([$authUser['user_id']]);
            $userProfile = $stmt->fetch();

            // Create report record
            $reportTitle = $service['name'] . ' - ' . date('d M Y');

            $stmt = $this->db->prepare("
                INSERT INTO reports (
                    user_id, service_id, payment_id, report_title, report_type,
                    status, generation_metadata, created_at
                )
                VALUES (?, ?, ?, ?, ?, 'processing', ?, NOW())
            ");
            $stmt->execute([
                $authUser['user_id'],
                $data['service_id'],
                $data['payment_id'],
                $reportTitle,
                $service['ai_agent_type'],
                json_encode(array_merge($userProfile, $data['report_data'] ?? []))
            ]);
            $reportId = $this->db->lastInsertId();

            // Generate report using AI service (async in production)
            try {
                $reportData = array_merge($userProfile, $data['report_data'] ?? []);
                $aiReport = $this->aiService->generateReport($service['ai_agent_type'], $reportData);

                // Update report with generated content
                $stmt = $this->db->prepare("
                    UPDATE reports
                    SET status = 'completed', generated_at = NOW()
                    WHERE id = ?
                ");
                $stmt->execute([$reportId]);

                // Store report sections
                if (isset($aiReport['report']['sections'])) {
                    foreach ($aiReport['report']['sections'] as $index => $section) {
                        $stmt = $this->db->prepare("
                            INSERT INTO report_details (report_id, section_name, section_content, section_order)
                            VALUES (?, ?, ?, ?)
                        ");
                        $stmt->execute([
                            $reportId,
                            $section['title'] ?? "Section " . ($index + 1),
                            $section['content'] ?? '',
                            $index
                        ]);
                    }
                }

            } catch (\Exception $e) {
                // Mark report as failed
                $stmt = $this->db->prepare("
                    UPDATE reports
                    SET status = 'failed', error_message = ?
                    WHERE id = ?
                ");
                $stmt->execute([$e->getMessage(), $reportId]);
                throw $e;
            }

            $this->sendSuccess([
                'report_id' => $reportId,
                'status' => 'completed',
                'title' => $reportTitle
            ], 'Report generated successfully', 201);

        } catch (\Exception $e) {
            error_log("Generate report error: " . $e->getMessage());
            $this->sendError('Failed to generate report: ' . $e->getMessage(), 500);
        }
    }

    public function getReports(): void
    {
        $authUser = AuthMiddleware::getAuthUser();

        try {
            $stmt = $this->db->prepare("
                SELECT r.id, r.report_title, r.report_type, r.status, r.file_url,
                       r.generated_at, r.created_at, s.name as service_name
                FROM reports r
                INNER JOIN services s ON r.service_id = s.id
                WHERE r.user_id = ?
                ORDER BY r.created_at DESC
            ");
            $stmt->execute([$authUser['user_id']]);
            $reports = $stmt->fetchAll();

            $this->sendSuccess(['reports' => $reports]);

        } catch (\Exception $e) {
            error_log("Get reports error: " . $e->getMessage());
            $this->sendError('Failed to fetch reports', 500);
        }
    }

    public function getReportById(int $reportId): void
    {
        $authUser = AuthMiddleware::getAuthUser();

        try {
            $stmt = $this->db->prepare("
                SELECT r.*, s.name as service_name
                FROM reports r
                INNER JOIN services s ON r.service_id = s.id
                WHERE r.id = ? AND r.user_id = ?
            ");
            $stmt->execute([$reportId, $authUser['user_id']]);
            $report = $stmt->fetch();

            if (!$report) {
                $this->sendError('Report not found', 404);
                return;
            }

            // Get report sections
            $stmt = $this->db->prepare("
                SELECT section_name, section_content
                FROM report_details
                WHERE report_id = ?
                ORDER BY section_order ASC
            ");
            $stmt->execute([$reportId]);
            $report['sections'] = $stmt->fetchAll();

            $this->sendSuccess(['report' => $report]);

        } catch (\Exception $e) {
            error_log("Get report error: " . $e->getMessage());
            $this->sendError('Failed to fetch report', 500);
        }
    }

    public function deleteReport(int $reportId): void
    {
        $authUser = AuthMiddleware::getAuthUser();

        try {
            $stmt = $this->db->prepare("
                DELETE FROM reports
                WHERE id = ? AND user_id = ?
            ");
            $stmt->execute([$reportId, $authUser['user_id']]);

            if ($stmt->rowCount() === 0) {
                $this->sendError('Report not found', 404);
                return;
            }

            $this->sendSuccess([], 'Report deleted successfully');

        } catch (\Exception $e) {
            error_log("Delete report error: " . $e->getMessage());
            $this->sendError('Failed to delete report', 500);
        }
    }
}
