import 'dart:math';
import '../models/vedic_kundali_model.dart';

/// Vedic Kundali Calculator
/// Based on Vedic Astrology principles with Lahiri Ayanamsa
class VedicKundaliCalculator {
  final BirthDetails birthDetails;

  VedicKundaliCalculator(this.birthDetails);

  /// Main calculation method
  Future<VedicKundaliData> calculateKundaliData() async {
    // Calculate Julian Day Number
    final jd = _calculateJulianDay(birthDetails.dateTime);

    // Calculate Local Mean Time
    final lmt = _calculateLMT(birthDetails.dateTime, birthDetails.longitude);

    // Calculate Sidereal Time
    final siderealTime =
        _calculateSiderealTime(jd, lmt, birthDetails.longitude);

    // Calculate Lahiri Ayanamsa
    final ayanamsa = _calculateLahiriAyanamsa(jd);

    // Calculate Lagna (Ascendant)
    final lagna = _calculateLagna(siderealTime, birthDetails.latitude);
    final siderealLagna = (lagna - ayanamsa) % 360;
    final lagnaSign = ZodiacSign.getSign(siderealLagna);

    // Calculate Planetary Positions
    final planets = _calculatePlanetaryPositions(jd, ayanamsa);

    // Calculate Houses
    final houses = _calculateHouses(siderealLagna, planets);

    // Get Moon and Sun signs
    final moonSign = planets['Moon']?.sign ?? 'Aries';
    final sunSign = planets['Sun']?.sign ?? 'Aries';

    // Calculate Vimshottari Dasha
    final currentDasha = _calculateVimshottariDasha(
      planets['Moon']!.siderealLongitude,
      birthDetails.dateTime,
    );

    return VedicKundaliData(
      ayanamsa: ayanamsa,
      lagna: siderealLagna,
      planets: planets,
      houses: houses,
      currentDasha: currentDasha,
      lagnaSign: lagnaSign,
      moonSign: moonSign,
      sunSign: sunSign,
    );
  }

  /// Calculate Julian Day Number
  double _calculateJulianDay(DateTime dt) {
    final year = dt.year;
    final month = dt.month;
    final day = dt.day;
    final hour = dt.hour + dt.minute / 60.0 + dt.second / 3600.0;

    int a = ((14 - month) / 12).floor();
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;

    double jd = day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045 +
        (hour - 12) / 24;

    return jd;
  }

  /// Calculate Local Mean Time
  DateTime _calculateLMT(DateTime dt, double longitude) {
    // Convert longitude to time difference (4 minutes per degree)
    final timeDiff = longitude * 4 / 60; // in hours
    return dt.add(Duration(minutes: (timeDiff * 60).round()));
  }

