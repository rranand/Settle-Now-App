import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'new_transaction_state.dart';

class NewTransactionCubit extends Cubit<NewTransactionState> {
  final QuicksplitRepository _repo;
  final PersonalMonthlyExpenseRepository _repoPS;
  final LendenRoomRepository _repoLD;
  final RoomRepository _repoRD;

  NewTransactionCubit(this._repo, this._repoPS, this._repoLD, this._repoRD)
    : super(NewTransactionInitial());

  void createNewExpense(
    BuildContext context,
    BaseTransactionModel baseTransData,
    TransactionType transactionType, {
    SplitType splitType = SplitType.equal,
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
            final newData = await _repo.create(data);
            bloc.add(QuicksplitAddNewTransaction(data: newData));
            return emit(NewTransactionSuccess(data: newData));
          }
        case TransactionType.personal:
          {
            final bloc = context.read<PersonalMonthlyExpenseBloc>();
            final data = baseTransData as PersonalExpenseTransactionModel;
            final PersonalExpenseTransactionModel newData = await _repoPS.add(
              data,
            );

            bloc.add(PersonalMonthlyExpenseAdd(data: newData));
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

            final LendenTransactionModel newData = await _repoLD.create(
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
            final newData = await _repoRD.createExpense(roomID, data, splitType);
            final newUpdatedData = newData.copyWith(
              activityCount: newData.activityCount + 1,
            );
            bloc.add(RoomAddNewTransaction(data: [newUpdatedData]));
            return emit(NewTransactionSuccess(data: newUpdatedData));
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
      final List<RoomTransactionModel> newData = await _repoRD.createBulkExpense(
        roomID,
        data,
      );
      bloc.add(RoomAddNewTransaction(data: newData));
      return emit(NewTransactionSuccess(data: newData.first));
    } catch (e) {
      return emit(NewTransactionFailure(error: e.toString()));
    }
  }

  void updateExpense(
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
            await _repo.update(data);
            bloc.add(QuicksplitUpdateTransaction(data: data));
            return emit(NewTransactionSuccess(data: data));
          }
        case TransactionType.personal:
          {
            final bloc = context.read<PersonalMonthlyExpenseBloc>();
            final data = baseTransData as PersonalExpenseTransactionModel;
            await _repoPS.update(data);
            bloc.add(PersonalMonthlyExpenseUpdate(data: data));
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
            await _repoLD.update(roomID, data);
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
            await _repoRD.updateExpense(roomID, data);
            final newUpdatedData = data.copyWith(
              activityCount: data.activityCount + 1,
            );
            bloc.add(RoomUpdateTransaction(data: newUpdatedData));
            return emit(NewTransactionSuccess(data: newUpdatedData));
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
    TransactionType personalExpenseSubType = TransactionType.personal,
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
            await _repo.delete(expenseID);
            bloc.add(QuicksplitDeleteTransaction(transactionID: expenseID));
            return emit(
              NewTransactionSuccess(data: QuicksplitTransactionModel.empty()),
            );
          }
        case TransactionType.personal:
          {
            bloc = context.read<PersonalMonthlyExpenseBloc>();
            bloc.add(
              PersonalMonthlyExpenseDelete(
                isLoading: true,
                expenseID: expenseID,
              ),
            );
            await _repoPS.delete(expenseID, personalExpenseSubType);

            bloc.add(
              PersonalMonthlyExpenseDelete(
                isLoading: false,
                expenseID: expenseID,
              ),
            );
            return emit(
              NewTransactionSuccess(
                data: PersonalExpenseTransactionModel.empty(),
              ),
            );
          }
        case TransactionType.lenden:
          {
            bloc = context.read<LendenRoomBloc>();
            final blocState = bloc.state;
            if (blocState is! LendenRoomFetchSuccess) {
              return;
            }
            final roomID = blocState.id;
            await _repoLD.delete(roomID, expenseID);

            bloc.add(LendenDeleteTransaction(expenseID: expenseID));
            return emit(
              NewTransactionSuccess(data: LendenTransactionModel.empty()),
            );
          }
        case TransactionType.room:
          {
            bloc = context.read<RoomBloc>();
            final blocState = bloc.state;
            if (blocState is! RoomFetchSuccess) {
              return;
            }
            final roomID = blocState.id;
            await _repoRD.deleteExpense(roomID, expenseID);

            bloc.add(RoomDeleteTransaction(expenseID: expenseID));
            return emit(
              NewTransactionSuccess(data: RoomTransactionModel.empty()),
            );
          }
      }
    } catch (e) {
      if (transactionType == TransactionType.personal) {
        bloc.add(
          PersonalMonthlyExpenseDelete(isLoading: false, expenseID: expenseID),
        );
      }
      return emit(NewTransactionFailure(error: e.toString()));
    }
  }

  void reset() {
    return emit(NewTransactionInitial());
  }
}
