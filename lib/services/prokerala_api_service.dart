import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kundali_model.dart';

/// Prokerala API Service for generating accurate Kundali
/// Free API: https://api.prokerala.com/
class ProkeralaApiService {
  static final ProkeralaApiService instance = ProkeralaApiService._init();
  ProkeralaApiService._init();

  // TODO: Replace with your actual API key from https://api.prokerala.com/
  static const String _apiKey = 'YOUR_PROKERALA_API_KEY';
  static const String _baseUrl = 'https://api.prokerala.com/v2';

  /// Generate Kundali using Prokerala API
  Future<KundaliData> generateKundali({
    required DateTime dateOfBirth,
    required String timeOfBirth,
    required String placeOfBirth,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Parse time
      final timeParts = timeOfBirth.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

      // Format datetime for API
      final datetime = DateTime(
        dateOfBirth.year,
        dateOfBirth.month,
        dateOfBirth.day,
        hour,
        minute,
      );

      // API endpoint for birth chart
      final url = Uri.parse('$_baseUrl/astrology/birth-details');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'datetime': datetime.toIso8601String(),
          'coordinates': '$latitude,$longitude',
          'ayanamsa': 1, // Lahiri ayanamsa
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseKundaliData(data);
      } else {
        throw Exception('Failed to generate Kundali: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating Kundali: $e');
    }
  }

  KundaliData _parseKundaliData(Map<String, dynamic> data) {
    final result = data['data'];

    // Extract planetary positions
    final planets = <PlanetPosition>[];
    if (result['planets'] != null) {
      for (var planet in result['planets']) {
        planets.add(PlanetPosition(
          name: planet['name'] ?? '',
          sign: planet['sign'] ?? '',
          house: planet['house']?.toString() ?? '',
          degree: (planet['degree'] ?? 0).toDouble(),
        ));
      }
    }

    // Extract houses
    final houses = <String, String>{};
    if (result['houses'] != null) {
      for (var i = 0; i < result['houses'].length; i++) {
        houses['${i + 1}'] = result['houses'][i]['sign'] ?? '';
      }
    }

    return KundaliData(
      sunSign: result['sun_sign'] ?? 'Unknown',
      moonSign: result['moon_sign'] ?? 'Unknown',
      ascendant: result['ascendant'] ?? 'Unknown',
      planets: planets,
      houses: houses,
    );
  }

  /// Get coordinates for a place using geocoding
  Future<Map<String, double>> getCoordinates(String place) async {
    // For now, return default coordinates (Delhi)
    // TODO: Integrate with a geocoding service
    return {
      'latitude': 28.6139,
      'longitude': 77.2090,
    };
  }
}
