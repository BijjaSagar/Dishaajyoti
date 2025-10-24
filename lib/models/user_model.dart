class User {
  final String id;
  final String email;
  final String status;
  final int failedLoginAttempts;
  final DateTime? lastFailedLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.status,
    this.failedLoginAttempts = 0,
    this.lastFailedLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      failedLoginAttempts: json['failedLoginAttempts'] as int? ?? 0,
      lastFailedLoginAt: json['lastFailedLoginAt'] != null
          ? DateTime.parse(json['lastFailedLoginAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'status': status,
      'failedLoginAttempts': failedLoginAttempts,
      'lastFailedLoginAt': lastFailedLoginAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? status,
    int? failedLoginAttempts,
    DateTime? lastFailedLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      status: status ?? this.status,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lastFailedLoginAt: lastFailedLoginAt ?? this.lastFailedLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
