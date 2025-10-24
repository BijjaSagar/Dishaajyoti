<?php

use App\Controllers\AuthController;
use App\Controllers\ServiceController;
use App\Controllers\UserController;
use App\Controllers\PaymentController;
use App\Controllers\ReportController;
use App\Controllers\AIController;
use App\Middleware\AuthMiddleware;

function route($method, $uri)
{
    // Remove trailing slash
    $uri = rtrim($uri, '/');

    // Public routes (no authentication required)
    $publicRoutes = [
        'POST /auth/register' => [AuthController::class, 'register'],
        'POST /auth/login' => [AuthController::class, 'login'],
        'POST /auth/refresh' => [AuthController::class, 'refreshToken'],
        'GET /services' => [ServiceController::class, 'getAllServices'],
        'GET /services/categories' => [ServiceController::class, 'getCategories'],
        'GET /services/featured' => [ServiceController::class, 'getFeaturedServices'],
    ];

    // Check for service ID routes
    if (preg_match('#^/services/([a-zA-Z0-9\-]+)$#', $uri, $matches)) {
        $serviceController = new ServiceController();
        $serviceController->getServiceById($matches[1]);
        return;
    }

    // Protected routes (require authentication)
    $protectedRoutes = [
        // User routes
        'GET /user/profile' => [UserController::class, 'getProfile'],
        'PUT /user/profile' => [UserController::class, 'updateProfile'],
        'GET /user/reports' => [UserController::class, 'getReports'],

        // Payment routes
        'POST /payments/create-order' => [PaymentController::class, 'createOrder'],
        'POST /payments/verify' => [PaymentController::class, 'verifyPayment'],
        'GET /payments/history' => [PaymentController::class, 'getPaymentHistory'],

        // Report routes
        'POST /reports/generate' => [ReportController::class, 'generateReport'],
        'GET /reports' => [ReportController::class, 'getReports'],

        // AI routes
        'POST /ai/query' => [AIController::class, 'query'],
        'POST /ai/chat' => [AIController::class, 'chat'],

        // Auth routes
        'POST /auth/logout' => [AuthController::class, 'logout'],
        'GET /auth/me' => [AuthController::class, 'getCurrentUser'],
    ];

    // Check report ID routes
    if (preg_match('#^/reports/([0-9]+)$#', $uri, $matches)) {
        AuthMiddleware::authenticate();
        $reportController = new ReportController();

        if ($method === 'GET') {
            $reportController->getReportById($matches[1]);
        } elseif ($method === 'DELETE') {
            $reportController->deleteReport($matches[1]);
        }
        return;
    }

    $routeKey = "$method $uri";

    // Check public routes
    if (isset($publicRoutes[$routeKey])) {
        [$controllerClass, $method] = $publicRoutes[$routeKey];
        $controller = new $controllerClass();
        $controller->$method();
        return;
    }

    // Check protected routes
    if (isset($protectedRoutes[$routeKey])) {
        // Authenticate user
        AuthMiddleware::authenticate();

        [$controllerClass, $method] = $protectedRoutes[$routeKey];
        $controller = new $controllerClass();
        $controller->$method();
        return;
    }

    // Route not found
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'error' => 'Route not found',
        'message' => "The route $routeKey does not exist"
    ]);
}
