enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

class Payment {
  final String id;
  final String userId;
  final String serviceId;
  final int amount;
  final String currency;
  final PaymentStatus status;
  final String paymentMethod;
  final String transactionId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.amount,
    this.currency = 'INR',
    required this.status,
    required this.paymentMethod,
    required this.transactionId,
    Map<String, dynamic>? metadata,
    required this.createdAt,
    required this.updatedAt,
  }) : metadata = metadata ?? {};

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      serviceId: json['serviceId'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String? ?? 'INR',
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: json['paymentMethod'] as String,
      transactionId: json['transactionId'] as String,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceId': serviceId,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Payment copyWith({
    String? id,
    String? userId,
    String? serviceId,
    int? amount,
    String? currency,
    PaymentStatus? status,
    String? paymentMethod,
    String? transactionId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
