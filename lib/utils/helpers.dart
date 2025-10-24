import 'package:intl/intl.dart';
import 'constants.dart';

/// Helper utility functions for common operations
class Helpers {
  // Date Formatting

  /// Format DateTime to display format (dd MMM yyyy)
  /// Example: 15 Jan 2024
  static String formatDisplayDate(DateTime date) {
    return DateFormat(AppConstants.displayDateFormat).format(date);
  }

  /// Format DateTime to standard date format (dd/MM/yyyy)
  /// Example: 15/01/2024
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  /// Format DateTime to time format (HH:mm)
  /// Example: 14:30
  static String formatTime(DateTime date) {
    return DateFormat(AppConstants.timeFormat).format(date);
  }

  /// Format DateTime to date and time format (dd/MM/yyyy HH:mm)
  /// Example: 15/01/2024 14:30
  static String formatDateTime(DateTime date) {
    return DateFormat(AppConstants.dateTimeFormat).format(date);
  }

  /// Format DateTime to API format (yyyy-MM-dd)
  /// Example: 2024-01-15
  static String formatApiDate(DateTime date) {
    return DateFormat(AppConstants.apiDateFormat).format(date);
  }

  /// Format DateTime to API date-time format (ISO 8601)
  /// Example: 2024-01-15T14:30:00.000Z
  static String formatApiDateTime(DateTime date) {
    return DateFormat(AppConstants.apiDateTimeFormat).format(date.toUtc());
  }

  /// Parse date string from API format
  static DateTime? parseApiDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get relative time string (e.g., "2 hours ago", "3 days ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Calculate age from date of birth
  static int calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;

    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }

  // Currency Formatting

  /// Format amount to currency string with rupee symbol
  /// Example: ₹299
  static String formatCurrency(int amount) {
    return '${AppConstants.currencySymbol}${amount.toString()}';
  }

  /// Format amount to currency string with comma separators
  /// Example: ₹1,299
  static String formatCurrencyWithCommas(int amount) {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    return '${AppConstants.currencySymbol}${formatter.format(amount)}';
  }

  /// Format amount to currency string with decimals
  /// Example: ₹299.00
  static String formatCurrencyWithDecimals(double amount) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return '${AppConstants.currencySymbol}${formatter.format(amount)}';
  }

  // String Utilities

  /// Capitalize first letter of string
  /// Example: "hello" -> "Hello"
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalize first letter of each word
  /// Example: "hello world" -> "Hello World"
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Truncate string with ellipsis
  /// Example: "Hello World" with maxLength 8 -> "Hello..."
  static String truncate(String text, int maxLength,
      {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - ellipsis.length) + ellipsis;
  }

  /// Remove extra whitespace from string
  static String cleanWhitespace(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Check if string is null or empty
  static bool isNullOrEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  // Phone Number Utilities

  /// Format phone number for display
  /// Example: "9876543210" -> "+91 98765 43210"
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');

    if (cleaned.startsWith('+91')) {
      final number = cleaned.substring(3);
      return '+91 ${number.substring(0, 5)} ${number.substring(5)}';
    } else if (cleaned.length == 10) {
      return '+91 ${cleaned.substring(0, 5)} ${cleaned.substring(5)}';
    }

    return phone;
  }

  /// Get phone number without country code
  /// Example: "+919876543210" -> "9876543210"
  static String getPhoneWithoutCountryCode(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');
    if (cleaned.startsWith('+91')) {
      return cleaned.substring(3);
    }
    return cleaned;
  }

  // File Size Utilities

  /// Format file size in bytes to human-readable format
  /// Example: 1024 -> "1 KB", 1048576 -> "1 MB"
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  // Validation Helpers

  /// Check if email is valid
  static bool isValidEmail(String email) {
    return RegExp(AppConstants.emailPattern).hasMatch(email);
  }

  /// Check if phone is valid
  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');
    return RegExp(AppConstants.phonePattern).hasMatch(cleaned);
  }

  // URL Utilities

  /// Open URL in browser (requires url_launcher package)
  static String sanitizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  // List Utilities

  /// Check if list is null or empty
  static bool isListNullOrEmpty(List? list) {
    return list == null || list.isEmpty;
  }

  /// Get safe list item at index (returns null if out of bounds)
  static T? safeListGet<T>(List<T>? list, int index) {
    if (list == null || index < 0 || index >= list.length) {
      return null;
    }
    return list[index];
  }

  // Session Utilities

  /// Check if session is expired based on last activity
  static bool isSessionExpired(DateTime lastActivity) {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    return difference.inMinutes >= AppConstants.sessionTimeoutMinutes;
  }

  /// Get session expiry time
  static DateTime getSessionExpiryTime(DateTime lastActivity) {
    return lastActivity.add(
      Duration(minutes: AppConstants.sessionTimeoutMinutes),
    );
  }

  // Error Message Utilities

  /// Get user-friendly error message from exception
  static String getErrorMessage(dynamic error) {
    if (error == null) {
      return AppConstants.unknownErrorMessage;
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      return AppConstants.networkErrorMessage;
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return AppConstants.sessionExpiredMessage;
    } else if (errorString.contains('forbidden') ||
        errorString.contains('403')) {
      return 'Access denied. You do not have permission to perform this action.';
    } else if (errorString.contains('not found') ||
        errorString.contains('404')) {
      return 'The requested resource was not found.';
    } else if (errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return AppConstants.serverErrorMessage;
    }

    return AppConstants.unknownErrorMessage;
  }

  // Debounce Utility

  /// Create a debounced function that delays execution
  static Function debounce(
    Function func, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    DateTime? lastCall;

    return () {
      final now = DateTime.now();
      if (lastCall == null || now.difference(lastCall!) >= delay) {
        lastCall = now;
        func();
      }
    };
  }

  // Color Utilities

  /// Convert hex color string to Color object
  /// Example: "#FF6B35" or "FF6B35"
  static int hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return int.parse(buffer.toString(), radix: 16);
  }

  // Platform Utilities

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Get initials from name
  /// Example: "John Doe" -> "JD"
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';

    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1))
        .toUpperCase();
  }
}
