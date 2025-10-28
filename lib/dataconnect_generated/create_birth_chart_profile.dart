part of 'generated.dart';

class CreateBirthChartProfileVariablesBuilder {
  String name;
  DateTime birthDate;
  Timestamp birthTime;
  double birthLatitude;
  double birthLongitude;
  String birthLocationName;
  Optional<String> _notes = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CreateBirthChartProfileVariablesBuilder notes(String? t) {
   _notes.value = t;
   return this;
  }

  CreateBirthChartProfileVariablesBuilder(this._dataConnect, {required  this.name,required  this.birthDate,required  this.birthTime,required  this.birthLatitude,required  this.birthLongitude,required  this.birthLocationName,});
  Deserializer<CreateBirthChartProfileData> dataDeserializer = (dynamic json)  => CreateBirthChartProfileData.fromJson(jsonDecode(json));
  Serializer<CreateBirthChartProfileVariables> varsSerializer = (CreateBirthChartProfileVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateBirthChartProfileData, CreateBirthChartProfileVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateBirthChartProfileData, CreateBirthChartProfileVariables> ref() {
    CreateBirthChartProfileVariables vars= CreateBirthChartProfileVariables(name: name,birthDate: birthDate,birthTime: birthTime,birthLatitude: birthLatitude,birthLongitude: birthLongitude,birthLocationName: birthLocationName,notes: _notes,);
    return _dataConnect.mutation("CreateBirthChartProfile", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateBirthChartProfileBirthChartProfileInsert {
  final String id;
  CreateBirthChartProfileBirthChartProfileInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateBirthChartProfileBirthChartProfileInsert otherTyped = other as CreateBirthChartProfileBirthChartProfileInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateBirthChartProfileBirthChartProfileInsert({
    required this.id,
  });
}

@immutable
class CreateBirthChartProfileData {
  final CreateBirthChartProfileBirthChartProfileInsert birthChartProfile_insert;
  CreateBirthChartProfileData.fromJson(dynamic json):
  
  birthChartProfile_insert = CreateBirthChartProfileBirthChartProfileInsert.fromJson(json['birthChartProfile_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateBirthChartProfileData otherTyped = other as CreateBirthChartProfileData;
    return birthChartProfile_insert == otherTyped.birthChartProfile_insert;
    
  }
  @override
  int get hashCode => birthChartProfile_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['birthChartProfile_insert'] = birthChartProfile_insert.toJson();
    return json;
  }

  CreateBirthChartProfileData({
    required this.birthChartProfile_insert,
  });
}

@immutable
class CreateBirthChartProfileVariables {
  final String name;
  final DateTime birthDate;
  final Timestamp birthTime;
  final double birthLatitude;
  final double birthLongitude;
  final String birthLocationName;
  late final Optional<String>notes;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateBirthChartProfileVariables.fromJson(Map<String, dynamic> json):
  
  name = nativeFromJson<String>(json['name']),
  birthDate = nativeFromJson<DateTime>(json['birthDate']),
  birthTime = Timestamp.fromJson(json['birthTime']),
  birthLatitude = nativeFromJson<double>(json['birthLatitude']),
  birthLongitude = nativeFromJson<double>(json['birthLongitude']),
  birthLocationName = nativeFromJson<String>(json['birthLocationName']) {
  
  
  
  
  
  
  
  
    notes = Optional.optional(nativeFromJson, nativeToJson);
    notes.value = json['notes'] == null ? null : nativeFromJson<String>(json['notes']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateBirthChartProfileVariables otherTyped = other as CreateBirthChartProfileVariables;
    return name == otherTyped.name && 
    birthDate == otherTyped.birthDate && 
    birthTime == otherTyped.birthTime && 
    birthLatitude == otherTyped.birthLatitude && 
    birthLongitude == otherTyped.birthLongitude && 
    birthLocationName == otherTyped.birthLocationName && 
    notes == otherTyped.notes;
    
  }
  @override
  int get hashCode => Object.hashAll([name.hashCode, birthDate.hashCode, birthTime.hashCode, birthLatitude.hashCode, birthLongitude.hashCode, birthLocationName.hashCode, notes.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    json['birthDate'] = nativeToJson<DateTime>(birthDate);
    json['birthTime'] = birthTime.toJson();
    json['birthLatitude'] = nativeToJson<double>(birthLatitude);
    json['birthLongitude'] = nativeToJson<double>(birthLongitude);
    json['birthLocationName'] = nativeToJson<String>(birthLocationName);
    if(notes.state == OptionalState.set) {
      json['notes'] = notes.toJson();
    }
    return json;
  }

  CreateBirthChartProfileVariables({
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.birthLatitude,
    required this.birthLongitude,
    required this.birthLocationName,
    required this.notes,
  });
}

