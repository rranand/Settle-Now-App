import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/data/data_provider/personal_expense/monthly_expense/personal_expense_data_provider.dart';
import 'package:settlenow_v2/model/personal_expense_transaction_model.dart';
import 'package:settlenow_v2/util/custom/pair.dart';

class PersonalExpenseMonthlyExpenseRepository {
  final PersonalExpenseMonthlyExpenseDataProvider personalExpenseDataProvider;

  PersonalExpenseMonthlyExpenseRepository(this.personalExpenseDataProvider);

  Future<Pair<List<double>, List<PersonalExpenseTransactionModel>>> fetchData(
    String email,
  ) async {
    try {
      List<PersonalExpenseTransactionModel> data =
          await personalExpenseDataProvider.fetchData(email);

      PersonalMonthlyExpenseTD processedData = PersonalMonthlyExpenseTD(
        List.filled(CategoryParser.getCategoryList().length, 0),
        data,
      );
      processedData.second = data;

      for (int i = 0; i < processedData.second.length; i++) {
        PersonalExpenseTransactionModel eachExpense = processedData.second[i];
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
