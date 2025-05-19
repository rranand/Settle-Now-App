import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/quicksplit/quicksplit_bloc.dart';
import 'package:settlenow_v2/data/repository/quicksplit_repository.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/model/transaction_model.dart';

part 'new_transaction_state.dart';

class NewTransactionCubit extends Cubit<NewTransactionState> {
  final QuicksplitRepository repo;
  NewTransactionCubit(this.repo) : super(NewTransactionInitial());

  void createNewExpense(BuildContext context, NewTransactionModel data) async {
    emit(NewTransactionLoading());

    final bloc = context.read<QuicksplitBloc>();
    try {
      final TransactionModel newData = await repo.create(data);

      bloc.add(QuicksplitAddNewTransaction(newData));
      emit(NewTransactionSuccess(newData));
    } catch (e) {
      emit(NewTransactionFailure(e.toString()));
    }
  }

  void updateExpense(BuildContext context, NewTransactionModel data) async {
    emit(NewTransactionLoading());

    final bloc = context.read<QuicksplitBloc>();
    try {
      final TransactionModel updatedData = await repo.update(data);

      bloc.add(QuicksplitUpdateTransaction(updatedData));
      emit(NewTransactionSuccess(updatedData));
    } catch (e) {
      emit(NewTransactionFailure(e.toString()));
    }
  }
}
