/// Vedic Astrology Kundali Data Models

/// Birth Details for Kundali calculation
class BirthDetails {
  final String name;
  final DateTime dateTime;
  final String locationName;
  final double latitude;
  final double longitude;
  final double timezone; // Offset from UTC in hours

  BirthDetails({
    required this.name,
    required this.dateTime,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.timezone = 5.5, // Default IST
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateTime': dateTime.toIso8601String(),
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }

  factory BirthDetails.fromJson(Map<String, dynamic> json) {
    return BirthDetails(
      name: json['name'],
      dateTime: DateTime.parse(json['dateTime']),
      locationName: json['locationName'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timezone: json['timezone'] ?? 5.5,
    );
  }
}

/// Complete Kundali Data
class VedicKundaliData {
  final double ayanamsa;
  final double lagna; // Ascendant longitude in degrees
  final Map<String, PlanetInfo> planets;
  final Map<int, HouseInfo> houses;
  final VimshottariDasha currentDasha;
  final String lagnaSign;
  final String moonSign;
  final String sunSign;

  VedicKundaliData({
    required this.ayanamsa,
    required this.lagna,
    required this.planets,
    required this.houses,
    required this.currentDasha,
    required this.lagnaSign,
    required this.moonSign,
    required this.sunSign,
  });

  factory VedicKundaliData.placeholder() {
    return VedicKundaliData(
      ayanamsa: 0.0,
      lagna: 0.0,
      planets: {},
      houses: {},
      currentDasha: VimshottariDasha.placeholder(),
      lagnaSign: 'Aries',
      moonSign: 'Aries',
      sunSign: 'Aries',
    );
  }
}

/// Planet Information
class PlanetInfo {
  final String name;
  final double longitude; // Tropical longitude in degrees
  final double siderealLongitude; // Sidereal longitude after Ayanamsa
  final String sign;
  final int house;
  final double degree;
  final bool isRetrograde;
  final String nakshatra;
  final int nakshatraPada;

  PlanetInfo({
    required this.name,
    required this.longitude,
    required this.siderealLongitude,
    required this.sign,
    required this.house,
    required this.degree,
    this.isRetrograde = false,
    required this.nakshatra,
    required this.nakshatraPada,
  });

  factory PlanetInfo.placeholder(String name) {
    return PlanetInfo(
      name: name,
      longitude: 0.0,
      siderealLongitude: 0.0,
      sign: 'Aries',
      house: 1,
      degree: 0.0,
      nakshatra: 'Ashwini',
      nakshatraPada: 1,
    );
  }
}

/// House Information
class HouseInfo {
  final int houseNumber;
  final double cuspLongitude; // Starting degree of the house
  final String sign;
  final List<String> planetsInHouse;

  HouseInfo({
    required this.houseNumber,
    required this.cuspLongitude,
    required this.sign,
    required this.planetsInHouse,
  });

  factory HouseInfo.placeholder(int number) {
    return HouseInfo(
      houseNumber: number,
      cuspLongitude: 0.0,
      sign: 'Aries',
      planetsInHouse: [],
    );
  }
}

/// Vimshottari Dasha Information
class VimshottariDasha {
  final String mahadasha;
  final DateTime mahadashaStart;
  final DateTime mahadashaEnd;
  final String antardasha;
  final DateTime antardashaStart;
  final DateTime antardashaEnd;
  final String pratyantardasha;

  VimshottariDasha({
    required this.mahadasha,
    required this.mahadashaStart,
    required this.mahadashaEnd,
    required this.antardasha,
    required this.antardashaStart,
    required this.antardashaEnd,
    required this.pratyantardasha,
  });

  factory VimshottariDasha.placeholder() {
    final now = DateTime.now();
    return VimshottariDasha(
      mahadasha: 'Sun',
      mahadashaStart: now,
      mahadashaEnd: now.add(const Duration(days: 365 * 6)),
      antardasha: 'Sun',
      antardashaStart: now,
      antardashaEnd: now.add(const Duration(days: 109)),
      pratyantardasha: 'Sun',
    );
  }
}

/// Zodiac Signs
class ZodiacSign {
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

  static String getSign(double longitude) {
    final normalizedLong = longitude % 360;
    final signIndex = (normalizedLong / 30).floor();
    return signs[signIndex % 12];
  }

  static int getSignNumber(double longitude) {
    final normalizedLong = longitude % 360;
    return ((normalizedLong / 30).floor() % 12) + 1;
  }
}

/// Nakshatras (27 Lunar Mansions)
class Nakshatra {
  static const List<String> nakshatras = [
    'Ashwini',
    'Bharani',
    'Krittika',
    'Rohini',
    'Mrigashira',
    'Ardra',
    'Punarvasu',
    'Pushya',
    'Ashlesha',
    'Magha',
    'Purva Phalguni',
    'Uttara Phalguni',
    'Hasta',
    'Chitra',
    'Swati',
    'Vishakha',
    'Anuradha',
    'Jyeshtha',
    'Mula',
    'Purva Ashadha',
    'Uttara Ashadha',
    'Shravana',
    'Dhanishta',
    'Shatabhisha',
    'Purva Bhadrapada',
    'Uttara Bhadrapada',
    'Revati',
  ];

  static String getNakshatra(double longitude) {
    final normalizedLong = longitude % 360;
    final nakshatraIndex = (normalizedLong / 13.333333).floor();
    return nakshatras[nakshatraIndex % 27];
  }

  static int getNakshatraPada(double longitude) {
    final normalizedLong = longitude % 360;
    final withinNakshatra = normalizedLong % 13.333333;
    return ((withinNakshatra / 3.333333).floor() % 4) + 1;
  }
}
