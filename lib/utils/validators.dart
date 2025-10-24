/// Validation utilities for form inputs
class Validators {
  /// Validates email format
  /// Returns null if valid, error message if invalid
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Standard email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  /// Requirements: At least 8 characters, one uppercase, one lowercase, one number
  /// Returns null if valid, error message if invalid
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validates password confirmation matches original password
  /// Returns null if valid, error message if invalid
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates phone number format (Indian format)
  /// Accepts 10-digit numbers with optional +91 prefix
  /// Returns null if valid, error message if invalid
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove spaces and dashes
    final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');

    // Check for Indian phone format: +91XXXXXXXXXX or XXXXXXXXXX
    final phoneRegex = RegExp(r'^(\+91)?[6-9]\d{9}$');

    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Please enter a valid 10-digit phone number';
    }

    return null;
  }

  /// Validates required field
  /// Returns null if valid, error message if invalid
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates name field (letters, spaces, and common punctuation only)
  /// Returns null if valid, error message if invalid
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    // Allow letters, spaces, hyphens, and apostrophes
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");

    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validates date of birth (must be in the past and user must be at least 13 years old)
  /// Returns null if valid, error message if invalid
  static String? dateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }

    final now = DateTime.now();

    // Check if date is in the future
    if (value.isAfter(now)) {
      return 'Date of birth cannot be in the future';
    }

    // Check minimum age (13 years)
    final age = now.year - value.year;
    final hasHadBirthdayThisYear = now.month > value.month ||
        (now.month == value.month && now.day >= value.day);

    final actualAge = hasHadBirthdayThisYear ? age : age - 1;

    if (actualAge < 13) {
      return 'You must be at least 13 years old';
    }

    return null;
  }

  /// Validates time format (HH:MM)
  /// Returns null if valid, error message if invalid
  static String? time(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time is required';
    }

    // Check for HH:MM format
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');

    if (!timeRegex.hasMatch(value)) {
      return 'Please enter time in HH:MM format';
    }

    return null;
  }

  /// Validates place/location field
  /// Returns null if valid, error message if invalid
  static String? place(String? value) {
    if (value == null || value.isEmpty) {
      return 'Place is required';
    }

    if (value.trim().length < 2) {
      return 'Place must be at least 2 characters';
    }

    return null;
  }

  /// Validates multi-line text field with minimum length
  /// Returns null if valid, error message if invalid
  static String? multilineText(
    String? value, {
    required String fieldName,
    int minLength = 10,
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }
}
