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
import 'package:settlenow_v2/util/enum/transaction_type.dart';

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
    final authLoginState = context.read<AuthBloc>().state;
    UserModel loggedInUser = UserModel.empty();
    if (authLoginState is! AuthLoginSuccess) {
      return;
    } else {
      loggedInUser = authLoginState.userData;
    }
    emit(NewTransactionLoading());

    try {
      switch (transactionType) {
        case TransactionType.quicksplit:
          {
            final bloc = context.read<QuicksplitBloc>();
            final TransactionModel newData = await repo.create(
              data,
              loggedInUser.authToken,
            );
            bloc.add(QuicksplitAddNewTransaction(newData));
            return emit(NewTransactionSuccess(newData));
          }
        case TransactionType.personal:
          {
            final bloc = context.read<PersonalMonthlyExpenseBloc>();
            final PersonalExpenseTransactionModel newData = await repoPS.add(
              loggedInUser.authToken,
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
            final blocState = bloc.state;
            if (blocState is! LendenRoomFetchSuccess) {
              return;
            }
            final roomID = blocState.id;
            final LendenTransactionModel newData = await repoLD.create(
              roomID,
              loggedInUser.authToken,
              data,
            );
            bloc.add(LendenAddNewTransaction(newData));
            return emit(
              NewTransactionSuccess(TransactionModel.fromNewTransaction(data)),
            );
          }
        case TransactionType.room:
          {
            final bloc = context.read<RoomBloc>();
            final blocState = bloc.state;
            if (blocState is! RoomFetchSuccess) {
              return;
            }
            final roomID = blocState.id;
            final TransactionModel newData = await repoRD.createExpense(
              roomID,
              data,
              loggedInUser.authToken,
            );
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
    TransactionType transactionType, {
    String expenseType = "Personal",
  }) async {
    final authLoginState = context.read<AuthBloc>().state;
    UserModel loggedInUser = UserModel.empty();
    if (authLoginState is! AuthLoginSuccess) {
      return;
    } else {
      loggedInUser = authLoginState.userData;
    }
    emit(NewTransactionLoading());

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
                .update(loggedInUser.authToken, data);
            bloc.add(PersonalMonthlyExpenseUpdate(updatedData));
            return emit(
              NewTransactionSuccess(TransactionModel.fromNewTransaction(data)),
            );
          }
        case TransactionType.lenden:
          {
            final bloc = context.read<LendenRoomBloc>();
            final blocState = bloc.state;
            if (blocState is! LendenRoomFetchSuccess) {
              return;
            }
            final roomID = blocState.id;
            final LendenTransactionModel updatedData = await repoLD.update(
              roomID,
              loggedInUser.authToken,
              data,
            );
            bloc.add(LendenUpdateTransaction(updatedData));
            return emit(
              NewTransactionSuccess(TransactionModel.fromNewTransaction(data)),
            );
          }
        case TransactionType.room:
          {
            final bloc = context.read<RoomBloc>();
            final blocState = bloc.state;
            if (blocState is! RoomFetchSuccess) {
              return;
            }
            final roomID = blocState.id;
            final TransactionModel newData = await repoRD.updateExpense(
              roomID,
              data,
              expenseType,
              loggedInUser.authToken,
            );
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
    TransactionType transactionType, {
    String expenseType = "Personal",
  }) async {
    final authLoginState = context.read<AuthBloc>().state;
    UserModel loggedInUser = UserModel.empty();
    if (authLoginState is! AuthLoginSuccess) {
      return;
    } else {
      loggedInUser = authLoginState.userData;
    }
    emit(NewTransactionLoading());
    dynamic bloc;

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
            final bool isDeleted = await repoPS.delete(
              loggedInUser.authToken,
              expenseID,
              expenseType,
            );

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
            final blocState = bloc.state;
            if (blocState is! LendenRoomFetchSuccess) {
              return;
            }
            final roomID = blocState.id;
            final bool isDeleted = await repoLD.delete(
              roomID,
              loggedInUser.authToken,
              expenseID,
            );

            if (isDeleted) {
              bloc.add(LendenDeleteTransaction(expenseID));
              return emit(NewTransactionSuccess(TransactionModel.empty()));
            } else {
              return emit(NewTransactionFailure("Something went wrong!"));
            }
          }
        case TransactionType.room:
          {
            bloc = context.read<RoomBloc>();
            final blocState = bloc.state;
            if (blocState is! RoomFetchSuccess) {
              return;
            }
            final roomID = blocState.id;
            final bool isDeleted = await repoRD.deleteExpense(
              roomID,
              expenseID,
              expenseType,
              loggedInUser.authToken,
            );

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

  void reset() {
    return emit(NewTransactionInitial());
  }
}
