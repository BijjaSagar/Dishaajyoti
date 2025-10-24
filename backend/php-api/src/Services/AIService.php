<?php

namespace App\Services;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;

class AIService
{
    private Client $client;
    private string $baseUrl;
    private string $apiKey;

    public function __construct()
    {
        $this->baseUrl = $_ENV['AI_SERVICE_URL'] ?? 'http://localhost:5000';
        $this->apiKey = $_ENV['AI_SERVICE_API_KEY'] ?? '';

        $this->client = new Client([
            'base_uri' => $this->baseUrl,
            'timeout' => 60,
            'headers' => [
                'Content-Type' => 'application/json',
                'X-API-Key' => $this->apiKey
            ]
        ]);
    }

    /**
     * Query AI agent with a question
     *
     * @param string $agentType The type of agent (jyotisha, vastu, numerology, etc.)
     * @param string $query The user's question
     * @param array $context Additional context data
     * @return array Response from AI service
     * @throws \RuntimeException
     */
    public function query(string $agentType, string $query, array $context = []): array
    {
        try {
            $response = $this->client->post('/api/query', [
                'json' => [
                    'agent_type' => $agentType,
                    'query' => $query,
                    'context' => $context
                ]
            ]);

            $data = json_decode($response->getBody()->getContents(), true);

            if (!$data || !isset($data['answer'])) {
                throw new \RuntimeException('Invalid response from AI service');
            }

            return $data;

        } catch (GuzzleException $e) {
            error_log("AI Service error: " . $e->getMessage());
            throw new \RuntimeException('AI service is unavailable: ' . $e->getMessage());
        }
    }

    /**
     * Chat with AI agent (conversational)
     *
     * @param string $agentType The type of agent
     * @param string $message The user's message
     * @param array $history Chat history
     * @param array $context Additional context
     * @return array Response from AI service
     * @throws \RuntimeException
     */
    public function chat(string $agentType, string $message, array $history = [], array $context = []): array
    {
        try {
            $response = $this->client->post('/api/chat', [
                'json' => [
                    'agent_type' => $agentType,
                    'message' => $message,
                    'history' => $history,
                    'context' => $context
                ]
            ]);

            $data = json_decode($response->getBody()->getContents(), true);

            if (!$data || !isset($data['answer'])) {
                throw new \RuntimeException('Invalid response from AI service');
            }

            return $data;

        } catch (GuzzleException $e) {
            error_log("AI Service chat error: " . $e->getMessage());
            throw new \RuntimeException('AI service is unavailable: ' . $e->getMessage());
        }
    }

    /**
     * Generate a complete report using AI
     *
     * @param string $agentType The type of agent
     * @param array $data Input data for report generation
     * @return array Generated report
     * @throws \RuntimeException
     */
    public function generateReport(string $agentType, array $data): array
    {
        try {
            $response = $this->client->post('/api/generate-report', [
                'json' => [
                    'agent_type' => $agentType,
                    'data' => $data
                ],
                'timeout' => 120 // Reports may take longer
            ]);

            $responseData = json_decode($response->getBody()->getContents(), true);

            if (!$responseData || !isset($responseData['report'])) {
                throw new \RuntimeException('Invalid response from AI service');
            }

            return $responseData;

        } catch (GuzzleException $e) {
            error_log("AI Service report generation error: " . $e->getMessage());
            throw new \RuntimeException('Failed to generate report: ' . $e->getMessage());
        }
    }

    /**
     * Check if AI service is healthy
     *
     * @return bool
     */
    public function healthCheck(): bool
    {
        try {
            $response = $this->client->get('/health');
            return $response->getStatusCode() === 200;
        } catch (GuzzleException $e) {
            return false;
        }
    }
}
