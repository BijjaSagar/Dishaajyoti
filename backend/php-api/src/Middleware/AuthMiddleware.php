<?php

namespace App\Middleware;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Exception;

class AuthMiddleware
{
    public static function authenticate(): ?array
    {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;

        if (!$authHeader) {
            http_response_code(401);
            echo json_encode([
                'success' => false,
                'error' => 'Unauthorized',
                'message' => 'No authorization token provided'
            ]);
            exit();
        }

        // Extract token from "Bearer <token>"
        if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            $token = $matches[1];
        } else {
            http_response_code(401);
            echo json_encode([
                'success' => false,
                'error' => 'Unauthorized',
                'message' => 'Invalid authorization format'
            ]);
            exit();
        }

        try {
            $secret = $_ENV['JWT_SECRET'];
            $algorithm = $_ENV['JWT_ALGORITHM'] ?? 'HS256';

            $decoded = JWT::decode($token, new Key($secret, $algorithm));
            $userData = (array) $decoded;

            // Store user data in global scope for access in controllers
            $GLOBALS['auth_user'] = $userData;

            return $userData;

        } catch (Exception $e) {
            http_response_code(401);
            echo json_encode([
                'success' => false,
                'error' => 'Unauthorized',
                'message' => 'Invalid or expired token'
            ]);
            exit();
        }
    }

    public static function getAuthUser(): ?array
    {
        return $GLOBALS['auth_user'] ?? null;
    }
}
