import 'dart:math';
import '../models/kundali_model.dart';

/// Kundali Service for generating birth chart data
/// This is a simplified version - in production, use a proper Vedic astrology library
class KundaliService {
  static final KundaliService instance = KundaliService._init();
  KundaliService._init();

  /// Generate Kundali data based on birth details
  Future<KundaliData> generateKundali({
    required DateTime dateOfBirth,
    required String timeOfBirth,
    required String placeOfBirth,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // In production, this would call a real Vedic astrology API
    // For now, we'll generate sample data based on birth date

    final sunSign = _calculateSunSign(dateOfBirth);
    final moonSign = _calculateMoonSign(dateOfBirth);
    final ascendant = _calculateAscendant(dateOfBirth, timeOfBirth);
    final planets = _generatePlanetPositions(dateOfBirth);
    final houses = _generateHouses();

    return KundaliData(
      sunSign: sunSign,
      moonSign: moonSign,
      ascendant: ascendant,
      planets: planets,
      houses: houses,
    );
  }

  String _calculateSunSign(DateTime date) {
    final month = date.month;
    final day = date.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21))
      return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21))
      return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19))
      return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18))
      return 'Aquarius';
    return 'Pisces';
  }

  String _calculateMoonSign(DateTime date) {
    // Simplified calculation - in production use proper lunar calculations
    final signs = [
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
      'Pisces'
    ];
    final index = (date.day + date.month) % 12;
    return signs[index];
  }

  String _calculateAscendant(DateTime date, String time) {
    // Simplified calculation - in production use proper ascendant calculations
    final signs = [
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
      'Pisces'
    ];
    final hour = int.tryParse(time.split(':')[0]) ?? 0;
    final index = (hour + date.day) % 12;
    return signs[index];
  }

  List<PlanetPosition> _generatePlanetPositions(DateTime date) {
    final signs = [
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
      'Pisces'
    ];

    final planets = [
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
      'Rahu',
      'Ketu'
    ];

    final random = Random(date.millisecondsSinceEpoch);

    return planets.map((planet) {
      final signIndex = random.nextInt(12);
      final houseIndex = random.nextInt(12) + 1;
      final degree = random.nextDouble() * 30;

      return PlanetPosition(
        name: planet,
        sign: signs[signIndex],
        house: houseIndex.toString(),
        degree: degree,
      );
    }).toList();
  }

  Map<String, String> _generateHouses() {
    final signs = [
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
      'Pisces'
    ];

    return {
      '1': signs[0],
      '2': signs[1],
      '3': signs[2],
      '4': signs[3],
      '5': signs[4],
      '6': signs[5],
      '7': signs[6],
      '8': signs[7],
      '9': signs[8],
      '10': signs[9],
      '11': signs[10],
      '12': signs[11],
    };
  }

  /// Get basic predictions based on Kundali data
  Map<String, String> getBasicPredictions(KundaliData data) {
    return {
      'Career': _getCareerPrediction(data.sunSign),
      'Health': _getHealthPrediction(data.moonSign),
      'Relationships': _getRelationshipPrediction(data.ascendant),
      'Finance': _getFinancePrediction(data.sunSign),
    };
  }

  String _getCareerPrediction(String sunSign) {
    final predictions = {
      'Aries': 'Leadership roles and entrepreneurship suit you well.',
      'Taurus': 'Finance, banking, and stable careers are favorable.',
      'Gemini': 'Communication, media, and teaching are ideal fields.',
      'Cancer': 'Caring professions like healthcare and hospitality.',
      'Leo': 'Creative fields, management, and entertainment.',
      'Virgo': 'Analytical roles, research, and service sectors.',
      'Libra': 'Law, diplomacy, and artistic professions.',
      'Scorpio': 'Investigation, research, and transformative work.',
      'Sagittarius': 'Education, travel, and philosophical pursuits.',
      'Capricorn': 'Administration, government, and structured careers.',
      'Aquarius': 'Technology, innovation, and humanitarian work.',
      'Pisces': 'Creative arts, spirituality, and healing professions.',
    };
    return predictions[sunSign] ?? 'Follow your passion and intuition.';
  }

  String _getHealthPrediction(String moonSign) {
    return 'Maintain emotional balance and regular health checkups. Focus on mental wellness.';
  }

  String _getRelationshipPrediction(String ascendant) {
    return 'Communication and understanding are key to harmonious relationships.';
  }

  String _getFinancePrediction(String sunSign) {
    return 'Financial stability comes through disciplined savings and wise investments.';
  }
}
