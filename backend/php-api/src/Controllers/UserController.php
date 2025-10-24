<?php

namespace App\Controllers;

use App\Config\Database;
use App\Middleware\AuthMiddleware;
use PDO;

class UserController extends BaseController
{
    private PDO $db;

    public function __construct()
    {
        parent::__construct();
        $this->db = Database::getConnection();
    }

    public function getProfile(): void
    {
        $authUser = AuthMiddleware::getAuthUser();

        try {
            $stmt = $this->db->prepare("
                SELECT u.id, u.email, u.full_name, u.phone, u.email_verified, u.phone_verified,
                       p.date_of_birth, p.time_of_birth, p.place_of_birth, p.latitude, p.longitude,
                       p.gender, p.marital_status, p.occupation, p.profile_picture,
                       p.language_preference, p.timezone
                FROM users u
                LEFT JOIN user_profiles p ON u.id = p.user_id
                WHERE u.id = ?
            ");
            $stmt->execute([$authUser['user_id']]);
            $profile = $stmt->fetch();

            if (!$profile) {
                $this->sendError('Profile not found', 404);
                return;
            }

            $this->sendSuccess(['profile' => $profile]);

        } catch (\Exception $e) {
            error_log("Get profile error: " . $e->getMessage());
            $this->sendError('Failed to fetch profile', 500);
        }
    }

    public function updateProfile(): void
    {
        $authUser = AuthMiddleware::getAuthUser();
        $data = $this->getRequestData();

        try {
            Database::beginTransaction();

            // Update user table
            if (isset($data['full_name']) || isset($data['phone'])) {
                $updates = [];
                $params = [];

                if (isset($data['full_name'])) {
                    $updates[] = "full_name = ?";
                    $params[] = $data['full_name'];
                }

                if (isset($data['phone'])) {
                    $updates[] = "phone = ?";
                    $params[] = $data['phone'];
                }

                if (!empty($updates)) {
                    $params[] = $authUser['user_id'];
                    $sql = "UPDATE users SET " . implode(', ', $updates) . " WHERE id = ?";
                    $stmt = $this->db->prepare($sql);
                    $stmt->execute($params);
                }
            }

            // Update user_profiles table
            $profileFields = [
                'date_of_birth', 'time_of_birth', 'place_of_birth', 'latitude', 'longitude',
                'gender', 'marital_status', 'occupation', 'profile_picture',
                'language_preference', 'timezone'
            ];

            $updates = [];
            $params = [];

            foreach ($profileFields as $field) {
                if (isset($data[$field])) {
                    $updates[] = "$field = ?";
                    $params[] = $data[$field];
                }
            }

            if (!empty($updates)) {
                $params[] = $authUser['user_id'];
                $sql = "UPDATE user_profiles SET " . implode(', ', $updates) . " WHERE user_id = ?";
                $stmt = $this->db->prepare($sql);
                $stmt->execute($params);
            }

            Database::commit();

            $this->sendSuccess([], 'Profile updated successfully');

        } catch (\Exception $e) {
            Database::rollBack();
            error_log("Update profile error: " . $e->getMessage());
            $this->sendError('Failed to update profile', 500);
        }
    }

    public function getReports(): void
    {
        $authUser = AuthMiddleware::getAuthUser();

        try {
            $stmt = $this->db->prepare("
                SELECT r.id, r.report_title, r.report_type, r.status, r.file_url,
                       r.generated_at, r.created_at, s.name as service_name, s.icon as service_icon
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
}
