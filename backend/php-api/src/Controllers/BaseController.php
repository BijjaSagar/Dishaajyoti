<?php

namespace App\Controllers;

class BaseController
{
    protected function getRequestData(): array
    {
        $contentType = $_SERVER['CONTENT_TYPE'] ?? '';

        if (str_contains($contentType, 'application/json')) {
            $json = file_get_contents('php://input');
            return json_decode($json, true) ?? [];
        }

        return array_merge($_POST, $_GET);
    }

    protected function sendSuccess($data = [], string $message = 'Success', int $statusCode = 200): void
    {
        http_response_code($statusCode);
        echo json_encode([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit();
    }

    protected function sendError(string $message, int $statusCode = 400, $errors = null): void
    {
        http_response_code($statusCode);
        $response = [
            'success' => false,
            'error' => $message
        ];

        if ($errors !== null) {
            $response['errors'] = $errors;
        }

        echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit();
    }

    protected function getQueryParams(): array
    {
        return $_GET;
    }

    protected function getParam(string $key, $default = null)
    {
        return $_GET[$key] ?? $_POST[$key] ?? $default;
    }
}
