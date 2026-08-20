part of 'room_data_provider.dart';

extension RoomTransactionDataProvider on RoomDataProvider {
  Future<Pair<List<RoomTransactionModel>, bool>> fetchData(
    String id,
    DateTime cursor,
  ) async {
    try {
      final response = await createAPICall(
        'room/$id/transaction?${addCursorInURL(cursor)}',
        "get",
        {},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        bool hasMore = data['has_more'];
        final allTrans = data['data'];
        List<RoomTransactionModel> arr = [];
        if (allTrans != null) {
          for (int i = 0; i < allTrans.length; i++) {
            arr.add(RoomTransactionModel.fromMap(allTrans[i]));
          }
        }

        return Pair(arr, hasMore);
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
    SplitType splitType,
  ) async {
    try {
      final response = await createAPICall(
        'room/$id/transaction',
        "post",
        data.toCreateExpenseJson()
          ..addAll({"split_type": splitType.labelInSmallCase}),
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
        {"transactions": data.map((e) => e.toBulkExpenseJson()).toList()},
      );

      final respData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final transactionIDs = respData['data'];
        List<RoomTransactionModel> newExpense = [...data];
        for (int i = 0; i < data.length; i++) {
          newExpense[i].id = transactionIDs[i];
          newExpense[i].activityCount = 1;
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

  Future<void> deleteExpense(String id, String expenseID) async {
    final response = await createAPICall('room/$id/transaction', "delete", {
      "id": expenseID,
    });

    final respData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return;
    } else {
      throw respData['message'];
    }
  }

  Future<String> addToPersonalExpense(String id, String expenseID) async {
    try {
      final response = await createAPICall(
        'room/$id/transaction/personalExpense',
        "post",
        {"id": expenseID},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['data']['id'];
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
