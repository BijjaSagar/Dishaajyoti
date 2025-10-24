import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring utilities
///
/// Provides tools for monitoring and optimizing app performance
/// Requirements: 1.3
class PerformanceUtils {
  /// Enable performance overlay in debug mode
  static bool get showPerformanceOverlay => kDebugMode;

  /// Log frame rendering time
  static void logFrameTime(String label) {
    if (!kDebugMode) return;

    SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      for (final timing in timings) {
        final buildTime = timing.buildDuration.inMilliseconds;
        final rasterTime = timing.rasterDuration.inMilliseconds;
        final totalTime = timing.totalSpan.inMilliseconds;

        if (totalTime > 16) {
          // Frame took longer than 16ms (60fps threshold)
          debugPrint(
            '⚠️ [$label] Slow frame detected: '
            'Build: ${buildTime}ms, '
            'Raster: ${rasterTime}ms, '
            'Total: ${totalTime}ms',
          );
        }
      }
    });
  }

  /// Measure widget build time
  static Future<T> measureBuildTime<T>(
    String label,
    Future<T> Function() operation,
  ) async {
    if (!kDebugMode) return await operation();

    final stopwatch = Stopwatch()..start();
    final result = await operation();
    stopwatch.stop();

    debugPrint(
      '⏱️ [$label] Build time: ${stopwatch.elapsedMilliseconds}ms',
    );

    return result;
  }

  /// Log memory usage
  static void logMemoryUsage(String label) {
    if (!kDebugMode) return;

    // Note: Actual memory profiling requires platform-specific implementation
    // This is a placeholder for memory monitoring
    debugPrint('📊 [$label] Memory check point');
  }

  /// Check if frame rate is acceptable
  static bool isFrameRateAcceptable(FrameTiming timing) {
    return timing.totalSpan.inMilliseconds <= 16; // 60fps = 16ms per frame
  }

  /// Get performance recommendations
  static List<String> getPerformanceRecommendations() {
    return [
      'Use const constructors where possible',
      'Implement lazy loading for lists',
      'Cache network images with cached_network_image',
      'Avoid unnecessary rebuilds with keys',
      'Use ListView.builder instead of ListView',
      'Minimize widget tree depth',
      'Use RepaintBoundary for complex widgets',
      'Profile with Flutter DevTools',
    ];
  }

  /// Check if device is low-end
  static bool isLowEndDevice() {
    // This is a simplified check
    // In production, you might want to check actual device specs
    return false; // Placeholder
  }

  /// Get recommended list item count for pagination
  static int getRecommendedPageSize() {
    return isLowEndDevice() ? 10 : 20;
  }

  /// Debounce function for search and other frequent operations
  static void Function() debounce(
    void Function() action, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    DateTime? lastActionTime;

    return () {
      final now = DateTime.now();
      if (lastActionTime == null || now.difference(lastActionTime!) > delay) {
        lastActionTime = now;
        action();
      }
    };
  }

  /// Throttle function for scroll and other continuous operations
  static void Function() throttle(
    void Function() action, {
    Duration interval = const Duration(milliseconds: 100),
  }) {
    DateTime? lastExecutionTime;
    bool isScheduled = false;

    return () {
      final now = DateTime.now();
      if (lastExecutionTime == null ||
          now.difference(lastExecutionTime!) > interval) {
        lastExecutionTime = now;
        action();
        isScheduled = false;
      } else if (!isScheduled) {
        isScheduled = true;
        Future.delayed(interval, () {
          lastExecutionTime = DateTime.now();
          action();
          isScheduled = false;
        });
      }
    };
  }
}

/// Mixin for widgets that need performance monitoring
mixin PerformanceMonitorMixin {
  void logBuildTime(String widgetName) {
    PerformanceUtils.logFrameTime(widgetName);
  }

  void logMemory(String widgetName) {
    PerformanceUtils.logMemoryUsage(widgetName);
  }
}
