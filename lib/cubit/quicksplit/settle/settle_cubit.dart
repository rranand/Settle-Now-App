import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'settle_state.dart';

class SettleCubit extends Cubit<SettleState> {
  final QuicksplitBloc bloc;
  final QuicksplitRepository repo;
  SettleCubit(this.bloc, this.repo) : super(SettleState());

  void settleExpense(
    String transactionID,
    String uid,

    BuildContext context,
  ) async {
    if (state.settlingExpense.contains(transactionID)) {
      return;
    }
    Set<String> oldProcessingIDs = Set.from(state.settlingExpense);
    oldProcessingIDs.add(transactionID);

    emit(state.copyWith(settlingExpense: oldProcessingIDs));

    try {
      await repo.settleExpense(transactionID);
      oldProcessingIDs.remove(transactionID);
      bloc.add(QuicksplitSettleRequest(transactionID: transactionID, uid: uid));
      return emit(state.copyWith(settlingExpense: oldProcessingIDs));
    } catch (e) {
      if (context.mounted) {
        showNormalSnackBar(context, e.toString());
      }
      oldProcessingIDs.remove(transactionID);
      return emit(state.copyWith(settlingExpense: oldProcessingIDs));
    }
  }

  void optout(String transactionID, String uid, BuildContext context) async {
    if (state.settlingExpense.contains(transactionID)) {
      return;
    }
    Set<String> oldProcessingIDs = Set.from(state.settlingExpense);
    oldProcessingIDs.add(transactionID);

    emit(state.copyWith(settlingExpense: oldProcessingIDs));

    try {
      await repo.optout(transactionID);
      oldProcessingIDs.remove(transactionID);
      bloc.add(QuicksplitDeleteTransaction(transactionID: transactionID));
      return emit(state.copyWith(settlingExpense: oldProcessingIDs));
    } catch (e) {
      if (context.mounted) {
        showNormalSnackBar(context, e.toString());
      }
      oldProcessingIDs.remove(transactionID);
      return emit(state.copyWith(settlingExpense: oldProcessingIDs));
    }
  }

  void delete(String transactionID, String uid, BuildContext context) async {
    if (state.settlingExpense.contains(transactionID)) {
      return;
    }
    Set<String> oldProcessingIDs = Set.from(state.settlingExpense);
    oldProcessingIDs.add(transactionID);

    emit(state.copyWith(settlingExpense: oldProcessingIDs));

    try {
      await repo.delete(transactionID);
      oldProcessingIDs.remove(transactionID);
      bloc.add(QuicksplitDeleteTransaction(transactionID: transactionID));
      return emit(state.copyWith(settlingExpense: oldProcessingIDs));
    } catch (e) {
      if (context.mounted) {
        showNormalSnackBar(context, e.toString());
      }
      oldProcessingIDs.remove(transactionID);
      return emit(state.copyWith(settlingExpense: oldProcessingIDs));
    }
  }
}
