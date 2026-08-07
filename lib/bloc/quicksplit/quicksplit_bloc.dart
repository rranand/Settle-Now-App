import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'quicksplit_event.dart';
part 'quicksplit_state.dart';

class QuicksplitBloc extends Bloc<QuicksplitEvent, QuicksplitState> {
  final QuicksplitRepository repo;

  QuicksplitBloc(this.repo) : super(QuicksplitInitial()) {
    on<QuicksplitFetch>(_quicksplitFetch);
    on<QuicksplitAddNewTransaction>(_quicksplitAddNewTransaction);
    on<QuicksplitUpdateTransaction>(_quicksplitUpdateTransaction);
    on<QuicksplitDeleteTransaction>(_quicksplitDeleteTransaction);
    on<QuicksplitAddToPersonalExpense>(_quicksplitAddToPersonalExpense);
    on<QuicksplitSettleRequest>(_quicksplitSettleRequest);
    on<QuicksplitReset>(_quicksplitReset);
  }

  void _quicksplitFetch(
    QuicksplitFetch event,
    Emitter<QuicksplitState> emit,
  ) async {
    List<QuicksplitTransactionModel> oldData = [];

    if (!event.isFreshFetch && state is QuicksplitFetchSuccess) {
      final oldState = state as QuicksplitFetchSuccess;
      if (!oldState.hasMoreData) {
        return;
      }

      oldData = [...(oldState.data)];
    }

    if (state is QuicksplitLoading) return;
    emit(QuicksplitLoading());

    try {
      Pair<List<QuicksplitTransactionModel>, bool> data = await repo.fetchData(
        oldData.length,
      );
      return emit(
        QuicksplitFetchSuccess(
          data: [...oldData, ...data.first],
          hasMoreData: data.second,
        ),
      );
    } catch (e) {
      return emit(QuicksplitFailure(error: e.toString()));
    }
  }

  void _quicksplitAddNewTransaction(
    QuicksplitAddNewTransaction event,
    Emitter<QuicksplitState> emit,
  ) async {
    if (state is! QuicksplitFetchSuccess) {
      return;
    }
    final oldState = state as QuicksplitFetchSuccess;
    List<QuicksplitTransactionModel> data = [event.data, ...oldState.data];
    return emit(
      QuicksplitFetchSuccess(data: data, hasMoreData: oldState.hasMoreData),
    );
  }

  void _quicksplitUpdateTransaction(
    QuicksplitUpdateTransaction event,
    Emitter<QuicksplitState> emit,
  ) async {
    if (state is! QuicksplitFetchSuccess) {
      return;
    }
    final oldState = state as QuicksplitFetchSuccess;
    List<QuicksplitTransactionModel> data = [...oldState.data];
    for (int i = 0; i < data.length; i++) {
      if (data[i].id == event.data.id) {
        data[i] = event.data.copyWith(
          personalExpenseId: data[i].personalExpenseId,
        );
        break;
      }
    }
    return emit(
      QuicksplitFetchSuccess(data: data, hasMoreData: oldState.hasMoreData),
    );
  }

  void _quicksplitDeleteTransaction(
    QuicksplitDeleteTransaction event,
    Emitter<QuicksplitState> emit,
  ) async {
    if (state is! QuicksplitFetchSuccess) {
      return;
    }
    final oldState = state as QuicksplitFetchSuccess;
    List<QuicksplitTransactionModel> data = [...oldState.data];
    data.removeWhere((element) => element.id == event.transactionID);
    return emit(
      QuicksplitFetchSuccess(data: data, hasMoreData: oldState.hasMoreData),
    );
  }

  void _quicksplitAddToPersonalExpense(
    QuicksplitAddToPersonalExpense event,
    Emitter<QuicksplitState> emit,
  ) async {
    if (state is! QuicksplitFetchSuccess) {
      return;
    }
    final oldState = state as QuicksplitFetchSuccess;
    List<QuicksplitTransactionModel> oldData = List.from(oldState.data);

    for (int i = 0; i < oldData.length; i++) {
      if (oldData[i].id == event.transactionID) {
        oldData[i].personalExpenseId = event.personalExpenseID;
      }
    }

    return emit(
      QuicksplitFetchSuccess(data: oldData, hasMoreData: oldState.hasMoreData),
    );
  }

  void _quicksplitSettleRequest(
    QuicksplitSettleRequest event,
    Emitter<QuicksplitState> emit,
  ) {
    if (state is! QuicksplitFetchSuccess) {
      return;
    }
    final oldState = state as QuicksplitFetchSuccess;
    List<QuicksplitTransactionModel> oldData = List.from(oldState.data);

    for (int i = 0; i < oldData.length; i++) {
      if (oldData[i].id == event.transactionID) {
        int settledUserCount = 0;

        for (int j = 0; j < oldData[i].users.length; j++) {
          if (oldData[i].users[j].id == event.uid) {
            oldData[i].users[j].isSettled = true;
          }
          settledUserCount += oldData[i].users[j].isSettled ? 1 : 0;
        }
        if (settledUserCount == oldData[i].users.length + 1) {
          oldData[i].active = false;
        }
        oldData[i].isClosedAny = true;
      }
    }

    return emit(
      QuicksplitFetchSuccess(data: oldData, hasMoreData: oldState.hasMoreData),
    );
  }

  void _quicksplitReset(QuicksplitReset event, Emitter<QuicksplitState> emit) {
    return emit(QuicksplitInitial());
  }
}
