import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile model for Firestore
class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SubscriptionInfo subscription;
  final UserPreferences preferences;
  final String? fcmToken;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
    SubscriptionInfo? subscription,
    UserPreferences? preferences,
    this.fcmToken,
  })  : subscription = subscription ?? SubscriptionInfo(),
        preferences = preferences ?? UserPreferences();

  /// Create UserProfile from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile.fromMap(data, doc.id);
  }

  /// Create UserProfile from Map
  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String?,
      dateOfBirth: map['dateOfBirth'] != null
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      subscription: map['subscription'] != null
          ? SubscriptionInfo.fromMap(
              map['subscription'] as Map<String, dynamic>)
          : SubscriptionInfo(),
      preferences: map['preferences'] != null
          ? UserPreferences.fromMap(map['preferences'] as Map<String, dynamic>)
          : UserPreferences(),
      fcmToken: map['fcmToken'] as String?,
    );
  }

  /// Convert UserProfile to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'subscription': subscription.toMap(),
      'preferences': preferences.toMap(),
      'fcmToken': fcmToken,
    };
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'subscription': subscription.toMap(),
      'preferences': preferences.toMap(),
      'fcmToken': fcmToken,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? updatedAt,
    SubscriptionInfo? subscription,
    UserPreferences? preferences,
    String? fcmToken,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subscription: subscription ?? this.subscription,
      preferences: preferences ?? this.preferences,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}

/// Subscription information
class SubscriptionInfo {
  final String type;
  final DateTime? expiresAt;

  SubscriptionInfo({
    this.type = 'free',
    this.expiresAt,
  });

  factory SubscriptionInfo.fromMap(Map<String, dynamic> map) {
    return SubscriptionInfo(
      type: map['type'] as String? ?? 'free',
      expiresAt: map['expiresAt'] != null
          ? (map['expiresAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  bool get isActive {
    if (type == 'free') return true;
    if (expiresAt == null) return false;
    return expiresAt!.isAfter(DateTime.now());
  }
}

/// User preferences
class UserPreferences {
  final String language;
  final String chartStyle;
  final bool notifications;

  UserPreferences({
    this.language = 'en',
    this.chartStyle = 'northIndian',
    this.notifications = true,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      language: map['language'] as String? ?? 'en',
      chartStyle: map['chartStyle'] as String? ?? 'northIndian',
      notifications: map['notifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'chartStyle': chartStyle,
      'notifications': notifications,
    };
  }

  UserPreferences copyWith({
    String? language,
    String? chartStyle,
    bool? notifications,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      chartStyle: chartStyle ?? this.chartStyle,
      notifications: notifications ?? this.notifications,
    );
  }
}
