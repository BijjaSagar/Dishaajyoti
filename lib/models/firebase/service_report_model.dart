import 'package:cloud_firestore/cloud_firestore.dart';

/// Service report status enum
enum ServiceReportStatus {
  pending,
  scheduled,
  processing,
  completed,
  failed;

  static ServiceReportStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ServiceReportStatus.pending;
      case 'scheduled':
        return ServiceReportStatus.scheduled;
      case 'processing':
        return ServiceReportStatus.processing;
      case 'completed':
        return ServiceReportStatus.completed;
      case 'failed':
        return ServiceReportStatus.failed;
      default:
        return ServiceReportStatus.pending;
    }
  }

  @override
  String toString() {
    return name;
  }

  String get displayName {
    switch (this) {
      case ServiceReportStatus.pending:
        return 'Pending';
      case ServiceReportStatus.scheduled:
        return 'Scheduled';
      case ServiceReportStatus.processing:
        return 'Processing';
      case ServiceReportStatus.completed:
        return 'Completed';
      case ServiceReportStatus.failed:
        return 'Failed';
    }
  }
}

/// Service type enum
enum ServiceType {
  kundali,
  palmistry,
  numerology,
  matchmaking,
  panchang;

  static ServiceType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'kundali':
        return ServiceType.kundali;
      case 'palmistry':
        return ServiceType.palmistry;
      case 'numerology':
        return ServiceType.numerology;
      case 'matchmaking':
        return ServiceType.matchmaking;
      case 'panchang':
        return ServiceType.panchang;
      default:
        return ServiceType.kundali;
    }
  }

  @override
  String toString() {
    return name;
  }
}

/// Service report model for Firestore
class ServiceReport {
  final String id;
  final String userId;
  final ServiceType serviceType;
  final ServiceReportStatus status;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final DateTime? completedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> data;
  final ReportFiles? files;
  final Map<String, dynamic>? metadata;
  final String? errorMessage;

  ServiceReport({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.status,
    required this.createdAt,
    this.scheduledFor,
    this.completedAt,
    this.expiresAt,
    Map<String, dynamic>? data,
    this.files,
    this.metadata,
    this.errorMessage,
  }) : data = data ?? {};

  /// Create ServiceReport from Firestore document
  factory ServiceReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceReport.fromMap(data, doc.id);
  }

  /// Create ServiceReport from Map
  factory ServiceReport.fromMap(Map<String, dynamic> map, String id) {
    return ServiceReport(
      id: id,
      userId: map['userId'] as String? ?? '',
      serviceType:
          ServiceType.fromString(map['serviceType'] as String? ?? 'kundali'),
      status:
          ServiceReportStatus.fromString(map['status'] as String? ?? 'pending'),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      scheduledFor: map['scheduledFor'] != null
          ? (map['scheduledFor'] as Timestamp).toDate()
          : null,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      expiresAt: map['expiresAt'] != null
          ? (map['expiresAt'] as Timestamp).toDate()
          : null,
      data: map['data'] != null
          ? Map<String, dynamic>.from(map['data'] as Map)
          : {},
      files: map['files'] != null
          ? ReportFiles.fromMap(map['files'] as Map<String, dynamic>)
          : null,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
      errorMessage: map['errorMessage'] as String?,
    );
  }

  /// Convert ServiceReport to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'serviceType': serviceType.toString(),
      'status': status.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledFor':
          scheduledFor != null ? Timestamp.fromDate(scheduledFor!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'data': data,
      'files': files?.toMap(),
      'metadata': metadata,
      'errorMessage': errorMessage,
    };
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceType': serviceType.toString(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'data': data,
      'files': files?.toMap(),
      'metadata': metadata,
      'errorMessage': errorMessage,
    };
  }

  ServiceReport copyWith({
    String? id,
    String? userId,
    ServiceType? serviceType,
    ServiceReportStatus? status,
    DateTime? createdAt,
    DateTime? scheduledFor,
    DateTime? completedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? data,
    ReportFiles? files,
    Map<String, dynamic>? metadata,
    String? errorMessage,
  }) {
    return ServiceReport(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      data: data ?? this.data,
      files: files ?? this.files,
      metadata: metadata ?? this.metadata,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if report is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return expiresAt!.isBefore(DateTime.now());
  }

  /// Check if report is ready
  bool get isReady {
    return status == ServiceReportStatus.completed && !isExpired;
  }
}

/// Report files information
class ReportFiles {
  final String? pdfUrl;
  final List<String> imageUrls;

  ReportFiles({
    this.pdfUrl,
    List<String>? imageUrls,
  }) : imageUrls = imageUrls ?? [];

  factory ReportFiles.fromMap(Map<String, dynamic> map) {
    return ReportFiles(
      pdfUrl: map['pdfUrl'] as String?,
      imageUrls: map['imageUrls'] != null
          ? List<String>.from(map['imageUrls'] as List)
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pdfUrl': pdfUrl,
      'imageUrls': imageUrls,
    };
  }

  ReportFiles copyWith({
    String? pdfUrl,
    List<String>? imageUrls,
  }) {
    return ReportFiles(
      pdfUrl: pdfUrl ?? this.pdfUrl,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}
