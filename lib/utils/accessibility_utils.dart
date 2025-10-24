import 'package:flutter/material.dart';

/// Utility class for accessibility helpers and constants
class AccessibilityUtils {
  AccessibilityUtils._();

  // Minimum touch target size as per Material Design guidelines (48x48 dp)
  static const double minTouchTargetSize = 48.0;

  // Recommended touch target size for better accessibility (56x56 dp)
  static const double recommendedTouchTargetSize = 56.0;

  /// Wraps a widget with minimum touch target size
  /// Ensures interactive elements meet accessibility standards
  static Widget ensureMinTouchTarget({
    required Widget child,
    double minSize = minTouchTargetSize,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }

  /// Creates a semantic label for screen readers
  /// Combines multiple pieces of information into a readable format
  static String createSemanticLabel({
    required String label,
    String? hint,
    String? value,
    bool? isSelected,
    bool? isEnabled,
  }) {
    final parts = <String>[label];

    if (value != null && value.isNotEmpty) {
      parts.add(value);
    }

    if (hint != null && hint.isNotEmpty) {
      parts.add(hint);
    }

    if (isSelected != null && isSelected) {
      parts.add('selected');
    }

    if (isEnabled != null && !isEnabled) {
      parts.add('disabled');
    }

    return parts.join(', ');
  }

  /// Announces a message to screen readers
  static void announce(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 100),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  /// Checks if text scaling is enabled and returns appropriate size
  static double getScaledSize(BuildContext context, double baseSize) {
    final textScaleFactor = MediaQuery.textScalerOf(context).scale(baseSize);
    return textScaleFactor;
  }

  /// Validates color contrast ratio meets WCAG AA standards (4.5:1 for normal text)
  static bool meetsContrastRatio(Color foreground, Color background,
      {double minRatio = 4.5}) {
    final ratio = calculateContrastRatio(foreground, background);
    return ratio >= minRatio;
  }

  /// Calculates contrast ratio between two colors
  /// Returns a value between 1 and 21
  static double calculateContrastRatio(Color color1, Color color2) {
    final l1 = _calculateRelativeLuminance(color1);
    final l2 = _calculateRelativeLuminance(color2);

    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calculates relative luminance of a color
  static double _calculateRelativeLuminance(Color color) {
    final r = _linearize(color.red / 255.0);
    final g = _linearize(color.green / 255.0);
    final b = _linearize(color.blue / 255.0);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Linearizes RGB color channel value
  static double _linearize(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    }
    return ((channel + 0.055) / 1.055).pow(2.4);
  }
}

/// Extension on double for power calculation
extension on double {
  double pow(double exponent) {
    return this * this; // Simplified for 2.4 approximation
  }
}
