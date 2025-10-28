part of 'generated.dart';

class DeleteBirthChartProfileVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  DeleteBirthChartProfileVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<DeleteBirthChartProfileData> dataDeserializer = (dynamic json)  => DeleteBirthChartProfileData.fromJson(jsonDecode(json));
  Serializer<DeleteBirthChartProfileVariables> varsSerializer = (DeleteBirthChartProfileVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeleteBirthChartProfileData, DeleteBirthChartProfileVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteBirthChartProfileData, DeleteBirthChartProfileVariables> ref() {
    DeleteBirthChartProfileVariables vars= DeleteBirthChartProfileVariables(id: id,);
    return _dataConnect.mutation("DeleteBirthChartProfile", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DeleteBirthChartProfileBirthChartProfileDelete {
  final String id;
  DeleteBirthChartProfileBirthChartProfileDelete.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteBirthChartProfileBirthChartProfileDelete otherTyped = other as DeleteBirthChartProfileBirthChartProfileDelete;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  DeleteBirthChartProfileBirthChartProfileDelete({
    required this.id,
  });
}

@immutable
class DeleteBirthChartProfileData {
  final DeleteBirthChartProfileBirthChartProfileDelete? birthChartProfile_delete;
  DeleteBirthChartProfileData.fromJson(dynamic json):
  
  birthChartProfile_delete = json['birthChartProfile_delete'] == null ? null : DeleteBirthChartProfileBirthChartProfileDelete.fromJson(json['birthChartProfile_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteBirthChartProfileData otherTyped = other as DeleteBirthChartProfileData;
    return birthChartProfile_delete == otherTyped.birthChartProfile_delete;
    
  }
  @override
  int get hashCode => birthChartProfile_delete.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (birthChartProfile_delete != null) {
      json['birthChartProfile_delete'] = birthChartProfile_delete!.toJson();
    }
    return json;
  }

  DeleteBirthChartProfileData({
    this.birthChartProfile_delete,
  });
}

@immutable
class DeleteBirthChartProfileVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteBirthChartProfileVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteBirthChartProfileVariables otherTyped = other as DeleteBirthChartProfileVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  DeleteBirthChartProfileVariables({
    required this.id,
  });
}

