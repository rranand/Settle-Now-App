import 'dart:convert';

import 'package:settlenow_v2/model/lenden_model.dart';

class LendenDataProvider {
  Future<List<LendenModel>> fetchData(String email) async {
    try {
      await Future.delayed(Duration(milliseconds: 3500));
      String dataStr =
          '''[{"id":"lend001","roomName":"Weekend Trip","status":"open","createdOn":"2024-04-20T10:00:00Z","modifiedOn":"2024-04-21T12:00:00Z","amount":1250.75,"users":[{"id":"user1","name":"Ava Carter","email":"ava.carter@example.com","profileImage":"https://picsum.photos/id/10/200/300"},{"id":"user2","name":"Liam Smith","email":"liam.smith@example.com","profileImage":"https://picsum.photos/id/11/200/300"}]},{"id":"lend002","roomName":"Birthday Bash","status":"closed","createdOn":"2024-03-10T14:30:00Z","modifiedOn":"2024-03-12T09:15:00Z","amount":850,"users":[{"id":"user3","name":"Olivia Johnson","email":"olivia.johnson@example.com","profileImage":"https://picsum.photos/id/12/200/300"},{"id":"user4","name":"Noah Williams","email":"noah.williams@example.com","profileImage":"https://picsum.photos/id/13/200/300"}]},{"id":"lend003","roomName":"Office Lunch","status":"partially closed","createdOn":"2024-04-15T09:00:00Z","modifiedOn":"2024-04-16T11:00:00Z","amount":410.5,"users":[{"id":"user5","name":"Ethan Davis","email":"ethan.davis@example.com","profileImage":"https://picsum.photos/id/14/200/300"},{"id":"user6","name":"Sophia Brown","email":"sophia.brown@example.com","profileImage":"https://picsum.photos/id/15/200/300"}]},{"id":"lend004","roomName":"House Party","status":"open","createdOn":"2024-04-01T19:00:00Z","modifiedOn":"2024-04-02T22:00:00Z","amount":675.25,"users":[{"id":"user7","name":"Mason Wilson","email":"mason.wilson@example.com","profileImage":"https://picsum.photos/id/16/200/300"},{"id":"user8","name":"Isabella Moore","email":"isabella.moore@example.com","profileImage":"https://picsum.photos/id/17/200/300"}]}]''';
      List<dynamic> tempArr = jsonDecode(dataStr);
      List<LendenModel> arr =
          tempArr.map((ele) => LendenModel.fromMap(ele)).toList();

      return arr;
    } catch (e) {
      rethrow;
    }
  }
}
