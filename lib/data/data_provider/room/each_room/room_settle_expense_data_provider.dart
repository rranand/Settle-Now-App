part of 'room_data_provider.dart';

extension RoomSettleExpenseDataProvider on RoomDataProvider {
  Future<List<RoomSettleModel>> fetchSettleData(String id) async {
    try {
      final response = await createAPICall('room/$id/settle', "get", {});

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final allTrans = data['data'];
        List<RoomSettleModel> arr = [];
        if (allTrans != null) {
          for (int i = 0; i < allTrans.length; i++) {
            arr.add(RoomSettleModel.fromMap(allTrans[i]));
          }
        }
        return arr;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomSettleModel> createNewSettleExpense(
    String id,
    RoomSettleModel data,
  ) async {
    try {
      final response = await createAPICall(
        'room/$id/settle',
        "post",
        data.toSettleTransactionJSON(),
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        data.id = respData['data']['id'];
        return data;
      } else {
        throw respData['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomSettleModel> updateSettleExpense(
    String id,
    RoomSettleModel data,
  ) async {
    final response = await createAPICall(
      'room/$id/settle',
      "patch",
      data.toUpdateTransactionJSON(),
    );

    final respData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      data.modifiedOn = DateTime.now();
      return data;
    } else {
      throw respData['message'];
    }
  }

  Future<bool> deleteSettleExpense(String id, String expenseID) async {
    final response = await createAPICall('room/$id/settle', "delete", {
      "id": expenseID,
    });

    final respData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw respData['message'];
    }
  }
}
