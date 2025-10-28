import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../models/kundali_with_chart_model.dart';
import 'database_helper.dart';

/// Kundali Sync Manager
/// Handles background synchronization with server
class KundaliSyncManager {
  static final KundaliSyncManager instance = KundaliSyncManager._init();

  KundaliSyncManager._init();

  final Dio _dio = Dio();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;
  Timer? _retryTimer;

  // Configuration
  static const String _baseUrl =
      'https://your-backend-url.com/api/v1'; // TODO: Update with actual URL
  static const int _maxRetries = 3;

  /// Initialize sync manager
  void initialize() {
    registerConnectivityListener();
    _startPeriodicSync();
  }

  /// Register for connectivity changes
  void registerConnectivityListener() {
    // TODO: Fix connectivity_plus API compatibility
    // The API has changed in newer versions
    // For now, sync manager is disabled
    /*
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        // Network is available, trigger sync
        syncPendingKundalis();
      }
    });
    */
  }

  /// Start periodic sync (every 5 minutes)
  void _startPeriodicSync() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncPendingKundalis();
    });
  }

  /// Sync pending Kundalis with server
  Future<void> syncPendingKundalis() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final pendingKundalis =
          await DatabaseHelper.instance.getPendingSyncKundalis();

      for (var kundali in pendingKundalis) {
        try {
          final success = await syncKundali(kundali);
          if (!success) {
            // Mark as failed and continue
            await DatabaseHelper.instance.updateSyncStatus(
              kundali.id,
              'failed',
            );
          }
        } catch (e) {
          // Continue with next kundali
          print('Failed to sync kundali ${kundali.id}: $e');
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync single Kundali
  Future<bool> syncKundali(KundaliWithChart kundali) async {
    try {
      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Prepare data for server
      final data = {
        'name': kundali.name,
        'date_of_birth':
            '${kundali.dateOfBirth.year}-${kundali.dateOfBirth.month.toString().padLeft(2, '0')}-${kundali.dateOfBirth.day.toString().padLeft(2, '0')}',
        'time_of_birth': kundali.timeOfBirth,
        'place_of_birth': kundali.placeOfBirth,
        'chart_style': kundali.chartStyle.name,
        'chart_data': kundali.chartData.toJson(),
      };

      // Send to server with retry logic
      Response? response;
      int retries = 0;

      while (retries < _maxRetries) {
        try {
          response = await _dio.post(
            '$_baseUrl/kundali/generate_with_chart',
            data: data,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                // TODO: Add authentication token
                // 'Authorization': 'Bearer $token',
              },
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Success
            final serverId = response.data['data']?['server_id'] ??
                response.data['data']?['kundali_id'];

            // Update local record
            await DatabaseHelper.instance.updateSyncStatus(
              kundali.id,
              'synced',
              serverId: serverId?.toString(),
            );

            return true;
          }

          retries++;
          if (retries < _maxRetries) {
            await Future.delayed(Duration(seconds: retries * 2));
          }
        } on DioException catch (e) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            retries++;
            if (retries < _maxRetries) {
              await Future.delayed(Duration(seconds: retries * 2));
            }
          } else {
            // Other errors, don't retry
            break;
          }
        }
      }

      return false;
    } catch (e) {
      print('Sync error: $e');
      return false;
    }
  }

  /// Pull Kundalis from server
  Future<void> pullFromServer(String userId) async {
    try {
      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return;
      }

      final response = await _dio.get(
        '$_baseUrl/kundali/list',
        queryParameters: {'user_id': userId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // TODO: Add authentication token
            // 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final kundalis = response.data['data']?['kundalis'] as List?;

        if (kundalis != null) {
          for (var kundaliData in kundalis) {
            // Check if already exists locally
            final existingKundali = await DatabaseHelper.instance
                .getKundaliWithChart(kundaliData['id'].toString());

            if (existingKundali == null) {
              // TODO: Convert server data to KundaliWithChart and save
              // This requires proper data mapping from server format
            }
          }
        }
      }
    } catch (e) {
      print('Pull from server error: $e');
    }
  }

  /// Get sync status
  Future<SyncStatus> getSyncStatus() async {
    try {
      final pendingKundalis =
          await DatabaseHelper.instance.getPendingSyncKundalis();

      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      return SyncStatus(
        pendingCount: pendingKundalis.length,
        isOnline: isOnline,
        isSyncing: _isSyncing,
        lastSyncTime: DateTime.now(), // TODO: Store actual last sync time
      );
    } catch (e) {
      return SyncStatus(
        pendingCount: 0,
        isOnline: false,
        isSyncing: false,
        lastSyncTime: null,
      );
    }
  }

  /// Force sync now
  Future<void> forceSyncNow() async {
    await syncPendingKundalis();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
  }
}

/// Sync Status model
class SyncStatus {
  final int pendingCount;
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncTime;

  SyncStatus({
    required this.pendingCount,
    required this.isOnline,
    required this.isSyncing,
    this.lastSyncTime,
  });

  bool get hasPendingSync => pendingCount > 0;

  String get statusMessage {
    if (isSyncing) return 'Syncing...';
    if (!isOnline) return 'Offline';
    if (hasPendingSync) return '$pendingCount pending';
    return 'All synced';
  }
}
