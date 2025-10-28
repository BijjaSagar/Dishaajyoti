import 'dart:convert';

/// Chart Data Model for Kundali Chart Visualization
/// Supports both North Indian and South Indian chart styles

/// Main chart data structure
class ChartData {
  final double ascendant; // Lagna in degrees (0-360)
  final List<ChartPlanet> planets;
  final List<ChartHouse> houses;
  final ChartStyle style;

  ChartData({
    required this.ascendant,
    required this.planets,
    required this.houses,
    required this.style,
  });

  Map<String, dynamic> toJson() {
    return {
      'ascendant': ascendant,
      'planets': planets.map((p) => p.toJson()).toList(),
      'houses': houses.map((h) => h.toJson()).toList(),
      'style': style.name,
    };
  }

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      ascendant: json['ascendant'].toDouble(),
      planets: (json['planets'] as List)
          .map((p) => ChartPlanet.fromJson(p))
          .toList(),
      houses:
          (json['houses'] as List).map((h) => ChartHouse.fromJson(h)).toList(),
      style: ChartStyle.values.firstWhere(
        (s) => s.name == json['style'],
        orElse: () => ChartStyle.northIndian,
      ),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ChartData.fromJsonString(String jsonString) {
    return ChartData.fromJson(jsonDecode(jsonString));
  }
}

/// Planet information for chart display
class ChartPlanet {
  final String name;
  final String symbol;
  final double longitude; // Sidereal longitude in degrees
  final int house; // House number (1-12)
  final bool isRetrograde;
  final String sign; // Zodiac sign name
  final double degree; // Degree within sign (0-30)

  ChartPlanet({
    required this.name,
    required this.symbol,
    required this.longitude,
    required this.house,
    this.isRetrograde = false,
    required this.sign,
    required this.degree,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbol': symbol,
      'longitude': longitude,
      'house': house,
      'isRetrograde': isRetrograde,
      'sign': sign,
      'degree': degree,
    };
  }

  factory ChartPlanet.fromJson(Map<String, dynamic> json) {
    return ChartPlanet(
      name: json['name'],
      symbol: json['symbol'],
      longitude: json['longitude'].toDouble(),
      house: json['house'],
      isRetrograde: json['isRetrograde'] ?? false,
      sign: json['sign'],
      degree: json['degree'].toDouble(),
    );
  }

  /// Get display text for planet (includes retrograde indicator)
  String get displayText {
    return isRetrograde ? '$symbol(R)' : symbol;
  }
}

/// House information for chart display
class ChartHouse {
  final int number; // House number (1-12)
  final double cuspDegree; // Starting degree of house
  final String sign; // Zodiac sign in this house
  final List<String> planets; // Planet names in this house

  ChartHouse({
    required this.number,
    required this.cuspDegree,
    required this.sign,
    required this.planets,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'cuspDegree': cuspDegree,
      'sign': sign,
      'planets': planets,
    };
  }

  factory ChartHouse.fromJson(Map<String, dynamic> json) {
    return ChartHouse(
      number: json['number'],
      cuspDegree: json['cuspDegree'].toDouble(),
      sign: json['sign'],
      planets: List<String>.from(json['planets']),
    );
  }
}

/// Chart style enumeration
enum ChartStyle {
  northIndian, // Diamond-shaped chart
  southIndian, // Square chart with diagonals
}

/// Planet symbol mapping
class PlanetSymbols {
  static const Map<String, String> symbols = {
    'Sun': '☉',
    'Moon': '☽',
    'Mars': '♂',
    'Mercury': '☿',
    'Jupiter': '♃',
    'Venus': '♀',
    'Saturn': '♄',
    'Rahu': '☊',
    'Ketu': '☋',
  };

  /// Get symbol for planet name
  static String getSymbol(String planetName) {
    return symbols[planetName] ?? planetName.substring(0, 2).toUpperCase();
  }

  /// Get all planet names
  static List<String> get allPlanets => symbols.keys.toList();
}

/// Zodiac sign information
class ZodiacSignInfo {
  static const List<String> signs = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  static const Map<String, String> signSymbols = {
    'Aries': '♈',
    'Taurus': '♉',
    'Gemini': '♊',
    'Cancer': '♋',
    'Leo': '♌',
    'Virgo': '♍',
    'Libra': '♎',
    'Scorpio': '♏',
    'Sagittarius': '♐',
    'Capricorn': '♑',
    'Aquarius': '♒',
    'Pisces': '♓',
  };

  /// Get sign from longitude
  static String getSign(double longitude) {
    final normalizedLong = longitude % 360;
    final signIndex = (normalizedLong / 30).floor();
    return signs[signIndex % 12];
  }

  /// Get sign symbol
  static String getSignSymbol(String signName) {
    return signSymbols[signName] ?? signName.substring(0, 2);
  }

  /// Get sign number (1-12)
  static int getSignNumber(double longitude) {
    final normalizedLong = longitude % 360;
    return ((normalizedLong / 30).floor() % 12) + 1;
  }
}

/// Chart configuration for different styles
class ChartConfig {
  final ChartStyle style;
  final double size;
  final bool showHouseNumbers;
  final bool showPlanetSymbols;
  final bool showSignSymbols;
  final bool showDegrees;

  const ChartConfig({
    required this.style,
    this.size = 300,
    this.showHouseNumbers = true,
    this.showPlanetSymbols = true,
    this.showSignSymbols = true,
    this.showDegrees = false,
  });

  /// Default configuration for North Indian style
  static const ChartConfig northIndian = ChartConfig(
    style: ChartStyle.northIndian,
    size: 300,
    showHouseNumbers: true,
    showPlanetSymbols: true,
    showSignSymbols: false,
    showDegrees: false,
  );

  /// Default configuration for South Indian style
  static const ChartConfig southIndian = ChartConfig(
    style: ChartStyle.southIndian,
    size: 300,
    showHouseNumbers: true,
    showPlanetSymbols: true,
    showSignSymbols: true,
    showDegrees: false,
  );

  ChartConfig copyWith({
    ChartStyle? style,
    double? size,
    bool? showHouseNumbers,
    bool? showPlanetSymbols,
    bool? showSignSymbols,
    bool? showDegrees,
  }) {
    return ChartConfig(
      style: style ?? this.style,
      size: size ?? this.size,
      showHouseNumbers: showHouseNumbers ?? this.showHouseNumbers,
      showPlanetSymbols: showPlanetSymbols ?? this.showPlanetSymbols,
      showSignSymbols: showSignSymbols ?? this.showSignSymbols,
      showDegrees: showDegrees ?? this.showDegrees,
    );
  }
}
