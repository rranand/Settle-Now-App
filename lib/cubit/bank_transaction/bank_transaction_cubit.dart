import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'bank_transaction_state.dart';

class BankTransactionCubit extends Cubit<BankTransactionState> {
  BankTransactionCubit() : super(BankTransactionInitial());

  void fetchData({bool refresh = false}) async {
    if (state is BankTransactionLoading &&
        (state is BankTransactionSuccess && !refresh)) {
      return;
    }

    emit(BankTransactionLoading());

    var permission = await Permission.sms.status;

    if (!permission.isGranted) {
      final permissionStatus = await Permission.sms.request();

      if (!permissionStatus.isGranted) {
        emit(BankTransactionFailure(error: "SMS permission denied"));
        return;
      }
    }

    final SmsQuery query = SmsQuery();

    final messages = await query.querySms(
      count: 10000000,
      kinds: [SmsQueryKind.inbox],
    );

    List<BankTransactionModel> allTransactions = await filterSMS(messages);

    emit(BankTransactionSuccess(data: allTransactions));
  }
}
