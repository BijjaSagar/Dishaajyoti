/// Order model representing a service order
class Order {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final int amount;
  final String currency;
  final OrderStatus status;
  final String? paymentId;
  final String? reportId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  Order({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.amount,
    this.currency = 'INR',
    required this.status,
    this.paymentId,
    this.reportId,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String? ?? 'INR',
      status: OrderStatus.fromString(json['status'] as String),
      paymentId: json['payment_id'] as String?,
      reportId: json['report_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'service_name': serviceName,
      'amount': amount,
      'currency': currency,
      'status': status.toString(),
      'payment_id': paymentId,
      'report_id': reportId,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    String? serviceId,
    String? serviceName,
    int? amount,
    String? currency,
    OrderStatus? status,
    String? paymentId,
    String? reportId,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      reportId: reportId ?? this.reportId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Order status enum
enum OrderStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled;

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'completed':
        return OrderStatus.completed;
      case 'failed':
        return OrderStatus.failed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  @override
  String toString() {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.failed:
        return 'failed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.failed:
        return 'Failed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
