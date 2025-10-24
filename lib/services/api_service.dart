import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

/// Base API service class with Dio configuration and interceptors
class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: Duration(seconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
        sendTimeout: Duration(seconds: AppConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  /// Setup request/response interceptors
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests
          final token =
              await _secureStorage.read(key: AppConstants.authTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log request in debug mode
          if (AppConstants.enableDebugLogging) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
            print('Headers: ${options.headers}');
            print('Data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response in debug mode
          if (AppConstants.enableDebugLogging) {
            print(
                'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
            print('Data: ${response.data}');
          }

          return handler.next(response);
        },
        onError: (error, handler) async {
          // Log error in debug mode
          if (AppConstants.enableDebugLogging) {
            print(
                'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
            print('Message: ${error.message}');
            print('Data: ${error.response?.data}');
          }

          // Handle 401 Unauthorized - attempt token refresh
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request
              return handler.resolve(await _retry(error.requestOptions));
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Refresh authentication token
  ///
  /// Requirements: 11.4
  Future<bool> _refreshToken() async {
    try {
      final refreshToken =
          await _secureStorage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        AppConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refreshToken'];

        await _secureStorage.write(
            key: AppConstants.authTokenKey, value: newToken);
        await _secureStorage.write(
            key: AppConstants.refreshTokenKey, value: newRefreshToken);

        // Store token expiry time (default 15 minutes from now)
        final tokenExpiry = DateTime.now().add(const Duration(minutes: 15));
        await _secureStorage.write(
          key: AppConstants.tokenExpiryKey,
          value: tokenExpiry.toIso8601String(),
        );

        // Update last activity timestamp
        await _secureStorage.write(
          key: AppConstants.lastActivityKey,
          value: DateTime.now().toIso8601String(),
        );

        return true;
      }

      return false;
    } catch (e) {
      // ignore: avoid_print
      print('Token refresh failed: $e');
      return false;
    }
  }

  /// Retry a failed request
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// GET request with error handling and retry logic
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    int retryCount = 0,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      return _handleError(
          e,
          retryCount,
          () => get<T>(
                path,
                queryParameters: queryParameters,
                options: options,
                retryCount: retryCount + 1,
              ));
    }
  }

  /// POST request with error handling and retry logic
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    int retryCount = 0,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      return _handleError(
          e,
          retryCount,
          () => post<T>(
                path,
                data: data,
                queryParameters: queryParameters,
                options: options,
                retryCount: retryCount + 1,
              ));
    }
  }

  /// PUT request with error handling and retry logic
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    int retryCount = 0,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      return _handleError(
          e,
          retryCount,
          () => put<T>(
                path,
                data: data,
                queryParameters: queryParameters,
                options: options,
                retryCount: retryCount + 1,
              ));
    }
  }

  /// DELETE request with error handling and retry logic
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    int retryCount = 0,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      return _handleError(
          e,
          retryCount,
          () => delete<T>(
                path,
                data: data,
                queryParameters: queryParameters,
                options: options,
                retryCount: retryCount + 1,
              ));
    }
  }

  /// Handle errors with retry logic
  Future<Response<T>> _handleError<T>(
    DioException error,
    int retryCount,
    Future<Response<T>> Function() retryFunction,
  ) async {
    // Check if error is retryable
    if (_isRetryable(error) && retryCount < AppConstants.maxRetryAttempts) {
      // Wait before retrying with exponential backoff
      await Future.delayed(
        Duration(seconds: AppConstants.retryDelaySeconds * (retryCount + 1)),
      );
      return retryFunction();
    }

    // Throw custom exception with user-friendly message
    throw _mapDioException(error);
  }

  /// Check if error is retryable
  bool _isRetryable(DioException error) {
    // Retry on network errors and 5xx server errors
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  /// Map DioException to custom ApiException
  ApiException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: AppConstants.networkErrorMessage,
          statusCode: null,
          type: ApiExceptionType.timeout,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: AppConstants.networkErrorMessage,
          statusCode: null,
          type: ApiExceptionType.network,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ??
            _getDefaultErrorMessage(statusCode);

        return ApiException(
          message: message,
          statusCode: statusCode,
          type: _getExceptionType(statusCode),
          data: error.response?.data,
        );

      default:
        return ApiException(
          message: AppConstants.unknownErrorMessage,
          statusCode: null,
          type: ApiExceptionType.unknown,
        );
    }
  }

  /// Get default error message based on status code
  String _getDefaultErrorMessage(int? statusCode) {
    if (statusCode == null) return AppConstants.unknownErrorMessage;

    if (statusCode >= 500) {
      return AppConstants.serverErrorMessage;
    } else if (statusCode == 401) {
      return AppConstants.sessionExpiredMessage;
    } else if (statusCode == 403) {
      return 'Access denied. You do not have permission to perform this action.';
    } else if (statusCode == 404) {
      return 'The requested resource was not found.';
    } else if (statusCode >= 400) {
      return 'Invalid request. Please check your input and try again.';
    }

    return AppConstants.unknownErrorMessage;
  }

  /// Get exception type based on status code
  ApiExceptionType _getExceptionType(int? statusCode) {
    if (statusCode == null) return ApiExceptionType.unknown;

    if (statusCode == 401) {
      return ApiExceptionType.unauthorized;
    } else if (statusCode == 403) {
      return ApiExceptionType.forbidden;
    } else if (statusCode == 404) {
      return ApiExceptionType.notFound;
    } else if (statusCode >= 400 && statusCode < 500) {
      return ApiExceptionType.validation;
    } else if (statusCode >= 500) {
      return ApiExceptionType.server;
    }

    return ApiExceptionType.unknown;
  }

  /// Get Dio instance for advanced usage
  Dio get dio => _dio;
}

/// Custom API exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiExceptionType type;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    required this.type,
    this.data,
  });

  @override
  String toString() => message;
}

/// API exception types
enum ApiExceptionType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  unknown,
}
