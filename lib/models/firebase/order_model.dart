import 'package:cloud_firestore/cloud_firestore.dart';

/// Order status enum for Firebase
enum FirebaseOrderStatus {
  pending,
  paid,
  failed,
  refunded,
  cancelled;

  static FirebaseOrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return FirebaseOrderStatus.pending;
      case 'paid':
        return FirebaseOrderStatus.paid;
      case 'failed':
        return FirebaseOrderStatus.failed;
      case 'refunded':
        return FirebaseOrderStatus.refunded;
      case 'cancelled':
        return FirebaseOrderStatus.cancelled;
      default:
        return FirebaseOrderStatus.pending;
    }
  }

  @override
  String toString() {
    return name;
  }

  String get displayName {
    switch (this) {
      case FirebaseOrderStatus.pending:
        return 'Pending';
      case FirebaseOrderStatus.paid:
        return 'Paid';
      case FirebaseOrderStatus.failed:
        return 'Failed';
      case FirebaseOrderStatus.refunded:
        return 'Refunded';
      case FirebaseOrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Order model for Firestore
class FirebaseOrder {
  final String id;
  final String userId;
  final String serviceType;
  final double amount;
  final String currency;
  final FirebaseOrderStatus status;
  final String? paymentId;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? reportId;
  final bool testMode;
  final Map<String, dynamic>? metadata;

  FirebaseOrder({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.amount,
    this.currency = 'INR',
    required this.status,
    this.paymentId,
    this.paymentMethod,
    required this.createdAt,
    this.paidAt,
    this.reportId,
    this.testMode = false,
    this.metadata,
  });

  /// Create FirebaseOrder from Firestore document
  factory FirebaseOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseOrder.fromMap(data, doc.id);
  }

  /// Create FirebaseOrder from Map
  factory FirebaseOrder.fromMap(Map<String, dynamic> map, String id) {
    return FirebaseOrder(
      id: id,
      userId: map['userId'] as String? ?? '',
      serviceType: map['serviceType'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'INR',
      status:
          FirebaseOrderStatus.fromString(map['status'] as String? ?? 'pending'),
      paymentId: map['paymentId'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      paidAt:
          map['paidAt'] != null ? (map['paidAt'] as Timestamp).toDate() : null,
      reportId: map['reportId'] as String?,
      testMode: map['testMode'] as bool? ?? false,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }

  /// Convert FirebaseOrder to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'serviceType': serviceType,
      'amount': amount,
      'currency': currency,
      'status': status.toString(),
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'reportId': reportId,
      'testMode': testMode,
      'metadata': metadata,
    };
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceType': serviceType,
      'amount': amount,
      'currency': currency,
      'status': status.toString(),
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'reportId': reportId,
      'testMode': testMode,
      'metadata': metadata,
    };
  }

  FirebaseOrder copyWith({
    String? id,
    String? userId,
    String? serviceType,
    double? amount,
    String? currency,
    FirebaseOrderStatus? status,
    String? paymentId,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? paidAt,
    String? reportId,
    bool? testMode,
    Map<String, dynamic>? metadata,
  }) {
    return FirebaseOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceType: serviceType ?? this.serviceType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      reportId: reportId ?? this.reportId,
      testMode: testMode ?? this.testMode,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if order is paid
  bool get isPaid {
    return status == FirebaseOrderStatus.paid;
  }

  /// Check if order is pending
  bool get isPending {
    return status == FirebaseOrderStatus.pending;
  }

  /// Check if order has failed
  bool get hasFailed {
    return status == FirebaseOrderStatus.failed;
  }
}
