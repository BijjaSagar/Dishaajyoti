<?php

namespace App\Controllers;

use App\Config\Database;
use App\Middleware\AuthMiddleware;
use Firebase\JWT\JWT;
use PDO;

class AuthController extends BaseController
{
    private PDO $db;

    public function __construct()
    {
        parent::__construct();
        $this->db = Database::getConnection();
    }

    public function register(): void
    {
        $data = $this->getRequestData();

        // Validate required fields
        $required = ['email', 'password', 'full_name', 'phone'];
        foreach ($required as $field) {
            if (empty($data[$field])) {
                $this->sendError("Field '$field' is required", 400);
                return;
            }
        }

        // Validate email format
        if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            $this->sendError('Invalid email format', 400);
            return;
        }

        // Validate password length
        if (strlen($data['password']) < 8) {
            $this->sendError('Password must be at least 8 characters', 400);
            return;
        }

        try {
            // Check if email already exists
            $stmt = $this->db->prepare("SELECT id FROM users WHERE email = ?");
            $stmt->execute([$data['email']]);
            if ($stmt->fetch()) {
                $this->sendError('Email already registered', 409);
                return;
            }

            // Check if phone already exists
            $stmt = $this->db->prepare("SELECT id FROM users WHERE phone = ?");
            $stmt->execute([$data['phone']]);
            if ($stmt->fetch()) {
                $this->sendError('Phone number already registered', 409);
                return;
            }

            // Hash password
            $passwordHash = password_hash($data['password'], PASSWORD_BCRYPT);

            // Insert user
            $stmt = $this->db->prepare("
                INSERT INTO users (email, phone, password_hash, full_name, created_at)
                VALUES (?, ?, ?, ?, NOW())
            ");
            $stmt->execute([
                $data['email'],
                $data['phone'],
                $passwordHash,
                $data['full_name']
            ]);

            $userId = $this->db->lastInsertId();

            // Create user profile
            $stmt = $this->db->prepare("
                INSERT INTO user_profiles (user_id, created_at)
                VALUES (?, NOW())
            ");
            $stmt->execute([$userId]);

            // Generate tokens
            $token = $this->generateToken($userId, $data['email']);
            $refreshToken = $this->generateRefreshToken($userId);

            $this->sendSuccess([
                'user' => [
                    'id' => $userId,
                    'email' => $data['email'],
                    'full_name' => $data['full_name'],
                    'phone' => $data['phone']
                ],
                'token' => $token,
                'refresh_token' => $refreshToken
            ], 'Registration successful', 201);

        } catch (\Exception $e) {
            error_log("Registration error: " . $e->getMessage());
            $this->sendError('Registration failed', 500);
        }
    }

    public function login(): void
    {
        $data = $this->getRequestData();

        if (empty($data['email']) || empty($data['password'])) {
            $this->sendError('Email and password are required', 400);
            return;
        }

        try {
            $stmt = $this->db->prepare("
                SELECT id, email, password_hash, full_name, phone, is_active
                FROM users
                WHERE email = ?
            ");
            $stmt->execute([$data['email']]);
            $user = $stmt->fetch();

            if (!$user || !password_verify($data['password'], $user['password_hash'])) {
                $this->sendError('Invalid credentials', 401);
                return;
            }

            if (!$user['is_active']) {
                $this->sendError('Account is inactive', 403);
                return;
            }

            // Update last login
            $stmt = $this->db->prepare("UPDATE users SET last_login_at = NOW() WHERE id = ?");
            $stmt->execute([$user['id']]);

            // Generate tokens
            $token = $this->generateToken($user['id'], $user['email']);
            $refreshToken = $this->generateRefreshToken($user['id']);

            $this->sendSuccess([
                'user' => [
                    'id' => $user['id'],
                    'email' => $user['email'],
                    'full_name' => $user['full_name'],
                    'phone' => $user['phone']
                ],
                'token' => $token,
                'refresh_token' => $refreshToken
            ], 'Login successful');

        } catch (\Exception $e) {
            error_log("Login error: " . $e->getMessage());
            $this->sendError('Login failed', 500);
        }
    }

    public function logout(): void
    {
        // In a production app, you might want to blacklist the token
        $this->sendSuccess([], 'Logout successful');
    }

    public function getCurrentUser(): void
    {
        $authUser = AuthMiddleware::getAuthUser();

        try {
            $stmt = $this->db->prepare("
                SELECT u.id, u.email, u.full_name, u.phone, u.email_verified, u.phone_verified,
                       p.date_of_birth, p.time_of_birth, p.place_of_birth, p.gender,
                       p.marital_status, p.occupation, p.profile_picture
                FROM users u
                LEFT JOIN user_profiles p ON u.id = p.user_id
                WHERE u.id = ?
            ");
            $stmt->execute([$authUser['user_id']]);
            $user = $stmt->fetch();

            if (!$user) {
                $this->sendError('User not found', 404);
                return;
            }

            $this->sendSuccess(['user' => $user]);

        } catch (\Exception $e) {
            error_log("Get current user error: " . $e->getMessage());
            $this->sendError('Failed to fetch user data', 500);
        }
    }

    public function refreshToken(): void
    {
        $data = $this->getRequestData();

        if (empty($data['refresh_token'])) {
            $this->sendError('Refresh token is required', 400);
            return;
        }

        try {
            $secret = $_ENV['JWT_SECRET'];
            $algorithm = $_ENV['JWT_ALGORITHM'] ?? 'HS256';

            $decoded = JWT::decode($data['refresh_token'], new \Firebase\JWT\Key($secret, $algorithm));

            if ($decoded->type !== 'refresh') {
                $this->sendError('Invalid token type', 401);
                return;
            }

            // Generate new tokens
            $token = $this->generateToken($decoded->user_id, $decoded->email);
            $refreshToken = $this->generateRefreshToken($decoded->user_id);

            $this->sendSuccess([
                'token' => $token,
                'refresh_token' => $refreshToken
            ]);

        } catch (\Exception $e) {
            $this->sendError('Invalid or expired refresh token', 401);
        }
    }

    private function generateToken(int $userId, string $email): string
    {
        $payload = [
            'user_id' => $userId,
            'email' => $email,
            'type' => 'access',
            'iat' => time(),
            'exp' => time() + (int)($_ENV['JWT_EXPIRY'] ?? 3600)
        ];

        return JWT::encode($payload, $_ENV['JWT_SECRET'], $_ENV['JWT_ALGORITHM'] ?? 'HS256');
    }

    private function generateRefreshToken(int $userId): string
    {
        $payload = [
            'user_id' => $userId,
            'type' => 'refresh',
            'iat' => time(),
            'exp' => time() + (int)($_ENV['JWT_REFRESH_EXPIRY'] ?? 2592000) // 30 days
        ];

        return JWT::encode($payload, $_ENV['JWT_SECRET'], $_ENV['JWT_ALGORITHM'] ?? 'HS256');
    }
}
