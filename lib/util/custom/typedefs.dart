import 'package:flutter/material.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

typedef UserWithEditControlTD = Map<BaseUserModel, TextEditingController>;

typedef PersonalMonthlyExpensePairTD =
    Pair<List<Pair<double, int>>, List<PersonalExpenseTransactionModel>>;

typedef UserPreferenceBundle =
    ({
      UserModel user,
      PreferenceModel preference,
      List<FriendUserModel> friends,
    });
