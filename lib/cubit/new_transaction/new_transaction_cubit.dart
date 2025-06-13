import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/room/lenden_room_bloc.dart';
import 'package:settlenow_v2/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow_v2/bloc/quicksplit/quicksplit_bloc.dart';
import 'package:settlenow_v2/bloc/room/each_room/room_bloc.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/data/repository/lenden/room/lenden_room_repository.dart';
import 'package:settlenow_v2/data/repository/personal_expense/monthly_expense/personal_expense_repository.dart';
import 'package:settlenow_v2/data/repository/quicksplit_repository.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/util/card/add_transaction.dart';

part 'new_transaction_state.dart';

class NewTransactionCubit extends Cubit<NewTransactionState> {
  final QuicksplitRepository repo;
  final PersonalMonthlyExpenseRepository repoPS;
  final LendenRoomRepository repoLD;
  final RoomRepository repoRD;

  NewTransactionCubit(this.repo, this.repoPS, this.repoLD, this.repoRD)
    : super(NewTransactionInitial());

  void createNewExpense(
    BuildContext context,
    NewTransactionModel data,
    TransactionType transactionType,
  ) async {
    emit(NewTransactionLoading());

    try {
      switch (transactionType) {
        case TransactionType.quicksplit:
          {
            final bloc = context.read<QuicksplitBloc>();
            final TransactionModel newData = await repo.create(data);
            bloc.add(QuicksplitAddNewTransaction(newData));
            return emit(NewTransactionSuccess(newData));
          }
        case TransactionType.personal:
          {
            final bloc = context.read<PersonalMonthlyExpenseBloc>();
            final PersonalExpenseTransactionModel newData = await repoPS.add(
              data,
            );
            bloc.add(PersonalMonthlyExpenseAdd(newData));
            return emit(
              NewTransactionSuccess(TransactionModel.fromNewTransaction(data)),
            );
          }
        case TransactionType.lenden:
          {
            final bloc = context.read<LendenRoomBloc>();
            final LendenRoomModel newData = await repoLD.create(data);
            bloc.add(LendenAddNewTransaction(newData));
            return emit(
              NewTransactionSuccess(TransactionModel.fromNewTransaction(data)),
            );
          }
        case TransactionType.room:
          {
            final bloc = context.read<RoomBloc>();
            final TransactionModel newData = await repoRD.createExpense(data);
            bloc.add(RoomAddNewTransaction(newData));
            return emit(NewTransactionSuccess(newData));
          }
      }
    } catch (e) {
      return emit(NewTransactionFailure(e.toString()));
    }
  }

  void updateExpense(
    BuildContext context,
    NewTransactionModel data,
    TransactionType transactionType,
  ) async {
    emit(NewTransactionLoading());
    final loggedInUser =
        (context.read<AuthBloc>().state as AuthLoginSuccess).userData;

    try {
      switch (transactionType) {
        case TransactionType.quicksplit:
          {
            final bloc = context.read<QuicksplitBloc>();
            final TransactionModel updatedData = await repo.update(
              data,
              loggedInUser.authToken,
            );
            bloc.add(QuicksplitUpdateTransaction(updatedData));
            return emit(NewTransactionSuccess(updatedData));
          }
        case TransactionType.personal:
          {
            final bloc = context.read<PersonalMonthlyExpenseBloc>();
            final PersonalExpenseTransactionModel updatedData = await repoPS
                .update(data);
            bloc.add(PersonalMonthlyExpenseUpdate(updatedData));
            return emit(
              NewTransactionSuccess(TransactionModel.fromNewTransaction(data)),
            );
          }
        case TransactionType.lenden:
          {
            final bloc = context.read<LendenRoomBloc>();
            final LendenRoomModel updatedData = await repoLD.update(data);
            bloc.add(LendenUpdateTransaction(updatedData));
            return emit(
              NewTransactionSuccess(TransactionModel.fromNewTransaction(data)),
            );
          }
        case TransactionType.room:
          {
            final bloc = context.read<RoomBloc>();
            final TransactionModel newData = await repoRD.updateExpense(data);
            bloc.add(RoomUpdateTransaction(newData));
            return emit(NewTransactionSuccess(newData));
          }
      }
    } catch (e) {
      return emit(NewTransactionFailure(e.toString()));
    }
  }

  void deleteExpense(
    BuildContext context,
    String expenseID,
    TransactionType transactionType,
  ) async {
    emit(NewTransactionLoading());
    dynamic bloc;

    final loggedInUser =
        (context.read<AuthBloc>().state as AuthLoginSuccess).userData;

    try {
      switch (transactionType) {
        case TransactionType.quicksplit:
          {
            bloc = context.read<QuicksplitBloc>();
            final bool isDeleted = await repo.delete(
              expenseID,
              loggedInUser.authToken,
            );
            if (isDeleted) {
              bloc.add(QuicksplitDeleteTransaction(expenseID));
              return emit(NewTransactionSuccess(TransactionModel.empty()));
            } else {
              return emit(NewTransactionFailure("Something went wrong!"));
            }
          }
        case TransactionType.personal:
          {
            bloc = context.read<PersonalMonthlyExpenseBloc>();
            bloc.add(PersonalMonthlyExpenseDelete(true, expenseID));
            final bool isDeleted = await repoPS.delete(expenseID);

            if (isDeleted) {
              bloc.add(PersonalMonthlyExpenseDelete(false, expenseID));
              return emit(NewTransactionSuccess(TransactionModel.empty()));
            } else {
              bloc.add(PersonalMonthlyExpenseDelete(false, expenseID));
              return emit(NewTransactionFailure("Something went wrong!"));
            }
          }
        case TransactionType.lenden:
          {
            bloc = context.read<LendenRoomBloc>();
            bloc.add(LendenDeleteTransaction(expenseID));
            final bool isDeleted = await repoLD.delete(expenseID);

            if (isDeleted) {
              bloc.add(LendenDeleteTransaction(expenseID));
              return emit(NewTransactionSuccess(TransactionModel.empty()));
            } else {
              return emit(NewTransactionFailure("Something went wrong!"));
            }
          }
        case TransactionType.room:
          {
            final bloc = context.read<RoomBloc>();
            final bool isDeleted = await repoRD.deleteExpense(expenseID);

            if (isDeleted) {
              bloc.add(RoomDeleteTransaction(expenseID));
              return emit(NewTransactionSuccess(TransactionModel.empty()));
            } else {
              return emit(NewTransactionFailure("Something went wrong!"));
            }
          }
      }
    } catch (e) {
      if (transactionType == TransactionType.personal) {
        bloc.add(PersonalMonthlyExpenseDelete(false, expenseID));
      }
      return emit(NewTransactionFailure(e.toString()));
    }
  }
}
