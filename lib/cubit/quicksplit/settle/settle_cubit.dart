import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/quicksplit/quicksplit_bloc.dart';
import 'package:settlenow_v2/data/repository/quicksplit_repository.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';

part 'settle_state.dart';

class SettleCubit extends Cubit<SettleState> {
  final QuicksplitBloc bloc;
  final QuicksplitRepository repo;
  SettleCubit(this.bloc, this.repo) : super(SettleState());

  void settleExpense(
    String transactionID,
    String uid,
    String authToken,
    BuildContext context,
  ) async {
    if (state.settlingExpense.contains(transactionID)) {
      return;
    }
    Set<String> oldProcessingIDs = Set.from(state.settlingExpense);
    oldProcessingIDs.add(transactionID);

    emit(state.copyWith(settlingExpense: oldProcessingIDs));

    try {
      await repo.settleExpense(transactionID, authToken);
      oldProcessingIDs.remove(transactionID);
      bloc.add(QuicksplitSettleRequest(transactionID, uid));
      return emit(state.copyWith(settlingExpense: oldProcessingIDs));
    } catch (e) {
      if (context.mounted) {
        showNormalSnackBar(context, e.toString());
      }
      oldProcessingIDs.remove(transactionID);
      return emit(state.copyWith(settlingExpense: oldProcessingIDs));
    }
  }

  void optout(
    String transactionID,
    String uid,
    String authToken,
    BuildContext context,
  ) async {
    if (state.settlingExpense.contains(transactionID)) {
      return;
    }
    Set<String> oldProcessingIDs = Set.from(state.settlingExpense);
    oldProcessingIDs.add(transactionID);

    emit(state.copyWith(settlingExpense: oldProcessingIDs));

    try {
      await repo.optout(transactionID, authToken);
      oldProcessingIDs.remove(transactionID);
      bloc.add(QuicksplitDeleteTransaction(transactionID));
      return emit(state.copyWith(settlingExpense: oldProcessingIDs));
    } catch (e) {
      if (context.mounted) {
        showNormalSnackBar(context, e.toString());
      }
      oldProcessingIDs.remove(transactionID);
      return emit(state.copyWith(settlingExpense: oldProcessingIDs));
    }
  }

  void delete(
    String transactionID,
    String uid,
    String authToken,
    BuildContext context,
  ) async {
    if (state.settlingExpense.contains(transactionID)) {
      return;
    }
    Set<String> oldProcessingIDs = Set.from(state.settlingExpense);
    oldProcessingIDs.add(transactionID);

    emit(state.copyWith(settlingExpense: oldProcessingIDs));

    try {
      await repo.delete(transactionID, authToken);
      oldProcessingIDs.remove(transactionID);
      bloc.add(QuicksplitDeleteTransaction(transactionID));
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
