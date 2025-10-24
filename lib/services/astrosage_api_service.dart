import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kundali_model.dart';

/// AstroSage-style API Service for Kundali generation
/// This uses a generic Vedic astrology API format
class AstroSageApiService {
  static final AstroSageApiService instance = AstroSageApiService._init();
  AstroSageApiService._init();

  // TODO: Replace with actual API credentials
  static const String _apiKey = 'YOUR_API_KEY';
  static const String _userId = 'YOUR_USER_ID';
  static const String _baseUrl = 'https://json.astrologyapi.com/v1';

  /// Generate Kundali chart
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

      final requestBody = {
        'day': dateOfBirth.day,
        'month': dateOfBirth.month,
        'year': dateOfBirth.year,
        'hour': hour,
        'min': minute,
        'lat': latitude,
        'lon': longitude,
        'tzone': 5.5, // IST timezone
      };

      // Get birth details
      final birthDetailsUrl = Uri.parse('$_baseUrl/birth_details');
      final birthResponse = await _makeRequest(birthDetailsUrl, requestBody);

      // Get planetary positions
      final planetsUrl = Uri.parse('$_baseUrl/planets');
      final planetsResponse = await _makeRequest(planetsUrl, requestBody);

      // Get houses
      final housesUrl = Uri.parse('$_baseUrl/houses');
      final housesResponse = await _makeRequest(housesUrl, requestBody);

      return _parseKundaliData(
        birthResponse,
        planetsResponse,
        housesResponse,
      );
    } catch (e) {
      throw Exception('Error generating Kundali: $e');
    }
  }

  Future<Map<String, dynamic>> _makeRequest(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    final credentials = base64Encode(utf8.encode('$_userId:$_apiKey'));

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API request failed: ${response.statusCode}');
    }
  }

  KundaliData _parseKundaliData(
    Map<String, dynamic> birthDetails,
    Map<String, dynamic> planetsData,
    Map<String, dynamic> housesData,
  ) {
    // Parse planets
    final planets = <PlanetPosition>[];
    if (planetsData['planets'] != null) {
      for (var planet in planetsData['planets']) {
        planets.add(PlanetPosition(
          name: planet['name'] ?? '',
          sign: planet['sign'] ?? '',
          house: planet['house']?.toString() ?? '',
          degree: (planet['full_degree'] ?? 0).toDouble(),
        ));
      }
    }

    // Parse houses
    final houses = <String, String>{};
    if (housesData['houses'] != null) {
      for (var i = 0; i < housesData['houses'].length; i++) {
        houses['${i + 1}'] = housesData['houses'][i]['sign'] ?? '';
      }
    }

    return KundaliData(
      sunSign: birthDetails['sun_sign'] ?? 'Unknown',
      moonSign: birthDetails['moon_sign'] ?? 'Unknown',
      ascendant: birthDetails['ascendant'] ?? 'Unknown',
      planets: planets,
      houses: houses,
    );
  }

  /// Download Kundali PDF from API
  Future<String?> downloadKundaliPdf({
    required DateTime dateOfBirth,
    required String timeOfBirth,
    required double latitude,
    required double longitude,
    required String savePath,
  }) async {
    try {
      final timeParts = timeOfBirth.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

      final requestBody = {
        'day': dateOfBirth.day,
        'month': dateOfBirth.month,
        'year': dateOfBirth.year,
        'hour': hour,
        'min': minute,
        'lat': latitude,
        'lon': longitude,
        'tzone': 5.5,
      };

      final url = Uri.parse('$_baseUrl/pdf/kundli');
      final credentials = base64Encode(utf8.encode('$_userId:$_apiKey'));

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Decode JSON response
        final responseData = jsonDecode(response.body);

        // Save PDF bytes to file
        final file = await http.get(Uri.parse(responseData['pdf_url']));
        // TODO: Save file to savePath
        return savePath;
      }

      return null;
    } catch (e) {
      print('Error downloading PDF: $e');
      return null;
    }
  }
}
