<?php

namespace App\Controllers;

use App\Config\Database;
use App\Middleware\AuthMiddleware;
use App\Services\AIService;
use PDO;

class AIController extends BaseController
{
    private PDO $db;
    private AIService $aiService;

    public function __construct()
    {
        parent::__construct();
        $this->db = Database::getConnection();
        $this->aiService = new AIService();
    }

    /**
     * Handle AI query
     * POST /ai/query
     *
     * Request body:
     * {
     *   "service_id": 1,
     *   "query": "What does my birth chart say about career?",
     *   "context": {
     *     "date_of_birth": "1990-05-15",
     *     "time_of_birth": "14:30",
     *     "place_of_birth": "New Delhi"
     *   }
     * }
     */
    public function query(): void
    {
        $authUser = AuthMiddleware::getAuthUser();
        $data = $this->getRequestData();

        // Validate required fields
        if (empty($data['service_id']) || empty($data['query'])) {
            $this->sendError('service_id and query are required', 400);
            return;
        }

        try {
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

            // Get user profile data for context
            $stmt = $this->db->prepare("
                SELECT date_of_birth, time_of_birth, place_of_birth, latitude, longitude, gender
                FROM user_profiles
                WHERE user_id = ?
            ");
            $stmt->execute([$authUser['user_id']]);
            $userProfile = $stmt->fetch();

            // Merge user profile with provided context
            $context = array_merge(
                $userProfile ? array_filter($userProfile) : [],
                $data['context'] ?? []
            );

            // Store query in database
            $stmt = $this->db->prepare("
                INSERT INTO user_queries (user_id, service_id, query_text, query_metadata, created_at)
                VALUES (?, ?, ?, ?, NOW())
            ");
            $stmt->execute([
                $authUser['user_id'],
                $data['service_id'],
                $data['query'],
                json_encode($context)
            ]);
            $queryId = $this->db->lastInsertId();

            // Call AI service
            $startTime = microtime(true);
            $aiResponse = $this->aiService->query(
                $service['ai_agent_type'],
                $data['query'],
                $context
            );
            $processingTime = round((microtime(true) - $startTime) * 1000); // ms

            // Store AI response
            $stmt = $this->db->prepare("
                INSERT INTO ai_responses (
                    query_id, agent_type, response_text, source_documents,
                    confidence_score, processing_time_ms, tokens_used, created_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
            ");
            $stmt->execute([
                $queryId,
                $service['ai_agent_type'],
                $aiResponse['answer'] ?? '',
                json_encode($aiResponse['sources'] ?? []),
                $aiResponse['confidence'] ?? null,
                $processingTime,
                $aiResponse['tokens_used'] ?? null
            ]);

            $this->sendSuccess([
                'query_id' => $queryId,
                'answer' => $aiResponse['answer'],
                'sources' => $aiResponse['sources'] ?? [],
                'confidence' => $aiResponse['confidence'] ?? null,
                'agent_type' => $service['ai_agent_type']
            ]);

        } catch (\Exception $e) {
            error_log("AI query error: " . $e->getMessage());
            $this->sendError('Failed to process AI query: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Handle AI chat (conversational)
     * POST /ai/chat
     *
     * Request body:
     * {
     *   "service_id": 1,
     *   "message": "Tell me more about that",
     *   "session_id": "uuid",
     *   "context": {}
     * }
     */
    public function chat(): void
    {
        $authUser = AuthMiddleware::getAuthUser();
        $data = $this->getRequestData();

        if (empty($data['service_id']) || empty($data['message'])) {
            $this->sendError('service_id and message are required', 400);
            return;
        }

        try {
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

            $sessionId = $data['session_id'] ?? uniqid('session_', true);

            // Get chat history for this session
            $stmt = $this->db->prepare("
                SELECT uq.query_text, ar.response_text
                FROM user_queries uq
                LEFT JOIN ai_responses ar ON uq.id = ar.query_id
                WHERE uq.user_id = ? AND uq.session_id = ?
                ORDER BY uq.created_at ASC
                LIMIT 10
            ");
            $stmt->execute([$authUser['user_id'], $sessionId]);
            $history = $stmt->fetchAll();

            // Format chat history
            $chatHistory = [];
            foreach ($history as $item) {
                $chatHistory[] = [
                    'role' => 'user',
                    'content' => $item['query_text']
                ];
                if ($item['response_text']) {
                    $chatHistory[] = [
                        'role' => 'assistant',
                        'content' => $item['response_text']
                    ];
                }
            }

            // Store current message
            $stmt = $this->db->prepare("
                INSERT INTO user_queries (user_id, service_id, query_text, query_metadata, session_id, created_at)
                VALUES (?, ?, ?, ?, ?, NOW())
            ");
            $stmt->execute([
                $authUser['user_id'],
                $data['service_id'],
                $data['message'],
                json_encode($data['context'] ?? []),
                $sessionId
            ]);
            $queryId = $this->db->lastInsertId();

            // Call AI service with chat history
            $startTime = microtime(true);
            $aiResponse = $this->aiService->chat(
                $service['ai_agent_type'],
                $data['message'],
                $chatHistory,
                $data['context'] ?? []
            );
            $processingTime = round((microtime(true) - $startTime) * 1000);

            // Store AI response
            $stmt = $this->db->prepare("
                INSERT INTO ai_responses (
                    query_id, agent_type, response_text, source_documents,
                    confidence_score, processing_time_ms, tokens_used, created_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
            ");
            $stmt->execute([
                $queryId,
                $service['ai_agent_type'],
                $aiResponse['answer'] ?? '',
                json_encode($aiResponse['sources'] ?? []),
                $aiResponse['confidence'] ?? null,
                $processingTime,
                $aiResponse['tokens_used'] ?? null
            ]);

            $this->sendSuccess([
                'session_id' => $sessionId,
                'query_id' => $queryId,
                'answer' => $aiResponse['answer'],
                'sources' => $aiResponse['sources'] ?? [],
                'agent_type' => $service['ai_agent_type']
            ]);

        } catch (\Exception $e) {
            error_log("AI chat error: " . $e->getMessage());
            $this->sendError('Failed to process chat: ' . $e->getMessage(), 500);
        }
    }
}
