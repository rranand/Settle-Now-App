import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'bank_transaction_state.dart';

class BankTransactionCubit extends Cubit<BankTransactionState> {
  final _batchSize = 1000;

  BankTransactionCubit() : super(BankTransactionInitial());

  void fetchData({bool forceRefresh = false}) async {
    if (state is BankTransactionLoading) {
      return;
    }

    BankTransactionSuccess? oldState;
    int oldMessagesProcessedCount = 0;
    List<BankTransactionModel> oldData = [];

    if (!forceRefresh && state is BankTransactionSuccess) {
      oldState = state as BankTransactionSuccess;
      if (!oldState.hasMoreData) {
        return;
      }

      oldMessagesProcessedCount = oldState.messagesProcessedCount;
      oldData = [...oldState.data];
      emit(oldState.copyWith(isLoadingMore: true));
    }

    if (oldState == null) {
      emit(BankTransactionLoading());
    }

    var permission = await Permission.sms.status;

    if (!permission.isGranted) {
      final permissionStatus = await Permission.sms.request();

      if (!permissionStatus.isGranted) {
        emit(BankTransactionFailure(error: "SMS permission denied"));
        return;
      }
    }

    final SmsQuery query = SmsQuery();
    final futureData = await Future.wait([
      query.querySms(
        start: forceRefresh ? 0 : oldMessagesProcessedCount,
        count: _batchSize,
        kinds: [SmsQueryKind.inbox],
      ),
      _getAllConsumedTransactions(),
    ]);

    final messages = futureData[0] as List<SmsMessage>;
    final consumedTransactions =
        futureData[1] as LinkedHashMap<String, BankTransactionConsumedModel>;

    final allTransactions = filterSMS(messages, consumedTransactions);

    emit(
      BankTransactionSuccess(
        data: [...oldData, ...allTransactions],
        isLoadingMore: false,
        hasMoreData: allTransactions.isNotEmpty,
        messagesProcessedCount: oldMessagesProcessedCount + _batchSize,
      ),
    );
  }

  Future<LinkedHashMap<String, BankTransactionConsumedModel>>
  _getAllConsumedTransactions() async {
    final db = await DatabaseHandler.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bank_transaction_consumed',
    );

    return LinkedHashMap.fromIterable(
      maps,
      key: (item) => item['id'] as String,
      value: (item) => BankTransactionConsumedModel.fromMap(item),
    );
  }
}
