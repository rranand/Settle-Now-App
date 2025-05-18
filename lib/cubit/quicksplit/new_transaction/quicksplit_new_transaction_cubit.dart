import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/quicksplit/quicksplit_bloc.dart';
import 'package:settlenow_v2/data/repository/quicksplit_repository.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/model/transaction_model.dart';

part 'quicksplit_new_transaction_state.dart';

class QuicksplitNewTransactionCubit
    extends Cubit<QuicksplitNewTransactionState> {
  final QuicksplitRepository repo;
  QuicksplitNewTransactionCubit(this.repo)
    : super(QuicksplitNewTransactionInitial());

  void createNewExpense(BuildContext context, NewTransactionModel data) async {
    emit(QSNTransactionLoading());

    final quicksplitBloc = context.read<QuicksplitBloc>();
    try {
      final TransactionModel newData = await repo.create(data);

      quicksplitBloc.add(QuicksplitAddNewTransaction(newData));
      emit(QSNTransactionSuccess(newData));
    } catch (e) {
      emit(QSNTransactionFailure(e.toString()));
    }
  }
}
