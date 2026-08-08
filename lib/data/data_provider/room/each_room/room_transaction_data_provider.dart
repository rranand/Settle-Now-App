part of 'room_data_provider.dart';

extension RoomTransactionDataProvider on RoomDataProvider {
  Future<List<RoomTransactionModel>> fetchData(String id) async {
    try {
      final response = await createAPICall('room/$id/transaction', "get", {});

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final allTrans = data['data'];
        List<RoomTransactionModel> arr = [];
        if (allTrans != null) {
          for (int i = 0; i < allTrans.length; i++) {
            arr.add(RoomTransactionModel.fromMap(allTrans[i]));
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

  Future<RoomTransactionModel> createExpense(
    String id,
    RoomTransactionModel data,
  ) async {
    try {
      final response = await createAPICall(
        'room/$id/transaction',
        "post",
        data.toCreateExpenseJson(),
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data.copyWith(id: respData['data']['id']);
      } else {
        throw respData['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoomTransactionModel>> createBulkExpense(
    String id,
    List<RoomTransactionModel> data,
  ) async {
    try {
      final response = await createAPICall(
        'room/$id/bulk-transaction',
        "post",
        {"data": data.map((e) => e.toCreateExpenseJson()).toList()},
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final transactionMapping = respData['data'];
        List<RoomTransactionModel> newExpense = [...data];
        for (int i = 0; i < data.length; i++) {
          newExpense[i].id = transactionMapping[i.toString()];
        }
        return newExpense;
      } else {
        throw respData['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateExpense(String id, RoomTransactionModel data) async {
    try {
      final response = await createAPICall(
        'room/$id/transaction',
        "patch",
        data.toUpdateExpenseJson(),
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return;
      } else {
        throw respData['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteExpense(
    String id,
    String expenseID,
    TransactionType expenseType,
  ) async {
    final response = await createAPICall('room/$id/transaction', "delete", {
      "id": expenseID,
      "split_type": expenseType.label,
    });

    final respData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw respData['message'];
    }
  }

  Future<bool> addToPersonalExpense(String id, String expenseID) async {
    try {
      final response = await createAPICall(
        'room/$id/transaction/personalExpense',
        "post",
        {"id": expenseID},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
