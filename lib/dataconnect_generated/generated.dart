library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_user.dart';

part 'get_birth_chart_profiles.dart';

part 'create_birth_chart_profile.dart';

part 'delete_birth_chart_profile.dart';







class ExampleConnector {
  
  
  CreateUserVariablesBuilder createUser () {
    return CreateUserVariablesBuilder(dataConnect, );
  }
  
  
  GetBirthChartProfilesVariablesBuilder getBirthChartProfiles () {
    return GetBirthChartProfilesVariablesBuilder(dataConnect, );
  }
  
  
  CreateBirthChartProfileVariablesBuilder createBirthChartProfile ({required String name, required DateTime birthDate, required Timestamp birthTime, required double birthLatitude, required double birthLongitude, required String birthLocationName, }) {
    return CreateBirthChartProfileVariablesBuilder(dataConnect, name: name,birthDate: birthDate,birthTime: birthTime,birthLatitude: birthLatitude,birthLongitude: birthLongitude,birthLocationName: birthLocationName,);
  }
  
  
  DeleteBirthChartProfileVariablesBuilder deleteBirthChartProfile ({required String id, }) {
    return DeleteBirthChartProfileVariablesBuilder(dataConnect, id: id,);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'dishaajyoti',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}

