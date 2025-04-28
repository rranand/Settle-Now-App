// import 'package:settlenow_v2/data/data_provider/personal_expense_data_provider.dart';
// import 'package:settlenow_v2/model/personal_expense_info_model.dart';

// class PersonalExpenseRepository {
//   final PersonalExpenseDataProvider personalExpenseDataProvider;

//   PersonalExpenseRepository(this.personalExpenseDataProvider);

//   Future<Map<int, List<PersonalExpenseInfoModel>>> fetchData(
//     String email,
//   ) async {
//     try {
//       List<PersonalExpenseInfoModel> data = await personalExpenseDataProvider
//           .fetchData(email);

//       Map<int, List<PersonalExpenseInfoModel>> yearWiseExpense = {};

//       for (int i = 0; i < data.length; i++) {
//         int curYear = int.parse(data[i].year);
//         if (yearWiseExpense.containsKey(curYear)) {
//           yearWiseExpense[curYear]!.add(data[i]);
//         } else {
//           yearWiseExpense[curYear] = [data[i]];
//         }
//       }
//       return yearWiseExpense;
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
