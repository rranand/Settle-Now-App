import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'settle_state.dart';

class SettleCubit extends Cubit<SettleState> {
  final QuicksplitBloc _bloc;
  final QuicksplitRepository _repo;
  SettleCubit(this._bloc, this._repo) : super(SettleState());

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
      await _repo.settleExpense(transactionID);
      oldProcessingIDs.remove(transactionID);
      _bloc.add(
        QuicksplitSettleRequest(transactionID: transactionID, uid: uid),
      );
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
      await _repo.optout(transactionID);
      oldProcessingIDs.remove(transactionID);
      _bloc.add(QuicksplitDeleteTransaction(transactionID: transactionID));
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
      await _repo.delete(transactionID);
      oldProcessingIDs.remove(transactionID);
      _bloc.add(QuicksplitDeleteTransaction(transactionID: transactionID));
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
