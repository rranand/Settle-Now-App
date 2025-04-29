import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/data/data_provider/personal_expense/monthly_expense/personal_expense_data_provider.dart';

class PersonalMonthlyExpenseRepository {
  final PersonalMonthlyExpenseDataProvider personalMonthlyExpenseDataProvider;

  PersonalMonthlyExpenseRepository(this.personalMonthlyExpenseDataProvider);

  Future<PersonalMonthlyExpensePairTD> fetchData(String email) async {
    try {
      List<PersonalExpenseTransactionModel> data =
          await personalMonthlyExpenseDataProvider.fetchData(email);

      PersonalMonthlyExpensePairTD processedData = PersonalMonthlyExpensePairTD(
        List.filled(CategoryParser.getCategoryList().length, 0),
        data,
      );

      for (int i = 0; i < data.length; i++) {
        PersonalExpenseTransactionModel eachExpense = data[i];
        processedData.first[CategoryParser.indexOfCategory(
              eachExpense.category,
            )] +=
            eachExpense.amount;
      }

      return processedData;
    } catch (e) {
      rethrow;
    }
  }
}
