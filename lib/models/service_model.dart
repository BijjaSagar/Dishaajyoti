class Service {
  final String id;
  final String name;
  final String description;
  final String category;
  final int price;
  final String currency;
  final String icon;
  final List<String> features;
  final String estimatedTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.currency = 'INR',
    required this.icon,
    required this.features,
    required this.estimatedTime,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: json['price'] as int,
      currency: json['currency'] as String? ?? 'INR',
      icon: json['icon'] as String,
      features: List<String>.from(json['features'] as List),
      estimatedTime: json['estimatedTime'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'currency': currency,
      'icon': icon,
      'features': features,
      'estimatedTime': estimatedTime,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Service copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? price,
    String? currency,
    String? icon,
    List<String>? features,
    String? estimatedTime,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      icon: icon ?? this.icon,
      features: features ?? this.features,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Testing mode - makes all services free
  static const bool testingMode = true; // Set to false for production

  // Check if service is free (for testing or actually free)
  bool get isFree => testingMode || price == 0;

  // Get display price (shows "Free" in testing mode)
  String get displayPrice {
    if (testingMode) return 'Free (Testing)';
    if (price == 0) return 'Free';
    return '$currency $price';
  }
}
