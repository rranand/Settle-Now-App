import 'package:flutter/material.dart';
import 'package:settlenow_v2/model/personal_expense_transaction_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/custom/pair.dart';

typedef PersonalMonthlyExpenseTD =
    Pair<List<double>, List<PersonalExpenseTransactionModel>>;

typedef UserWithEditControlTD = Map<UserModel, TextEditingController>;
