import 'kundali_model.dart';
import 'chart_data_model.dart';
import 'dart:convert';

/// Extended Kundali model with chart visualization data
/// Maintains backward compatibility with existing Kundali model
class KundaliWithChart extends Kundali {
  final ChartData chartData;
  final ChartStyle chartStyle;
  final String? chartImagePath; // Path to cached chart image
  final String? syncStatus; // 'synced', 'pending', 'failed'
  final String? serverId; // Server-generated ID

  KundaliWithChart({
    required String id,
    required String userId,
    required String name,
    required DateTime dateOfBirth,
    required String timeOfBirth,
    required String placeOfBirth,
    required this.chartData,
    required this.chartStyle,
    String? pdfPath,
    KundaliData? data,
    this.chartImagePath,
    this.syncStatus = 'pending',
    this.serverId,
    required DateTime createdAt,
  }) : super(
          id: id,
          userId: userId,
          name: name,
          dateOfBirth: dateOfBirth,
          timeOfBirth: timeOfBirth,
          placeOfBirth: placeOfBirth,
          pdfPath: pdfPath,
          data: data,
          createdAt: createdAt,
        );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['chartData'] = chartData.toJson();
    json['chartStyle'] = chartStyle.name;
    json['chartImagePath'] = chartImagePath;
    json['syncStatus'] = syncStatus;
    json['serverId'] = serverId;
    return json;
  }

  factory KundaliWithChart.fromJson(Map<String, dynamic> json) {
    return KundaliWithChart(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      timeOfBirth: json['timeOfBirth'],
      placeOfBirth: json['placeOfBirth'],
      pdfPath: json['pdfPath'],
      data: json['data'] != null ? KundaliData.fromJson(json['data']) : null,
      chartData: ChartData.fromJson(json['chartData']),
      chartStyle: ChartStyle.values.firstWhere(
        (s) => s.name == json['chartStyle'],
        orElse: () => ChartStyle.northIndian,
      ),
      chartImagePath: json['chartImagePath'],
      syncStatus: json['syncStatus'] ?? 'pending',
      serverId: json['serverId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'timeOfBirth': timeOfBirth,
      'placeOfBirth': placeOfBirth,
      'pdfPath': pdfPath,
      'dataJson': data?.toJson().toString(),
      'chartDataJson': chartData.toJsonString(),
      'chartStyle': chartStyle.name,
      'chartImagePath': chartImagePath,
      'syncStatus': syncStatus ?? 'pending',
      'serverId': serverId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory KundaliWithChart.fromMap(Map<String, dynamic> map) {
    // Parse chart data from JSON string
    ChartData? parsedChartData;
    try {
      if (map['chartDataJson'] != null && map['chartDataJson'] != '') {
        parsedChartData = ChartData.fromJsonString(map['chartDataJson']);
      }
    } catch (e) {
      // If parsing fails, create placeholder chart data
      parsedChartData = null;
    }

    // Parse chart style
    ChartStyle parsedStyle = ChartStyle.northIndian;
    if (map['chartStyle'] != null) {
      try {
        parsedStyle = ChartStyle.values.firstWhere(
          (s) => s.name == map['chartStyle'],
          orElse: () => ChartStyle.northIndian,
        );
      } catch (e) {
        parsedStyle = ChartStyle.northIndian;
      }
    }

    return KundaliWithChart(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
      timeOfBirth: map['timeOfBirth'],
      placeOfBirth: map['placeOfBirth'],
      pdfPath: map['pdfPath'],
      data: null, // Parse from dataJson if needed
      chartData: parsedChartData ??
          ChartData(
            ascendant: 0,
            planets: [],
            houses: [],
            style: parsedStyle,
          ),
      chartStyle: parsedStyle,
      chartImagePath: map['chartImagePath'],
      syncStatus: map['syncStatus'] ?? 'pending',
      serverId: map['serverId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  /// Create KundaliWithChart from existing Kundali
  factory KundaliWithChart.fromKundali(
    Kundali kundali,
    ChartData chartData,
    ChartStyle chartStyle,
  ) {
    return KundaliWithChart(
      id: kundali.id,
      userId: kundali.userId,
      name: kundali.name,
      dateOfBirth: kundali.dateOfBirth,
      timeOfBirth: kundali.timeOfBirth,
      placeOfBirth: kundali.placeOfBirth,
      pdfPath: kundali.pdfPath,
      data: kundali.data,
      chartData: chartData,
      chartStyle: chartStyle,
      createdAt: kundali.createdAt,
    );
  }

  /// Copy with method for updating specific fields
  KundaliWithChart copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? dateOfBirth,
    String? timeOfBirth,
    String? placeOfBirth,
    String? pdfPath,
    KundaliData? data,
    ChartData? chartData,
    ChartStyle? chartStyle,
    String? chartImagePath,
    String? syncStatus,
    String? serverId,
    DateTime? createdAt,
  }) {
    return KundaliWithChart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      pdfPath: pdfPath ?? this.pdfPath,
      data: data ?? this.data,
      chartData: chartData ?? this.chartData,
      chartStyle: chartStyle ?? this.chartStyle,
      chartImagePath: chartImagePath ?? this.chartImagePath,
      syncStatus: syncStatus ?? this.syncStatus,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if Kundali is synced with server
  bool get isSynced => syncStatus == 'synced' && serverId != null;

  /// Check if Kundali is pending sync
  bool get isPendingSync => syncStatus == 'pending';

  /// Check if Kundali sync failed
  bool get isSyncFailed => syncStatus == 'failed';

  /// Get chart style display name
  String get chartStyleDisplayName {
    switch (chartStyle) {
      case ChartStyle.northIndian:
        return 'North Indian';
      case ChartStyle.southIndian:
        return 'South Indian';
    }
  }
}
