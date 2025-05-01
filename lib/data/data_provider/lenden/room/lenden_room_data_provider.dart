import 'dart:convert';

import 'package:settlenow_v2/model/lenden_room_model.dart';

class LendenRoomDataProvider {
  Future<List<LendenRoomModel>> fetchData(String email, String id) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      String dataStr =
          '''[{"id":"1","amount":-1434.04,"description":"Movie tickets","createdOn":"2025-04-15T20:49:30.177240","createdBy":{"id":"user_1","name":"Rohit Anand","profileImage":""},"modifiedOn":"2025-04-16T20:49:30.177240"},{"id":"2","amount":-522.01,"description":"Bought snacks","createdOn":"2025-04-17T11:49:30.177274","createdBy":{"id":"user_2","name":"RA","profileImage":""},"modifiedOn":"2025-04-20T11:49:30.177274"},{"id":"3","amount":902.31,"description":"Movie tickets","createdOn":"2025-04-07T04:49:30.177288","createdBy":{"id":"user_2","name":"RA","profileImage":""},"modifiedOn":"2025-04-10T04:49:30.177288"},{"id":"4","amount":211.61,"description":"Electricity bill split","createdOn":"2025-04-06T14:49:30.177305","createdBy":{"id":"user_2","name":"RA","profileImage":""},"modifiedOn":"2025-04-06T14:49:30.177305"},{"id":"5","amount":908.79,"description":"Groceries","createdOn":"2025-04-28T22:49:30.177315","createdBy":{"id":"user_2","name":"RA","profileImage":""},"modifiedOn":"2025-05-01T22:49:30.177315"},{"id":"6","amount":1378.34,"description":"Bought snacks","createdOn":"2025-04-25T22:49:30.177325","createdBy":{"id":"user_1","name":"Rohit Anand","profileImage":""},"modifiedOn":"2025-04-27T22:49:30.177325"},{"id":"7","amount":-484.18,"description":"Shared cab fare","createdOn":"2025-04-20T23:49:30.177334","createdBy":{"id":"user_1","name":"Rohit Anand","profileImage":""},"modifiedOn":"2025-04-22T23:49:30.177334"},{"id":"8","amount":1228.55,"description":"Shared cab fare","createdOn":"2025-04-08T08:49:30.177346","createdBy":{"id":"user_1","name":"Rohit Anand","profileImage":""},"modifiedOn":"2025-04-10T08:49:30.177346"},{"id":"9","amount":-230.52,"description":"Paid for lunch","createdOn":"2025-04-25T06:49:30.177358","createdBy":{"id":"user_2","name":"RA","profileImage":""},"modifiedOn":"2025-04-28T06:49:30.177358"},{"id":"10","amount":286.25,"description":"Shared cab fare","createdOn":"2025-04-26T18:49:30.177367","createdBy":{"id":"user_1","name":"Rohit Anand","profileImage":""},"modifiedOn":"2025-04-27T18:49:30.177367"},{"id":"11","amount":-282.65,"description":"Groceries","createdOn":"2025-04-11T19:49:30.177389","createdBy":{"id":"user_2","name":"RA","profileImage":""},"modifiedOn":"2025-04-14T19:49:30.177389"},{"id":"12","amount":603.99,"description":"Bought snacks","createdOn":"2025-04-21T02:49:30.177399","createdBy":{"id":"user_2","name":"RA","profileImage":""},"modifiedOn":"2025-04-24T02:49:30.177399"},{"id":"13","amount":753.02,"description":"Electricity bill split","createdOn":"2025-04-08T23:49:30.177407","createdBy":{"id":"user_2","name":"RA","profileImage":""},"modifiedOn":"2025-04-10T23:49:30.177407"},{"id":"14","amount":1263.71,"description":"Paid for lunch","createdOn":"2025-04-24T10:49:30.177416","createdBy":{"id":"user_1","name":"Rohit Anand","profileImage":""},"modifiedOn":"2025-04-25T10:49:30.177416"},{"id":"15","amount":474.76,"description":"Electricity bill split","createdOn":"2025-04-03T03:49:30.177428","createdBy":{"id":"user_1","name":"Rohit Anand","profileImage":""},"modifiedOn":"2025-04-04T03:49:30.177428"}]''';
      List<dynamic> tempArr = jsonDecode(dataStr);
      List<LendenRoomModel> arr =
          tempArr.map((ele) => LendenRoomModel.fromMap(ele)).toList();

      return arr;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> fetchRoomNameByID(String email, String id) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});

      return "RA-LD";
    } catch (e) {
      rethrow;
    }
  }
}
