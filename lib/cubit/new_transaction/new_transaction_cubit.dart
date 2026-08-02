import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

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
    BaseTransactionModel baseTransData,
    TransactionType transactionType,
  ) async {
    final authLoginState = context.read<AuthBloc>().state;
    if (authLoginState is! AuthLoginSuccess) {
      return;
    }
    emit(NewTransactionLoading());

    try {
      switch (transactionType) {
        case TransactionType.quicksplit:
          {
            final bloc = context.read<QuicksplitBloc>();
            final data = baseTransData as QuicksplitTransactionModel;
            final newData = await repo.create(data);
            bloc.add(QuicksplitAddNewTransaction(newData));
            return emit(NewTransactionSuccess(data: newData));
          }
        case TransactionType.personal:
          {
            final bloc = context.read<PersonalMonthlyExpenseBloc>();
            final data = baseTransData as PersonalExpenseTransactionModel;
            final PersonalExpenseTransactionModel newData = await repoPS.add(
              data,
            );

            bloc.add(PersonalMonthlyExpenseAdd(newData));
            return emit(NewTransactionSuccess(data: newData));
          }
        case TransactionType.lenden:
          {
            final bloc = context.read<LendenRoomBloc>();
            final blocState = bloc.state;
            if (blocState is! LendenRoomFetchSuccess) {
              return;
            }
            final roomID = blocState.id;
            final data = baseTransData as LendenTransactionModel;

            final LendenTransactionModel newData = await repoLD.create(
              roomID,
              data,
            );
            bloc.add(LendenAddNewTransaction(data: newData));
            return emit(NewTransactionSuccess(data: newData));
          }
        case TransactionType.room:
          {
            final bloc = context.read<RoomBloc>();
            final blocState = bloc.state;
            if (blocState is! RoomFetchSuccess) {
              return;
            }
            final roomID = blocState.id;
            final data = baseTransData as RoomTransactionModel;
            final RoomTransactionModel newData = await repoRD.createExpense(
              roomID,
              data,
            );
            bloc.add(RoomAddNewTransaction([newData]));
            return emit(NewTransactionSuccess(data: newData));
          }
      }
    } catch (e) {
      return emit(NewTransactionFailure(error: e.toString()));
    }
  }

  void createBulkExpense(
    BuildContext context,
    List<RoomTransactionModel> data,
  ) async {
    final authLoginState = context.read<AuthBloc>().state;
    if (authLoginState is! AuthLoginSuccess) {
      return;
    }
    emit(NewTransactionLoading());

    try {
      final bloc = context.read<RoomBloc>();
      final blocState = bloc.state;
      if (blocState is! RoomFetchSuccess) {
        return;
      }
      final roomID = blocState.id;
      final List<RoomTransactionModel> newData = await repoRD.createBulkExpense(
        roomID,
        data,
      );
      bloc.add(RoomAddNewTransaction(newData));
      return emit(NewTransactionSuccess(data: newData.first));
    } catch (e) {
      return emit(NewTransactionFailure(error: e.toString()));
    }
  }

  void updateExpense(
    BuildContext context,
    BaseTransactionModel baseTransData,
    TransactionType transactionType, {
    String expenseType = "Personal",
  }) async {
    final authLoginState = context.read<AuthBloc>().state;
    if (authLoginState is! AuthLoginSuccess) {
      return;
    }

    emit(NewTransactionLoading());

    try {
      switch (transactionType) {
        case TransactionType.quicksplit:
          {
            final bloc = context.read<QuicksplitBloc>();
            final data = baseTransData as QuicksplitTransactionModel;
            await repo.update(data);
            bloc.add(QuicksplitUpdateTransaction(data));
            return emit(NewTransactionSuccess(data: data));
          }
        case TransactionType.personal:
          {
            final bloc = context.read<PersonalMonthlyExpenseBloc>();
            final data = baseTransData as PersonalExpenseTransactionModel;
            await repoPS.update(data);
            bloc.add(PersonalMonthlyExpenseUpdate(data));
            return emit(NewTransactionSuccess(data: data));
          }
        case TransactionType.lenden:
          {
            final bloc = context.read<LendenRoomBloc>();
            final blocState = bloc.state;
            if (blocState is! LendenRoomFetchSuccess) {
              return;
            }
            final roomID = blocState.id;
            final data = baseTransData as LendenTransactionModel;
            await repoLD.update(roomID, data);
            bloc.add(LendenUpdateTransaction(data: data));
            return emit(NewTransactionSuccess(data: data));
          }
        case TransactionType.room:
          {
            final bloc = context.read<RoomBloc>();
            final blocState = bloc.state;
            if (blocState is! RoomFetchSuccess) {
              return;
            }
            final roomID = blocState.id;
            final data = baseTransData as RoomTransactionModel;
            await repoRD.updateExpense(roomID, data);
            bloc.add(RoomUpdateTransaction(data));
            return emit(NewTransactionSuccess(data: data));
          }
      }
    } catch (e) {
      return emit(NewTransactionFailure(error: e.toString()));
    }
  }

  void deleteExpense(
    BuildContext context,
    String expenseID,
    TransactionType transactionType, {
    String expenseType = "Personal",
  }) async {
    final authLoginState = context.read<AuthBloc>().state;
    if (authLoginState is! AuthLoginSuccess) {
      return;
    }

    emit(NewTransactionLoading());
    dynamic bloc;

    try {
      switch (transactionType) {
        case TransactionType.quicksplit:
          {
            bloc = context.read<QuicksplitBloc>();
            final bool isDeleted = await repo.delete(expenseID);
            if (isDeleted) {
              bloc.add(QuicksplitDeleteTransaction(expenseID));
              return emit(
                NewTransactionSuccess(data: QuicksplitTransactionModel.empty()),
              );
            } else {
              return emit(
                NewTransactionFailure(error: "Something went wrong!"),
              );
            }
          }
        case TransactionType.personal:
          {
            bloc = context.read<PersonalMonthlyExpenseBloc>();
            bloc.add(PersonalMonthlyExpenseDelete(true, expenseID));
            final bool isDeleted = await repoPS.delete(expenseID, expenseType);

            if (isDeleted) {
              bloc.add(PersonalMonthlyExpenseDelete(false, expenseID));
              return emit(
                NewTransactionSuccess(
                  data: PersonalExpenseTransactionModel.empty(),
                ),
              );
            } else {
              bloc.add(PersonalMonthlyExpenseDelete(false, expenseID));
              return emit(
                NewTransactionFailure(error: "Something went wrong!"),
              );
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
            final bool isDeleted = await repoLD.delete(roomID, expenseID);

            if (isDeleted) {
              bloc.add(LendenDeleteTransaction(expenseID: expenseID));
              return emit(
                NewTransactionSuccess(data: LendenTransactionModel.empty()),
              );
            } else {
              return emit(
                NewTransactionFailure(error: "Something went wrong!"),
              );
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
            );

            if (isDeleted) {
              bloc.add(RoomDeleteTransaction(expenseID));
              return emit(
                NewTransactionSuccess(data: RoomTransactionModel.empty()),
              );
            } else {
              return emit(
                NewTransactionFailure(error: "Something went wrong!"),
              );
            }
          }
      }
    } catch (e) {
      if (transactionType == TransactionType.personal) {
        bloc.add(PersonalMonthlyExpenseDelete(false, expenseID));
      }
      return emit(NewTransactionFailure(error: e.toString()));
    }
  }

  void reset() {
    return emit(NewTransactionInitial());
  }
}
