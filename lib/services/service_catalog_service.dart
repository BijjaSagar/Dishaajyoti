import '../models/service_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Service catalog service for browsing and retrieving available services
class ServiceCatalogService {
  final ApiService _apiService;

  ServiceCatalogService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get all available services
  ///
  /// Requirements: 7.1
  Future<List<Service>> getAllServices() async {
    try {
      final response = await _apiService.get(
        AppConstants.servicesEndpoint,
      );

      final List<dynamic> servicesJson =
          response.data['services'] ?? response.data;
      return servicesJson.map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get service by ID
  Future<Service> getServiceById(String serviceId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.servicesEndpoint}/$serviceId',
      );

      return Service.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get services by category
  Future<List<Service>> getServicesByCategory(String category) async {
    try {
      final response = await _apiService.get(
        AppConstants.servicesEndpoint,
        queryParameters: {'category': category},
      );

      final List<dynamic> servicesJson =
          response.data['services'] ?? response.data;
      return servicesJson.map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Search services by keyword
  Future<List<Service>> searchServices(String keyword) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.servicesEndpoint}/search',
        queryParameters: {'q': keyword},
      );

      final List<dynamic> servicesJson =
          response.data['services'] ?? response.data;
      return servicesJson.map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get featured services
  Future<List<Service>> getFeaturedServices() async {
    try {
      final response = await _apiService.get(
        '${AppConstants.servicesEndpoint}/featured',
      );

      final List<dynamic> servicesJson =
          response.data['services'] ?? response.data;
      return servicesJson.map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get service categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _apiService.get(
        '${AppConstants.servicesEndpoint}/categories',
      );

      final List<dynamic> categoriesJson =
          response.data['categories'] ?? response.data;
      return categoriesJson.map((category) => category.toString()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
