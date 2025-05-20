import 'dart:convert';

import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';

class PersonalMonthlyExpenseDataProvider {
  Future<List<PersonalExpenseTransactionModel>> fetchData(
    String email,
    String year,
    String month,
  ) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      String dataStr = '''
                [{"id":"9501cae0-e5d3-4042-beff-14538fac76e5","amount":208.2,"description":"New furniture","category":"Household","createdOn":"2024-08-06T02:12:22","modifiedOn":"2024-08-08T02:12:22","roomData":{"id":"8caaf5ae-f173-4421-aa90-7e96dd51ac43","roomName":"Office Lunch","transactionID":"bdf9a081-e736-4081-8390-7a36ec2deb64","createdOn":"2025-04-29T18:18:50.376742","modifiedOn":"2025-04-29T18:18:50.376752"}},{"id":"23654bf1-8e38-4843-8937-030eb6fd0cf3","amount":3129.01,"description":"Pharmacy purchase","category":"HealthCare","createdOn":"2024-07-15T05:50:36","modifiedOn":"2024-07-17T05:50:36"},{"id":"688b4fb1-02d3-4b08-9de7-a048dba9019e","amount":4378.05,"description":"Online course","category":"Education","createdOn":"2024-05-05T20:16:26","modifiedOn":"2024-05-09T20:16:26","roomData":{"id":"bc567883-f2a3-461b-9c0c-ad9039910b46","roomName":"Gym Group","transactionID":"85e04bb9-8b8b-4a06-9703-c28b8493fb32","createdOn":"2025-04-29T18:18:50.377923","modifiedOn":"2025-04-29T18:18:50.377931"}},{"id":"1765d542-be8b-4499-baa7-f0217091d443","amount":3763.29,"description":"Flight tickets","category":"Travel","createdOn":"2024-03-09T21:11:42","modifiedOn":"2024-03-09T21:11:42"},{"id":"8abd79f6-2958-4ec2-8b8a-339ddb069197","amount":2373.01,"description":"City tour","category":"Travel","createdOn":"2024-12-01T03:31:00","modifiedOn":"2024-12-06T03:31:00"},{"id":"d287f452-c3c9-49c1-bc4a-233e7bd05305","amount":2066.19,"description":"Fuel refill","category":"Travel","createdOn":"2024-01-02T02:57:11","modifiedOn":"2024-01-05T02:57:11"},{"id":"17efd5ae-03cd-4d5a-adf8-a1015df72e8b","amount":2930.19,"description":"Clothes Miscellaneous","category":"Miscellaneous","createdOn":"2025-03-13T08:02:35","modifiedOn":"2025-03-17T08:02:35"},{"id":"50be5e3b-1818-4f48-9be1-13b5360b423b","amount":1006.29,"description":"Dinner with friends","category":"Food","createdOn":"2025-02-15T11:25:37","modifiedOn":"2025-02-19T11:25:37"},{"id":"9dc6fd94-5c0f-495b-b45e-84a975ce7263","amount":302.67,"description":"Online course","category":"Education","createdOn":"2024-07-03T02:35:58","modifiedOn":"2024-07-07T02:35:58","roomData":{"id":"cafe378a-0e93-42e7-bc84-96d4931d0cc8","roomName":"Flatmates","transactionID":"6d61f795-87b7-4e99-bdd7-a0fdb06c0c9c","createdOn":"2025-04-29T18:18:50.378250","modifiedOn":"2025-04-29T18:18:50.378254"}},{"id":"cc023bcd-ad23-49b1-bf0a-c169bb77363f","amount":1738.13,"description":"Stationery","category":"Miscellaneous","createdOn":"2025-03-22T11:10:00","modifiedOn":"2025-03-25T11:10:00"},{"id":"c698bbf1-a028-4b2f-93e6-8afb0ad99e9f","amount":15.25,"description":"Rent payment","category":"Household","createdOn":"2024-04-18T11:15:50","modifiedOn":"2024-04-23T11:15:50","roomData":{"id":"6ab40d97-950b-4a17-a8a3-006b4d0d8682","roomName":"Gym Group","transactionID":"a139aa6a-58fb-4617-97f2-3305f19d5183","createdOn":"2025-04-29T18:18:50.378365","modifiedOn":"2025-04-29T18:18:50.378367"}},{"id":"718eb81e-e6be-43a7-95ef-a788b1cb1eee","amount":3066.65,"description":"Clothes Miscellaneous","category":"Miscellaneous","createdOn":"2024-07-22T09:19:00","modifiedOn":"2024-07-27T09:19:00"},{"id":"a4fb5075-62ce-4c1a-ac75-f4ce0e975ec8","amount":2124.73,"description":"Cab ride","category":"Travel","createdOn":"2024-03-31T16:55:32","modifiedOn":"2024-04-03T16:55:32","roomData":{"id":"f556f778-d42b-42e4-843c-21729973b466","roomName":"Trip to Goa","transactionID":"e360fb1b-9f7d-49cd-a4ab-493e0ec7bf98","createdOn":"2025-04-29T18:18:50.378418","modifiedOn":"2025-04-29T18:18:50.378420"}},{"id":"5096c2ea-9c29-4e0f-8e77-1a80035989e7","amount":3168.47,"description":"Movie night","category":"Entertainment","createdOn":"2025-01-27T08:25:12","modifiedOn":"2025-01-31T08:25:12"},{"id":"2f44913a-445b-4229-a2fd-f922958a30da","amount":2379.96,"description":"Repair service","category":"Household","createdOn":"2024-09-13T05:52:08","modifiedOn":"2024-09-15T05:52:08"},{"id":"5f42a9e7-3a1c-4451-a799-10fd4180fff4","amount":1040.08,"description":"Repair service","category":"Household","createdOn":"2024-07-18T23:04:31","modifiedOn":"2024-07-22T23:04:31"},{"id":"24d3e213-8df3-4a9c-8d16-a8e4eb5d3c7b","amount":707.49,"description":"Fuel refill","category":"Travel","createdOn":"2025-02-07T16:39:58","modifiedOn":"2025-02-11T16:39:58"},{"id":"35f29763-6ff9-4ab6-8294-1c224498dee2","amount":4481.88,"description":"Donation","category":"Miscellaneous","createdOn":"2024-02-13T06:28:33","modifiedOn":"2024-02-15T06:28:33"},{"id":"3e6b99da-f71e-4ec4-a087-6dd51b71c2dd","amount":2798.09,"description":"Hotel booking","category":"Travel","createdOn":"2024-01-18T00:27:00","modifiedOn":"2024-01-22T00:27:00"},{"id":"64fff760-4f43-4464-b0bd-861d12fc4be9","amount":2595.82,"description":"Fuel refill","category":"Travel","createdOn":"2025-03-07T02:25:51","modifiedOn":"2025-03-10T02:25:51","roomData":{"id":"199f8dcb-8db3-4ea1-88db-7610d62f88e9","roomName":"Flatmates","transactionID":"a078ae49-50e0-4e1b-bc98-f9a87384fa54","createdOn":"2025-04-29T18:18:50.378739","modifiedOn":"2025-04-29T18:18:50.378743"}},{"id":"f5df595a-2778-425a-9bb9-c68a17a5e2f0","amount":2734.31,"description":"City tour","category":"Travel","createdOn":"2024-10-13T09:59:45","modifiedOn":"2024-10-15T09:59:45","roomData":{"id":"a15a8956-0adf-4f53-a0c8-e9a946d0362b","roomName":"Trip to Goa","transactionID":"868dc0af-2862-429c-b4bd-96f41cbccbe2","createdOn":"2025-04-29T18:18:50.378805","modifiedOn":"2025-04-29T18:18:50.378807"}},{"id":"5d468a70-302f-463a-8f83-0af16ee1d1bd","amount":1879.7,"description":"Grocery Miscellaneous","category":"Food","createdOn":"2024-03-29T10:25:08","modifiedOn":"2024-04-03T10:25:08"},{"id":"4c47f49e-52e9-4a98-bd0a-ea70e98d590b","amount":50.82,"description":"Pharmacy purchase","category":"HealthCare","createdOn":"2025-02-17T02:26:58","modifiedOn":"2025-02-17T02:26:58"},{"id":"119b1709-38a7-48f9-acbd-6aacf19e714f","amount":4037.41,"description":"Online order","category":"Miscellaneous","createdOn":"2024-11-22T22:17:10","modifiedOn":"2024-11-23T22:17:10"},{"id":"75a49ec8-4fcd-4e9e-9395-8aed294ab239","amount":4551.96,"description":"New furniture","category":"Household","createdOn":"2024-08-01T07:43:44","modifiedOn":"2024-08-06T07:43:44"}]
      ''';
      List<dynamic> tempArr = jsonDecode(dataStr);
      List<PersonalExpenseTransactionModel> arr =
          tempArr
              .map((ele) => PersonalExpenseTransactionModel.fromMap(ele))
              .toList();
      return arr;
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalExpenseTransactionModel> add(NewTransactionModel data) async {
    try {
      PersonalExpenseTransactionModel newExpense =
          PersonalExpenseTransactionModel.fromNewTransaction(data);
      newExpense.id = "${newExpense.description}##${newExpense.createdOn}";
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalExpenseTransactionModel> update(
    NewTransactionModel data,
  ) async {
    try {
      PersonalExpenseTransactionModel updatedExpense =
          PersonalExpenseTransactionModel.fromNewTransaction(data);
      updatedExpense.modifiedOn = DateTime.now();
      return updatedExpense;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(String expenseID) async {
    try {
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
