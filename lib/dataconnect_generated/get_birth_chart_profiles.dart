part of 'generated.dart';

class GetBirthChartProfilesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetBirthChartProfilesVariablesBuilder(this._dataConnect, );
  Deserializer<GetBirthChartProfilesData> dataDeserializer = (dynamic json)  => GetBirthChartProfilesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetBirthChartProfilesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<GetBirthChartProfilesData, void> ref() {
    
    return _dataConnect.query("GetBirthChartProfiles", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class GetBirthChartProfilesBirthChartProfiles {
  final String id;
  final String name;
  final DateTime birthDate;
  final Timestamp birthTime;
  final double birthLatitude;
  final double birthLongitude;
  final String birthLocationName;
  GetBirthChartProfilesBirthChartProfiles.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  birthDate = nativeFromJson<DateTime>(json['birthDate']),
  birthTime = Timestamp.fromJson(json['birthTime']),
  birthLatitude = nativeFromJson<double>(json['birthLatitude']),
  birthLongitude = nativeFromJson<double>(json['birthLongitude']),
  birthLocationName = nativeFromJson<String>(json['birthLocationName']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetBirthChartProfilesBirthChartProfiles otherTyped = other as GetBirthChartProfilesBirthChartProfiles;
    return id == otherTyped.id && 
    name == otherTyped.name && 
    birthDate == otherTyped.birthDate && 
    birthTime == otherTyped.birthTime && 
    birthLatitude == otherTyped.birthLatitude && 
    birthLongitude == otherTyped.birthLongitude && 
    birthLocationName == otherTyped.birthLocationName;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode, birthDate.hashCode, birthTime.hashCode, birthLatitude.hashCode, birthLongitude.hashCode, birthLocationName.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    json['birthDate'] = nativeToJson<DateTime>(birthDate);
    json['birthTime'] = birthTime.toJson();
    json['birthLatitude'] = nativeToJson<double>(birthLatitude);
    json['birthLongitude'] = nativeToJson<double>(birthLongitude);
    json['birthLocationName'] = nativeToJson<String>(birthLocationName);
    return json;
  }

  GetBirthChartProfilesBirthChartProfiles({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.birthLatitude,
    required this.birthLongitude,
    required this.birthLocationName,
  });
}

@immutable
class GetBirthChartProfilesData {
  final List<GetBirthChartProfilesBirthChartProfiles> birthChartProfiles;
  GetBirthChartProfilesData.fromJson(dynamic json):
  
  birthChartProfiles = (json['birthChartProfiles'] as List<dynamic>)
        .map((e) => GetBirthChartProfilesBirthChartProfiles.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetBirthChartProfilesData otherTyped = other as GetBirthChartProfilesData;
    return birthChartProfiles == otherTyped.birthChartProfiles;
    
  }
  @override
  int get hashCode => birthChartProfiles.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['birthChartProfiles'] = birthChartProfiles.map((e) => e.toJson()).toList();
    return json;
  }

  GetBirthChartProfilesData({
    required this.birthChartProfiles,
  });
}

