import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/quicksplit_repository.dart';
import 'package:settlenow_v2/model/transaction_model.dart';

part 'quicksplit_event.dart';
part 'quicksplit_state.dart';

class QuicksplitBloc extends Bloc<QuicksplitEvent, QuicksplitState> {
  final QuicksplitRepository repo;

  QuicksplitBloc(this.repo) : super(QuicksplitInitial()) {
    on<QuicksplitFetch>(_quicksplitFetch);
    on<QuicksplitAddNewTransaction>(_quicksplitAddNewTransaction);
    on<QuicksplitUpdateTransaction>(_quicksplitUpdateTransaction);
    on<QuicksplitDeleteTransaction>(_quicksplitDeleteTransaction);
  }

  void _quicksplitFetch(
    QuicksplitFetch event,
    Emitter<QuicksplitState> emit,
  ) async {
    emit(QuicksplitLoading());
    try {
      List<TransactionModel> data = await repo.fetchData("niriif@kff.ed");
      return emit(QuicksplitFetchSuccess(data));
    } catch (e) {
      return emit(QuicksplitFailure(e.toString()));
    }
  }

  void _quicksplitAddNewTransaction(
    QuicksplitAddNewTransaction event,
    Emitter<QuicksplitState> emit,
  ) async {
    final oldData = state as QuicksplitFetchSuccess;
    List<TransactionModel> data = [event.data, ...oldData.data];
    return emit(QuicksplitFetchSuccess(data));
  }

  void _quicksplitUpdateTransaction(
    QuicksplitUpdateTransaction event,
    Emitter<QuicksplitState> emit,
  ) async {
    final oldData = state as QuicksplitFetchSuccess;
    List<TransactionModel> data = [...oldData.data];
    for (int i = 0; i < data.length; i++) {
      if (data[i].id == event.data.id) {
        data[i] = event.data;
      }
    }
    return emit(QuicksplitFetchSuccess(data));
  }

  void _quicksplitDeleteTransaction(
    QuicksplitDeleteTransaction event,
    Emitter<QuicksplitState> emit,
  ) async {
    final oldData = state as QuicksplitFetchSuccess;
    List<TransactionModel> data = [...oldData.data];
    data.removeWhere((element) => element.id == event.expenseID);
    return emit(QuicksplitFetchSuccess(data));
  }
}
