/// Kundali (Birth Chart) Model
class Kundali {
  final String id;
  final String userId;
  final String name;
  final DateTime dateOfBirth;
  final String timeOfBirth;
  final String placeOfBirth;
  final String? pdfPath;
  final KundaliData? data;
  final DateTime createdAt;

  Kundali({
    required this.id,
    required this.userId,
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    this.pdfPath,
    this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'timeOfBirth': timeOfBirth,
      'placeOfBirth': placeOfBirth,
      'pdfPath': pdfPath,
      'data': data?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Kundali.fromJson(Map<String, dynamic> json) {
    return Kundali(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      timeOfBirth: json['timeOfBirth'],
      placeOfBirth: json['placeOfBirth'],
      pdfPath: json['pdfPath'],
      data: json['data'] != null ? KundaliData.fromJson(json['data']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

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
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Kundali.fromMap(Map<String, dynamic> map) {
    return Kundali(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
      timeOfBirth: map['timeOfBirth'],
      placeOfBirth: map['placeOfBirth'],
      pdfPath: map['pdfPath'],
      data: null, // Parse from dataJson if needed
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

/// Kundali Data containing astrological information
class KundaliData {
  final String sunSign;
  final String moonSign;
  final String ascendant;
  final List<PlanetPosition> planets;
  final Map<String, String> houses;

  KundaliData({
    required this.sunSign,
    required this.moonSign,
    required this.ascendant,
    required this.planets,
    required this.houses,
  });

  Map<String, dynamic> toJson() {
    return {
      'sunSign': sunSign,
      'moonSign': moonSign,
      'ascendant': ascendant,
      'planets': planets.map((p) => p.toJson()).toList(),
      'houses': houses,
    };
  }

  factory KundaliData.fromJson(Map<String, dynamic> json) {
    return KundaliData(
      sunSign: json['sunSign'],
      moonSign: json['moonSign'],
      ascendant: json['ascendant'],
      planets: (json['planets'] as List)
          .map((p) => PlanetPosition.fromJson(p))
          .toList(),
      houses: Map<String, String>.from(json['houses']),
    );
  }
}

/// Planet Position in the birth chart
class PlanetPosition {
  final String name;
  final String sign;
  final String house;
  final double degree;

  PlanetPosition({
    required this.name,
    required this.sign,
    required this.house,
    required this.degree,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sign': sign,
      'house': house,
      'degree': degree,
    };
  }

  factory PlanetPosition.fromJson(Map<String, dynamic> json) {
    return PlanetPosition(
      name: json['name'],
      sign: json['sign'],
      house: json['house'],
      degree: json['degree'].toDouble(),
    );
  }
}
