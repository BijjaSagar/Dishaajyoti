class Profile {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final DateTime dateOfBirth;
  final String timeOfBirth;
  final String placeOfBirth;
  final String career;
  final String goals;
  final String challenges;
  final Map<String, bool> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.career,
    required this.goals,
    required this.challenges,
    Map<String, bool>? preferences,
    required this.createdAt,
    required this.updatedAt,
  }) : preferences =
            preferences ?? {'notifications': true, 'newsletter': false};

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      timeOfBirth: json['timeOfBirth'] as String,
      placeOfBirth: json['placeOfBirth'] as String,
      career: json['career'] as String,
      goals: json['goals'] as String,
      challenges: json['challenges'] as String,
      preferences: json['preferences'] != null
          ? Map<String, bool>.from(json['preferences'] as Map)
          : {'notifications': true, 'newsletter': false},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'timeOfBirth': timeOfBirth,
      'placeOfBirth': placeOfBirth,
      'career': career,
      'goals': goals,
      'challenges': challenges,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    String? timeOfBirth,
    String? placeOfBirth,
    String? career,
    String? goals,
    String? challenges,
    Map<String, bool>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      career: career ?? this.career,
      goals: goals ?? this.goals,
      challenges: challenges ?? this.challenges,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
