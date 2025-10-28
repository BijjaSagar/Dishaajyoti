import '../models/chart_data_model.dart';
import '../models/vedic_kundali_model.dart';

/// Chart Data Adapter
/// Transforms VedicKundaliData into ChartData format for visualization
class ChartDataAdapter {
  /// Convert VedicKundaliData to ChartData
  static ChartData toChartData(
    VedicKundaliData vedicData,
    ChartStyle style,
  ) {
    // Convert planets
    final chartPlanets = convertPlanets(vedicData.planets);

    // Convert houses
    final chartHouses = convertHouses(
      vedicData.houses,
      vedicData.lagna,
      vedicData.planets,
    );

    return ChartData(
      ascendant: vedicData.lagna,
      planets: chartPlanets,
      houses: chartHouses,
      style: style,
    );
  }

  /// Convert planet positions to chart format
  static List<ChartPlanet> convertPlanets(
    Map<String, PlanetInfo> planets,
  ) {
    final chartPlanets = <ChartPlanet>[];

    planets.forEach((name, planetInfo) {
      final symbol = PlanetSymbols.getSymbol(name);

      chartPlanets.add(
        ChartPlanet(
          name: name,
          symbol: symbol,
          longitude: planetInfo.siderealLongitude,
          house: planetInfo.house,
          isRetrograde: planetInfo.isRetrograde,
          sign: planetInfo.sign,
          degree: planetInfo.degree,
        ),
      );
    });

    // Sort planets by house number for consistent display
    chartPlanets.sort((a, b) => a.house.compareTo(b.house));

    return chartPlanets;
  }

  /// Convert houses to chart format
  static List<ChartHouse> convertHouses(
    Map<int, HouseInfo> houses,
    double lagna,
    Map<String, PlanetInfo> planets,
  ) {
    final chartHouses = <ChartHouse>[];

    for (int i = 1; i <= 12; i++) {
      final houseInfo = houses[i];
      if (houseInfo == null) continue;

      // Get planets in this house
      final planetsInHouse = <String>[];
      planets.forEach((name, planetInfo) {
        if (planetInfo.house == i) {
          planetsInHouse.add(name);
        }
      });

      chartHouses.add(
        ChartHouse(
          number: i,
          cuspDegree: houseInfo.cuspLongitude,
          sign: houseInfo.sign,
          planets: planetsInHouse,
        ),
      );
    }

    return chartHouses;
  }

  /// Get chart configuration for style
  static ChartConfig getChartConfig(ChartStyle style) {
    switch (style) {
      case ChartStyle.northIndian:
        return ChartConfig.northIndian;
      case ChartStyle.southIndian:
        return ChartConfig.southIndian;
    }
  }

  /// Convert chart style string to enum
  static ChartStyle parseChartStyle(String? styleString) {
    if (styleString == null) return ChartStyle.northIndian;

    switch (styleString.toLowerCase()) {
      case 'northindian':
      case 'north_indian':
      case 'north':
        return ChartStyle.northIndian;
      case 'southindian':
      case 'south_indian':
      case 'south':
        return ChartStyle.southIndian;
      default:
        return ChartStyle.northIndian;
    }
  }

  /// Convert chart style enum to string
  static String chartStyleToString(ChartStyle style) {
    switch (style) {
      case ChartStyle.northIndian:
        return 'northIndian';
      case ChartStyle.southIndian:
        return 'southIndian';
    }
  }

  /// Get house position for North Indian chart
  /// North Indian charts have fixed house positions in diamond shape
  static int getNorthIndianHousePosition(int houseNumber) {
    // House positions in North Indian chart (clockwise from top)
    // 1=top, 2=top-right, 3=right, 4=bottom-right, etc.
    return houseNumber;
  }

  /// Get house position for South Indian chart
  /// South Indian charts have houses rotating based on ascendant
  static int getSouthIndianHousePosition(int houseNumber, double ascendant) {
    // In South Indian chart, signs are fixed and houses rotate
    final signNumber = ZodiacSignInfo.getSignNumber(ascendant);

    // Calculate position based on ascendant sign
    int position = (houseNumber + signNumber - 2) % 12 + 1;
    return position;
  }

  /// Group planets by house for display
  static Map<int, List<ChartPlanet>> groupPlanetsByHouse(
    List<ChartPlanet> planets,
  ) {
    final grouped = <int, List<ChartPlanet>>{};

    for (var planet in planets) {
      if (!grouped.containsKey(planet.house)) {
        grouped[planet.house] = [];
      }
      grouped[planet.house]!.add(planet);
    }

    return grouped;
  }

  /// Format degree notation for display
  static String formatDegree(double degree) {
    final deg = degree.floor();
    final min = ((degree - deg) * 60).floor();
    final sec = (((degree - deg) * 60 - min) * 60).floor();

    return '$deg°$min\'$sec"';
  }

  /// Get planet display order (for consistent rendering)
  static List<String> getPlanetDisplayOrder() {
    return [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
      'Rahu',
      'Ketu',
    ];
  }

  /// Sort planets by display order
  static List<ChartPlanet> sortPlanetsByDisplayOrder(
    List<ChartPlanet> planets,
  ) {
    final order = getPlanetDisplayOrder();
    planets.sort((a, b) {
      final aIndex = order.indexOf(a.name);
      final bIndex = order.indexOf(b.name);
      if (aIndex == -1) return 1;
      if (bIndex == -1) return -1;
      return aIndex.compareTo(bIndex);
    });
    return planets;
  }

  /// Check if two planets are in conjunction (same house)
  static bool areInConjunction(ChartPlanet planet1, ChartPlanet planet2) {
    return planet1.house == planet2.house;
  }

  /// Get conjunction groups (planets in same house)
  static List<List<ChartPlanet>> getConjunctionGroups(
    List<ChartPlanet> planets,
  ) {
    final groups = <List<ChartPlanet>>[];
    final grouped = groupPlanetsByHouse(planets);

    grouped.forEach((house, planetsInHouse) {
      if (planetsInHouse.length > 1) {
        groups.add(planetsInHouse);
      }
    });

    return groups;
  }

  /// Calculate aspect between two planets (simplified)
  static String? getAspect(ChartPlanet planet1, ChartPlanet planet2) {
    final diff = (planet1.longitude - planet2.longitude).abs() % 360;

    // Major aspects
    if (diff < 10 || diff > 350) return 'Conjunction';
    if ((diff - 60).abs() < 10) return 'Sextile';
    if ((diff - 90).abs() < 10) return 'Square';
    if ((diff - 120).abs() < 10) return 'Trine';
    if ((diff - 180).abs() < 10) return 'Opposition';

    return null;
  }

  /// Validate chart data
  static bool validateChartData(ChartData chartData) {
    // Check ascendant is valid
    if (chartData.ascendant < 0 || chartData.ascendant >= 360) {
      return false;
    }

    // Check all planets have valid data
    for (var planet in chartData.planets) {
      if (planet.longitude < 0 || planet.longitude >= 360) return false;
      if (planet.house < 1 || planet.house > 12) return false;
    }

    // Check all houses are present
    if (chartData.houses.length != 12) return false;

    return true;
  }
}
