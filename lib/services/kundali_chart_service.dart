import '../models/kundali_with_chart_model.dart';
import '../models/chart_data_model.dart';
import '../models/vedic_kundali_model.dart';
import '../models/kundali_model.dart';
import 'vedic_kundali_calculator.dart';
import 'chart_data_adapter.dart';
import 'database_helper.dart';

/// Kundali Chart Service
/// Orchestrates chart generation, data transformation, and storage
class KundaliChartService {
  static final KundaliChartService instance = KundaliChartService._init();

  KundaliChartService._init();

  /// Generate complete Kundali with chart data
  Future<KundaliWithChart> generateKundaliWithChart({
    required BirthDetails birthDetails,
    ChartStyle chartStyle = ChartStyle.northIndian,
  }) async {
    try {
      // Step 1: Calculate Vedic Kundali data
      final calculator = VedicKundaliCalculator(birthDetails);
      final vedicData = await calculator.calculateKundaliData();

      // Step 2: Transform to chart data
      final chartData = ChartDataAdapter.toChartData(vedicData, chartStyle);

      // Step 3: Validate chart data
      if (!ChartDataAdapter.validateChartData(chartData)) {
        throw KundaliChartException(
          'Invalid chart data generated',
          KundaliErrorType.calculation,
        );
      }

      // Step 4: Create basic Kundali data for backward compatibility
      final kundaliData = _createKundaliData(vedicData);

      // Step 5: Create KundaliWithChart object
      final kundaliId = 'KUNDALI_${DateTime.now().millisecondsSinceEpoch}';

      final kundaliWithChart = KundaliWithChart(
        id: kundaliId,
        userId: 'user123', // TODO: Get from auth provider
        name: birthDetails.name,
        dateOfBirth: birthDetails.dateTime,
        timeOfBirth:
            '${birthDetails.dateTime.hour.toString().padLeft(2, '0')}:${birthDetails.dateTime.minute.toString().padLeft(2, '0')}',
        placeOfBirth: birthDetails.locationName,
        chartData: chartData,
        chartStyle: chartStyle,
        data: kundaliData,
        createdAt: DateTime.now(),
      );

      return kundaliWithChart;
    } catch (e) {
      if (e is KundaliChartException) {
        rethrow;
      }
      throw KundaliChartException(
        'Failed to generate Kundali: ${e.toString()}',
        KundaliErrorType.calculation,
        originalError: e,
      );
    }
  }

  /// Create KundaliData from VedicKundaliData for backward compatibility
  KundaliData _createKundaliData(VedicKundaliData vedicData) {
    final planets = <PlanetPosition>[];

    vedicData.planets.forEach((name, planetInfo) {
      planets.add(PlanetPosition(
        name: name,
        sign: planetInfo.sign,
        house: planetInfo.house.toString(),
        degree: planetInfo.degree,
      ));
    });

    final houses = <String, String>{};
    vedicData.houses.forEach((number, houseInfo) {
      houses[number.toString()] = houseInfo.sign;
    });

    return KundaliData(
      sunSign: vedicData.sunSign,
      moonSign: vedicData.moonSign,
      ascendant: vedicData.lagnaSign,
      planets: planets,
      houses: houses,
    );
  }

  /// Save Kundali to local database
  Future<void> saveKundali(KundaliWithChart kundali) async {
    try {
      await DatabaseHelper.instance.insertKundaliWithChart(kundali);
    } catch (e) {
      throw KundaliChartException(
        'Failed to save Kundali: ${e.toString()}',
        KundaliErrorType.storage,
        originalError: e,
      );
    }
  }

  /// Load Kundalis from local database
  Future<List<KundaliWithChart>> loadKundalis(String userId) async {
    try {
      return await DatabaseHelper.instance.getKundalisWithChart(userId);
    } catch (e) {
      throw KundaliChartException(
        'Failed to load Kundalis: ${e.toString()}',
        KundaliErrorType.storage,
        originalError: e,
      );
    }
  }

  /// Get chart data for existing Kundali
  Future<ChartData?> getChartData(String kundaliId) async {
    try {
      final kundali =
          await DatabaseHelper.instance.getKundaliWithChart(kundaliId);
      return kundali?.chartData;
    } catch (e) {
      throw KundaliChartException(
        'Failed to get chart data: ${e.toString()}',
        KundaliErrorType.storage,
        originalError: e,
      );
    }
  }

