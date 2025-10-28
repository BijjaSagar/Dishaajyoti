import 'dart:convert';
import 'package:http/http.dart' as http;

/// Geocoding Service to get coordinates from place name
class GeocodingService {
  static final GeocodingService instance = GeocodingService._init();
  GeocodingService._init();

  /// Get coordinates from place name using Nominatim (OpenStreetMap)
  /// Free and no API key required
  Future<Map<String, double>?> getCoordinates(String placeName) async {
    try {
      final encodedPlace = Uri.encodeComponent(placeName);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encodedPlace&format=json&limit=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'DishaAjyoti/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          final location = data[0];
          return {
            'latitude': double.parse(location['lat']),
            'longitude': double.parse(location['lon']),
          };
        }
      }

      return null;
    } catch (e) {
      print('Error fetching coordinates: $e');
      return null;
    }
  }

  /// Get coordinates with better accuracy for Indian cities
  Future<Map<String, double>?> getIndianCityCoordinates(String cityName) async {
    // Common Indian cities with accurate coordinates
    final indianCities = {
      'mumbai': {'latitude': 19.0760, 'longitude': 72.8777},
      'delhi': {'latitude': 28.7041, 'longitude': 77.1025},
      'bangalore': {'latitude': 12.9716, 'longitude': 77.5946},
      'bengaluru': {'latitude': 12.9716, 'longitude': 77.5946},
      'kolkata': {'latitude': 22.5726, 'longitude': 88.3639},
      'chennai': {'latitude': 13.0827, 'longitude': 80.2707},
      'hyderabad': {'latitude': 17.3850, 'longitude': 78.4867},
      'pune': {'latitude': 18.5204, 'longitude': 73.8567},
      'ahmedabad': {'latitude': 23.0225, 'longitude': 72.5714},
      'jaipur': {'latitude': 26.9124, 'longitude': 75.7873},
      'surat': {'latitude': 21.1702, 'longitude': 72.8311},
      'lucknow': {'latitude': 26.8467, 'longitude': 80.9462},
      'kanpur': {'latitude': 26.4499, 'longitude': 80.3319},
      'nagpur': {'latitude': 21.1458, 'longitude': 79.0882},
      'indore': {'latitude': 22.7196, 'longitude': 75.8577},
      'thane': {'latitude': 19.2183, 'longitude': 72.9781},
      'bhopal': {'latitude': 23.2599, 'longitude': 77.4126},
      'visakhapatnam': {'latitude': 17.6868, 'longitude': 83.2185},
      'pimpri-chinchwad': {'latitude': 18.6298, 'longitude': 73.7997},
      'patna': {'latitude': 25.5941, 'longitude': 85.1376},
      'vadodara': {'latitude': 22.3072, 'longitude': 73.1812},
      'ghaziabad': {'latitude': 28.6692, 'longitude': 77.4538},
      'ludhiana': {'latitude': 30.9010, 'longitude': 75.8573},
      'agra': {'latitude': 27.1767, 'longitude': 78.0081},
      'nashik': {'latitude': 19.9975, 'longitude': 73.7898},
      'faridabad': {'latitude': 28.4089, 'longitude': 77.3178},
      'meerut': {'latitude': 28.9845, 'longitude': 77.7064},
      'rajkot': {'latitude': 22.3039, 'longitude': 70.8022},
      'varanasi': {'latitude': 25.3176, 'longitude': 82.9739},
      'srinagar': {'latitude': 34.0837, 'longitude': 74.7973},
      'amritsar': {'latitude': 31.6340, 'longitude': 74.8723},
      'allahabad': {'latitude': 25.4358, 'longitude': 81.8463},
      'prayagraj': {'latitude': 25.4358, 'longitude': 81.8463},
      'ranchi': {'latitude': 23.3441, 'longitude': 85.3096},
      'howrah': {'latitude': 22.5958, 'longitude': 88.2636},
      'coimbatore': {'latitude': 11.0168, 'longitude': 76.9558},
      'jabalpur': {'latitude': 23.1815, 'longitude': 79.9864},
      'gwalior': {'latitude': 26.2183, 'longitude': 78.1828},
      'vijayawada': {'latitude': 16.5062, 'longitude': 80.6480},
      'jodhpur': {'latitude': 26.2389, 'longitude': 73.0243},
      'madurai': {'latitude': 9.9252, 'longitude': 78.1198},
      'raipur': {'latitude': 21.2514, 'longitude': 81.6296},
      'kota': {'latitude': 25.2138, 'longitude': 75.8648},
      'chandigarh': {'latitude': 30.7333, 'longitude': 76.7794},
      'guwahati': {'latitude': 26.1445, 'longitude': 91.7362},
      'solapur': {'latitude': 17.6599, 'longitude': 75.9064},
      'hubli': {'latitude': 15.3647, 'longitude': 75.1240},
      'mysore': {'latitude': 12.2958, 'longitude': 76.6394},
      'mysuru': {'latitude': 12.2958, 'longitude': 76.6394},
      'tiruchirappalli': {'latitude': 10.7905, 'longitude': 78.7047},
      'tiruppur': {'latitude': 11.1085, 'longitude': 77.3411},
      'bareilly': {'latitude': 28.3670, 'longitude': 79.4304},
      'salem': {'latitude': 11.6643, 'longitude': 78.1460},
      'moradabad': {'latitude': 28.8389, 'longitude': 78.7378},
      'thiruvananthapuram': {'latitude': 8.5241, 'longitude': 76.9366},
      'trivandrum': {'latitude': 8.5241, 'longitude': 76.9366},
      'bhiwandi': {'latitude': 19.2961, 'longitude': 73.0629},
      'saharanpur': {'latitude': 29.9680, 'longitude': 77.5460},
      'gorakhpur': {'latitude': 26.7606, 'longitude': 83.3732},
      'guntur': {'latitude': 16.3067, 'longitude': 80.4365},
      'bikaner': {'latitude': 28.0229, 'longitude': 73.3119},
      'amravati': {'latitude': 20.9374, 'longitude': 77.7796},
      'noida': {'latitude': 28.5355, 'longitude': 77.3910},
      'jamshedpur': {'latitude': 22.8046, 'longitude': 86.2029},
      'bhilai': {'latitude': 21.2095, 'longitude': 81.3784},
      'cuttack': {'latitude': 20.4625, 'longitude': 85.8830},
      'firozabad': {'latitude': 27.1591, 'longitude': 78.3957},
      'kochi': {'latitude': 9.9312, 'longitude': 76.2673},
      'cochin': {'latitude': 9.9312, 'longitude': 76.2673},
      'bhavnagar': {'latitude': 21.7645, 'longitude': 72.1519},
      'dehradun': {'latitude': 30.3165, 'longitude': 78.0322},
      'durgapur': {'latitude': 23.5204, 'longitude': 87.3119},
      'asansol': {'latitude': 23.6739, 'longitude': 86.9524},
      'nanded': {'latitude': 19.1383, 'longitude': 77.3210},
      'kolhapur': {'latitude': 16.7050, 'longitude': 74.2433},
      'ajmer': {'latitude': 26.4499, 'longitude': 74.6399},
      'akola': {'latitude': 20.7002, 'longitude': 77.0082},
      'gulbarga': {'latitude': 17.3297, 'longitude': 76.8343},
      'jamnagar': {'latitude': 22.4707, 'longitude': 70.0577},
      'ujjain': {'latitude': 23.1765, 'longitude': 75.7885},
      'loni': {'latitude': 28.7520, 'longitude': 77.2864},
      'siliguri': {'latitude': 26.7271, 'longitude': 88.3953},
      'jhansi': {'latitude': 25.4484, 'longitude': 78.5685},
      'ulhasnagar': {'latitude': 19.2183, 'longitude': 73.1382},
      'jammu': {'latitude': 32.7266, 'longitude': 74.8570},
      'mangalore': {'latitude': 12.9141, 'longitude': 74.8560},
      'erode': {'latitude': 11.3410, 'longitude': 77.7172},
      'belgaum': {'latitude': 15.8497, 'longitude': 74.4977},
      'ambattur': {'latitude': 13.1143, 'longitude': 80.1548},
      'tirunelveli': {'latitude': 8.7139, 'longitude': 77.7567},
      'malegaon': {'latitude': 20.5579, 'longitude': 74.5287},
      'gaya': {'latitude': 24.7955, 'longitude': 85.0002},
      'jalgaon': {'latitude': 21.0077, 'longitude': 75.5626},
      'udaipur': {'latitude': 24.5854, 'longitude': 73.7125},
      'maheshtala': {'latitude': 22.5093, 'longitude': 88.2477},
    };

    final normalizedCity = cityName.toLowerCase().trim();

    // Check if it's a known Indian city
    if (indianCities.containsKey(normalizedCity)) {
      return indianCities[normalizedCity];
    }

    // If not found in local database, try online geocoding
    return await getCoordinates(cityName);
  }
}
