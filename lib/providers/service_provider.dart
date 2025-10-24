import 'package:flutter/foundation.dart';
import '../models/service_model.dart';
import '../services/service_catalog_service.dart';

/// Service catalog state provider
///
/// Manages service catalog data and operations
/// Requirements: 7.1
class ServiceProvider with ChangeNotifier {
  final ServiceCatalogService _serviceCatalogService;

  List<Service> _services = [];
  List<Service> _featuredServices = [];
  List<String> _categories = [];
  Service? _selectedService;
  bool _isLoading = false;
  String? _error;

  ServiceProvider({ServiceCatalogService? serviceCatalogService})
      : _serviceCatalogService =
            serviceCatalogService ?? ServiceCatalogService();

  // Getters
  List<Service> get services => _services;
  List<Service> get featuredServices => _featuredServices;
  List<String> get categories => _categories;
  Service? get selectedService => _selectedService;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasServices => _services.isNotEmpty;

  /// Load all available services
  ///
  /// Requirements: 7.1
  Future<bool> loadServices() async {
    _setLoading(true);
    _clearError();

    try {
      final services = await _serviceCatalogService.getAllServices();
      _services = services;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load featured services
  Future<bool> loadFeaturedServices() async {
    _setLoading(true);
    _clearError();

    try {
      final services = await _serviceCatalogService.getFeaturedServices();
      _featuredServices = services;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load service categories
  Future<bool> loadCategories() async {
    _setLoading(true);
    _clearError();

    try {
      final categories = await _serviceCatalogService.getCategories();
      _categories = categories;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load service by ID
  Future<bool> loadServiceById(String serviceId) async {
    _setLoading(true);
    _clearError();

    try {
      final service = await _serviceCatalogService.getServiceById(serviceId);
      _selectedService = service;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load services by category
  Future<bool> loadServicesByCategory(String category) async {
    _setLoading(true);
    _clearError();

    try {
      final services =
          await _serviceCatalogService.getServicesByCategory(category);
      _services = services;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Search services by keyword
  Future<bool> searchServices(String keyword) async {
    _setLoading(true);
    _clearError();

    try {
      final services = await _serviceCatalogService.searchServices(keyword);
      _services = services;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Select a service
  void selectService(Service service) {
    _selectedService = service;
    notifyListeners();
  }

  /// Clear selected service
  void clearSelectedService() {
    _selectedService = null;
    notifyListeners();
  }

  /// Get service by ID from cached list
  Service? getServiceById(String serviceId) {
    try {
      return _services.firstWhere((service) => service.id == serviceId);
    } catch (e) {
      return null;
    }
  }

  /// Filter services by price range
  List<Service> filterByPriceRange(int minPrice, int maxPrice) {
    return _services
        .where(
          (service) => service.price >= minPrice && service.price <= maxPrice,
        )
        .toList();
  }

  /// Get services sorted by price (ascending)
  List<Service> getServicesSortedByPrice({bool ascending = true}) {
    final sortedServices = List<Service>.from(_services);
    sortedServices.sort(
      (a, b) =>
          ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price),
    );
    return sortedServices;
  }

  /// Get active services only
  List<Service> getActiveServices() {
    return _services.where((service) => service.isActive).toList();
  }

  /// Refresh all service data
  Future<bool> refreshAll() async {
    final results = await Future.wait([
      loadServices(),
      loadFeaturedServices(),
      loadCategories(),
    ]);

    return results.every((result) => result);
  }

  /// Clear all service data
  void clearServices() {
    _services = [];
    _featuredServices = [];
    _categories = [];
    _selectedService = null;
    _clearError();
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
  }
}
