enum ReportStatus {
  generating,
  ready,
  failed,
}

class Report {
  final String id;
  final String userId;
  final String serviceId;
  final String paymentId;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final ReportStatus status;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.paymentId,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.status,
    Map<String, dynamic>? metadata,
    required this.createdAt,
    required this.updatedAt,
  }) : metadata = metadata ?? {};

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      userId: json['userId'] as String,
      serviceId: json['serviceId'] as String,
      paymentId: json['paymentId'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      fileSize: json['fileSize'] as int,
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.generating,
      ),
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
      'paymentId': paymentId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'status': status.name,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Report copyWith({
    String? id,
    String? userId,
    String? serviceId,
    String? paymentId,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    ReportStatus? status,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      paymentId: paymentId ?? this.paymentId,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