  /// Calculate Sidereal Time
  double _calculateSiderealTime(double jd, DateTime lmt, double longitude) {
    // Calculate days since J2000.0
    final t = (jd - 2451545.0) / 36525.0;

    // Greenwich Mean Sidereal Time at 0h UT
    double gmst = 280.46061837 +
        360.98564736629 * (jd - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0;

    // Normalize to 0-360
    gmst = gmst % 360;
    if (gmst < 0) gmst += 360;

    // Add longitude to get Local Sidereal Time
    double lst = gmst + longitude;
    lst = lst % 360;
    if (lst < 0) lst += 360;

    // Add time of day
    final hourAngle = (lmt.hour + lmt.minute / 60.0 + lmt.second / 3600.0) * 15;
    lst = (lst + hourAngle) % 360;

    return lst;
  }

  /// Calculate Lahiri Ayanamsa (Chitrapaksha)
  double _calculateLahiriAyanamsa(double jd) {
    // Lahiri Ayanamsa formula
    // Base: 23° 15' 00" at 21 March 1956 (JD 2435553.0)
    final t = (jd - 2451545.0) / 36525.0; // Centuries from J2000.0

    // Ayanamsa at J2000.0 = 23.85° (approximately)
    // Annual precession rate = 50.2 arc-seconds = 0.01394444 degrees
    final ayanamsa = 23.85 + (50.2 / 3600.0) * (jd - 2451545.0) / 365.25;

    return ayanamsa;
  }

  /// Calculate Lagna (Ascendant)
  double _calculateLagna(double siderealTime, double latitude) {
    // Convert sidereal time to radians
    final st = siderealTime * pi / 180;
    final lat = latitude * pi / 180;

    // Calculate RAMC (Right Ascension of Midheaven)
    final ramc = siderealTime;

    // Calculate Ascendant using simplified formula
    // tan(Asc) = cos(RAMC) / (sin(RAMC) * cos(obliquity) - tan(lat) * sin(obliquity))
    final obliquity = 23.4397 * pi / 180; // Mean obliquity of ecliptic

    final numerator = cos(st);
    final denominator = sin(st) * cos(obliquity) - tan(lat) * sin(obliquity);

    double ascendant = atan2(numerator, denominator) * 180 / pi;

    // Normalize to 0-360
    if (ascendant < 0) ascendant += 360;

    return ascendant;
  }

  /// Calculate Planetary Positions (Simplified)
  Map<String, PlanetInfo> _calculatePlanetaryPositions(
    double jd,
    double ayanamsa,
  ) {
    // This is a simplified calculation
    // In production, use Swiss Ephemeris or similar library
    final t = (jd - 2451545.0) / 36525.0;

    final planets = <String, PlanetInfo>{};

    // Sun
    final sunLong = _calculateSunPosition(t);
    planets['Sun'] = _createPlanetInfo('Sun', sunLong, ayanamsa);

    // Moon
    final moonLong = _calculateMoonPosition(t);
    planets['Moon'] = _createPlanetInfo('Moon', moonLong, ayanamsa);

    // Mars
    final marsLong = _calculateMarsPosition(t);
    planets['Mars'] = _createPlanetInfo('Mars', marsLong, ayanamsa);

    // Mercury
    final mercuryLong = _calculateMercuryPosition(t);
    planets['Mercury'] = _createPlanetInfo('Mercury', mercuryLong, ayanamsa);

    // Jupiter
    final jupiterLong = _calculateJupiterPosition(t);
    planets['Jupiter'] = _createPlanetInfo('Jupiter', jupiterLong, ayanamsa);

    // Venus
    final venusLong = _calculateVenusPosition(t);
    planets['Venus'] = _createPlanetInfo('Venus', venusLong, ayanamsa);

    // Saturn
    final saturnLong = _calculateSaturnPosition(t);
    planets['Saturn'] = _createPlanetInfo('Saturn', saturnLong, ayanamsa);

    // Rahu (North Node) - Mean Node
    final rahuLong = 125.04 - 1934.136 * t;
    planets['Rahu'] = _createPlanetInfo('Rahu', rahuLong, ayanamsa);

    // Ketu (South Node) - 180° opposite to Rahu
    final ketuLong = (rahuLong + 180) % 360;
    planets['Ketu'] = _createPlanetInfo('Ketu', ketuLong, ayanamsa);

    return planets;
  }

  PlanetInfo _createPlanetInfo(
      String name, double tropicalLong, double ayanamsa) {
    final siderealLong = (tropicalLong - ayanamsa) % 360;
    final sign = ZodiacSign.getSign(siderealLong);
    final degree = siderealLong % 30;
    final nakshatra = Nakshatra.getNakshatra(siderealLong);
    final nakshatraPada = Nakshatra.getNakshatraPada(siderealLong);

    return PlanetInfo(
      name: name,
      longitude: tropicalLong,
      siderealLongitude: siderealLong,
      sign: sign,
      house: 1, // Will be calculated in _calculateHouses
      degree: degree,
      nakshatra: nakshatra,
      nakshatraPada: nakshatraPada,
    );
  }

  /// Simplified Sun position calculation
  double _calculateSunPosition(double t) {
    final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
    final m = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;
    final c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * sin(m * pi / 180) +
        (0.019993 - 0.000101 * t) * sin(2 * m * pi / 180) +
        0.000289 * sin(3 * m * pi / 180);

    return (l0 + c) % 360;
  }

  /// Simplified Moon position calculation
  double _calculateMoonPosition(double t) {
    final l = 218.316 + 481267.881 * t;
    final m = 134.963 + 477198.868 * t;
    final f = 93.272 + 483202.018 * t;

    final longitude = l +
        6.289 * sin(m * pi / 180) +
        1.274 * sin((2 * 218.316 - m) * pi / 180) +
        0.658 * sin(2 * f * pi / 180);

    return longitude % 360;
  }

  /// Simplified Mars position
  double _calculateMarsPosition(double t) {
    return (355.45 + 19140.30 * t) % 360;
  }

  /// Simplified Mercury position
  double _calculateMercuryPosition(double t) {
    return (252.25 + 149472.68 * t) % 360;
  }

  /// Simplified Jupiter position
  double _calculateJupiterPosition(double t) {
    return (34.35 + 3034.91 * t) % 360;
  }

  /// Simplified Venus position
  double _calculateVenusPosition(double t) {
    return (181.98 + 58517.82 * t) % 360;
  }

  /// Simplified Saturn position
  double _calculateSaturnPosition(double t) {
    return (50.08 + 1222.11 * t) % 360;
  }

  /// Calculate Houses
  Map<int, HouseInfo> _calculateHouses(
    double lagna,
    Map<String, PlanetInfo> planets,
  ) {
    final houses = <int, HouseInfo>{};

    // Equal House System - each house is 30 degrees
    for (int i = 1; i <= 12; i++) {
      final cuspLongitude = (lagna + (i - 1) * 30) % 360;
      final sign = ZodiacSign.getSign(cuspLongitude);

      // Find planets in this house
      final planetsInHouse = <String>[];
      planets.forEach((name, planet) {
        final planetHouse =
            ((planet.siderealLongitude - lagna) / 30).floor() + 1;
        if (planetHouse == i || (planetHouse <= 0 && i == planetHouse + 12)) {
          planetsInHouse.add(name);
        }
      });

      houses[i] = HouseInfo(
        houseNumber: i,
        cuspLongitude: cuspLongitude,
        sign: sign,
        planetsInHouse: planetsInHouse,
      );
    }

    // Update planet house numbers
    planets.forEach((name, planet) {
      final houseNum = ((planet.siderealLongitude - lagna) / 30).floor() + 1;
      final correctedHouse = houseNum <= 0 ? houseNum + 12 : houseNum;
      planets[name] = PlanetInfo(
        name: planet.name,
        longitude: planet.longitude,
        siderealLongitude: planet.siderealLongitude,
        sign: planet.sign,
        house: correctedHouse > 12 ? correctedHouse - 12 : correctedHouse,
        degree: planet.degree,
        isRetrograde: planet.isRetrograde,
        nakshatra: planet.nakshatra,
        nakshatraPada: planet.nakshatraPada,
      );
    });

    return houses;
  }

  /// Calculate Vimshottari Dasha
  VimshottariDasha _calculateVimshottariDasha(
    double moonLongitude,
    DateTime birthDate,
  ) {
    // Vimshottari Dasha periods in years
    final dashaYears = {
      'Ketu': 7,
      'Venus': 20,
      'Sun': 6,
      'Moon': 10,
      'Mars': 7,
      'Rahu': 18,
      'Jupiter': 16,
      'Saturn': 19,
      'Mercury': 17,
    };

    final dashaOrder = [
      'Ketu',
      'Venus',
      'Sun',
      'Moon',
      'Mars',
      'Rahu',
      'Jupiter',
      'Saturn',
      'Mercury',
    ];

    // Determine starting Dasha based on Moon's Nakshatra
    final nakshatraIndex = (moonLongitude / 13.333333).floor() % 27;
    final dashaLordIndex = nakshatraIndex % 9;
    final dashaLord = dashaOrder[dashaLordIndex];

    // Calculate balance of Dasha at birth
    final nakshatraProgress = (moonLongitude % 13.333333) / 13.333333;
    final dashaBalance = dashaYears[dashaLord]! * (1 - nakshatraProgress);

    // Calculate Mahadasha start and end
    final mahadashaStart = birthDate.subtract(
      Duration(days: (dashaBalance * 365.25).round()),
    );
    final mahadashaEnd = mahadashaStart.add(
      Duration(days: (dashaYears[dashaLord]! * 365.25).round()),
    );

    // Find current Mahadasha
    DateTime currentDate = DateTime.now();
    String currentMahadasha = dashaLord;
    DateTime currentMahaStart = mahadashaStart;
    DateTime currentMahaEnd = mahadashaEnd;

    if (currentDate.isAfter(mahadashaEnd)) {
      // Calculate which Mahadasha we're in
      int daysFromBirth = currentDate.difference(birthDate).inDays;
      int totalDays = (dashaBalance * 365.25).round();

      for (int i = 0; i < dashaOrder.length * 2; i++) {
        final lordIndex = (dashaLordIndex + i + 1) % 9;
        final lord = dashaOrder[lordIndex];
        final years = dashaYears[lord]!;
        final days = (years * 365.25).round();

        if (totalDays + days > daysFromBirth) {
          currentMahadasha = lord;
          currentMahaStart = birthDate.add(Duration(days: totalDays));
          currentMahaEnd = currentMahaStart.add(Duration(days: days));
          break;
        }
        totalDays += days;
      }
    }

    // Calculate Antardasha (simplified - using proportional division)
    final mahadashaProgress = currentDate.difference(currentMahaStart).inDays /
        currentMahaEnd.difference(currentMahaStart).inDays;

    return VimshottariDasha(
      mahadasha: currentMahadasha,
      mahadashaStart: currentMahaStart,
      mahadashaEnd: currentMahaEnd,
      antardasha: currentMahadasha, // Simplified
      antardashaStart: currentDate,
      antardashaEnd: currentDate.add(const Duration(days: 365)),
      pratyantardasha: currentMahadasha,
    );
  }
}
