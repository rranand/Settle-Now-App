import 'dart:convert';

import 'package:settlenow_v2/model/room_info_model.dart';

class RoomDashboardDataProvider {
  Future<List<RoomInfoModel>> fetchData(String email) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      String dataStr =
          '''[{"id":"1","roomName":"Development Team","createdOn":"2023-05-15T09:30:00Z","modifiedOn":"2023-05-20T14:45:00Z","status":"Open","users":[{"id":"101","name":"John Doe","email":"john@example.com","profileImage":"https://picsum.photos/id/42/200/300"},{"id":"102","name":"Jane Smith","email":"jane@example.com","profileImage":"https://picsum.photos/id/78/200/300"}]},{"id":"2","roomName":"Marketing Discussion","createdOn":"2023-04-10T11:15:00Z","modifiedOn":"2023-04-12T16:20:00Z","status":"Closed","users":[{"id":"201","name":"Alex Johnson","email":"alex@example.com","profileImage":"https://picsum.photos/id/135/200/300"},{"id":"202","name":"Sarah Williams","email":"sarah@example.com","profileImage":"https://picsum.photos/id/89/200/300"},{"id":"203","name":"Mike Brown","email":"mike@example.com","profileImage":"https://picsum.photos/id/156/200/300"}]},{"id":"3","roomName":"Project Alpha","createdOn":"2023-06-01T08:00:00Z","modifiedOn":"2023-06-05T10:30:00Z","status":"Partially Closed","users":[{"id":"301","name":"Emily Davis","email":"emily@example.com","profileImage":"https://picsum.photos/id/23/200/300"},{"id":"302","name":"David Wilson","email":"david@example.com","profileImage":"https://picsum.photos/id/187/200/300"}]},{"id":"4","roomName":"Design Review","createdOn":"2023-03-22T13:45:00Z","modifiedOn":"2023-03-25T15:10:00Z","status":"Open","users":[{"id":"401","name":"Lisa Chen","email":"lisa@example.com","profileImage":"https://picsum.photos/id/64/200/300"},{"id":"402","name":"Robert Taylor","email":"robert@example.com","profileImage":"https://picsum.photos/id/112/200/300"},{"id":"403","name":"Olivia Martinez","email":"olivia@example.com","profileImage":"https://picsum.photos/id/199/200/300"}]},{"id":"5","roomName":"QA Testing","createdOn":"2023-07-10T10:20:00Z","modifiedOn":"2023-07-12T11:45:00Z","status":"Closed","users":[{"id":"501","name":"Daniel Anderson","email":"daniel@example.com","profileImage":"https://picsum.photos/id/5/200/300"},{"id":"502","name":"Sophia Thomas","email":"sophia@example.com","profileImage":"https://picsum.photos/id/76/200/300"}]},{"id":"6","roomName":"Client Meeting","createdOn":"2023-02-18T14:00:00Z","modifiedOn":"2023-02-20T16:30:00Z","status":"Open","users":[{"id":"601","name":"Michael Clark","email":"michael@example.com","profileImage":"https://picsum.photos/id/143/200/300"},{"id":"602","name":"Emma Rodriguez","email":"emma@example.com","profileImage":"https://picsum.photos/id/88/200/300"},{"id":"603","name":"James Lewis","email":"james@example.com","profileImage":"https://picsum.photos/id/121/200/300"},{"id":"604","name":"Ava Walker","email":"ava@example.com","profileImage":"https://picsum.photos/id/34/200/300"}]},{"id":"7","roomName":"HR Policies","createdOn":"2023-01-05T09:00:00Z","modifiedOn":"2023-01-10T11:15:00Z","status":"Partially Closed","users":[{"id":"701","name":"William Hall","email":"william@example.com","profileImage":"https://picsum.photos/id/167/200/300"},{"id":"702","name":"Charlotte Young","email":"charlotte@example.com","profileImage":"https://picsum.photos/id/92/200/300"}]}]''';

      List<dynamic> tempArr = jsonDecode(dataStr);
      List<RoomInfoModel> arr =
          tempArr.map((ele) => RoomInfoModel.fromMap(ele)).toList();

      return arr;
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomInfoModel> createRoom(String roomName) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      RoomInfoModel data = RoomInfoModel(
        id: "${DateTime.now()}##$roomName",
        roomName: roomName,
        status: "Open",
        createdOn: DateTime.now(),
        modifiedOn: DateTime.now(),
        users: [],
      );
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> joinRoom(String roomKey) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
