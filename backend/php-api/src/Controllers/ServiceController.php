<?php

namespace App\Controllers;

use App\Config\Database;
use PDO;

class ServiceController extends BaseController
{
    private PDO $db;

    public function __construct()
    {
        parent::__construct();
        $this->db = Database::getConnection();
    }

    public function getAllServices(): void
    {
        try {
            $category = $this->getParam('category');
            $query = $this->getParam('q');

            $sql = "
                SELECT s.*, c.name as category_name, c.slug as category_slug
                FROM services s
                INNER JOIN categories c ON s.category_id = c.id
                WHERE s.is_active = 1
            ";

            $params = [];

            if ($category) {
                $sql .= " AND c.slug = ?";
                $params[] = $category;
            }

            if ($query) {
                $sql .= " AND (s.name LIKE ? OR s.description LIKE ?)";
                $params[] = "%$query%";
                $params[] = "%$query%";
            }

            $sql .= " ORDER BY s.is_featured DESC, s.display_order ASC, s.name ASC";

            $stmt = $this->db->prepare($sql);
            $stmt->execute($params);
            $services = $stmt->fetchAll();

            // Fetch features for each service
            foreach ($services as &$service) {
                $service['features'] = $this->getServiceFeatures($service['id']);
                $service['price'] = (float)$service['price'];
            }

            $this->sendSuccess(['services' => $services]);

        } catch (\Exception $e) {
            error_log("Get services error: " . $e->getMessage());
            $this->sendError('Failed to fetch services', 500);
        }
    }

    public function getServiceById(string $id): void
    {
        try {
            $stmt = $this->db->prepare("
                SELECT s.*, c.name as category_name, c.slug as category_slug
                FROM services s
                INNER JOIN categories c ON s.category_id = c.id
                WHERE s.id = ? AND s.is_active = 1
            ");
            $stmt->execute([$id]);
            $service = $stmt->fetch();

            if (!$service) {
                $this->sendError('Service not found', 404);
                return;
            }

            $service['features'] = $this->getServiceFeatures($service['id']);
            $service['price'] = (float)$service['price'];

            $this->sendSuccess(['service' => $service]);

        } catch (\Exception $e) {
            error_log("Get service error: " . $e->getMessage());
            $this->sendError('Failed to fetch service', 500);
        }
    }

    public function getCategories(): void
    {
        try {
            $stmt = $this->db->prepare("
                SELECT id, name, slug, description, icon
                FROM categories
                WHERE is_active = 1
                ORDER BY display_order ASC, name ASC
            ");
            $stmt->execute();
            $categories = $stmt->fetchAll();

            $this->sendSuccess(['categories' => $categories]);

        } catch (\Exception $e) {
            error_log("Get categories error: " . $e->getMessage());
            $this->sendError('Failed to fetch categories', 500);
        }
    }

    public function getFeaturedServices(): void
    {
        try {
            $stmt = $this->db->prepare("
                SELECT s.*, c.name as category_name, c.slug as category_slug
                FROM services s
                INNER JOIN categories c ON s.category_id = c.id
                WHERE s.is_active = 1 AND s.is_featured = 1
                ORDER BY s.display_order ASC, s.name ASC
            ");
            $stmt->execute();
            $services = $stmt->fetchAll();

            foreach ($services as &$service) {
                $service['features'] = $this->getServiceFeatures($service['id']);
                $service['price'] = (float)$service['price'];
            }

            $this->sendSuccess(['services' => $services]);

        } catch (\Exception $e) {
            error_log("Get featured services error: " . $e->getMessage());
            $this->sendError('Failed to fetch featured services', 500);
        }
    }

    private function getServiceFeatures(int $serviceId): array
    {
        $stmt = $this->db->prepare("
            SELECT feature_text
            FROM service_features
            WHERE service_id = ?
            ORDER BY display_order ASC
        ");
        $stmt->execute([$serviceId]);

        return array_column($stmt->fetchAll(), 'feature_text');
    }
}