  /// Update chart style preference
  Future<void> updateChartStyle(
    String kundaliId,
    ChartStyle newStyle,
  ) async {
    try {
      final kundali =
          await DatabaseHelper.instance.getKundaliWithChart(kundaliId);

      if (kundali == null) {
        throw KundaliChartException(
          'Kundali not found',
          KundaliErrorType.storage,
        );
      }

      // Update chart data with new style
      final updatedChartData = ChartData(
        ascendant: kundali.chartData.ascendant,
        planets: kundali.chartData.planets,
        houses: kundali.chartData.houses,
        style: newStyle,
      );

      final updatedKundali = kundali.copyWith(
        chartData: updatedChartData,
        chartStyle: newStyle,
      );

      await DatabaseHelper.instance.updateKundaliWithChart(updatedKundali);
    } catch (e) {
      if (e is KundaliChartException) {
        rethrow;
      }
      throw KundaliChartException(
        'Failed to update chart style: ${e.toString()}',
        KundaliErrorType.storage,
        originalError: e,
      );
    }
  }

  /// Get Kundali by ID
  Future<KundaliWithChart?> getKundali(String kundaliId) async {
    try {
      return await DatabaseHelper.instance.getKundaliWithChart(kundaliId);
    } catch (e) {
      throw KundaliChartException(
        'Failed to get Kundali: ${e.toString()}',
        KundaliErrorType.storage,
        originalError: e,
      );
    }
  }

  /// Delete Kundali
  Future<void> deleteKundali(String kundaliId) async {
    try {
      await DatabaseHelper.instance.deleteKundali(kundaliId);
    } catch (e) {
      throw KundaliChartException(
        'Failed to delete Kundali: ${e.toString()}',
        KundaliErrorType.storage,
        originalError: e,
      );
    }
  }

  /// Regenerate chart data for existing Kundali
  Future<KundaliWithChart> regenerateChart(
    KundaliWithChart kundali,
    ChartStyle newStyle,
  ) async {
    try {
      // Recreate birth details
      final birthDetails = BirthDetails(
        name: kundali.name,
        dateTime: kundali.dateOfBirth,
        locationName: kundali.placeOfBirth,
        latitude: 0, // TODO: Store coordinates in Kundali model
        longitude: 0,
      );

      // Regenerate
      return await generateKundaliWithChart(
        birthDetails: birthDetails,
        chartStyle: newStyle,
      );
    } catch (e) {
      throw KundaliChartException(
        'Failed to regenerate chart: ${e.toString()}',
        KundaliErrorType.calculation,
        originalError: e,
      );
    }
  }

  /// Get basic predictions based on chart data
  Map<String, String> getBasicPredictions(KundaliWithChart kundali) {
    return {
      'Career': _getCareerPrediction(kundali.chartData),
      'Health': _getHealthPrediction(kundali.chartData),
      'Relationships': _getRelationshipPrediction(kundali.chartData),
      'Finance': _getFinancePrediction(kundali.chartData),
    };
  }

  String _getCareerPrediction(ChartData chartData) {
    // Find 10th house (career house)
    final tenthHouse = chartData.houses.firstWhere(
      (h) => h.number == 10,
      orElse: () => chartData.houses.first,
    );

    if (tenthHouse.planets.isNotEmpty) {
      return 'Strong career prospects indicated by planets in 10th house.';
    }
    return 'Focus on building skills and networking for career growth.';
  }

  String _getHealthPrediction(ChartData chartData) {
    return 'Maintain regular health checkups and balanced lifestyle.';
  }

  String _getRelationshipPrediction(ChartData chartData) {
    return 'Communication and understanding are key to harmonious relationships.';
  }

  String _getFinancePrediction(ChartData chartData) {
    return 'Financial stability comes through disciplined savings and wise investments.';
  }
}

/// Kundali Chart Exception
class KundaliChartException implements Exception {
  final String message;
  final KundaliErrorType type;
  final dynamic originalError;
  final bool isRecoverable;

  KundaliChartException(
    this.message,
    this.type, {
    this.originalError,
    this.isRecoverable = true,
  });

  @override
  String toString() => 'KundaliChartException: $message';
}

/// Error types
enum KundaliErrorType {
  validation,
  calculation,
  storage,
  sync,
  rendering,
}
