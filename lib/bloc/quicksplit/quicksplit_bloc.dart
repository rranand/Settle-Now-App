import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/quicksplit_repository.dart';
import 'package:settlenow_v2/model/quicksplit_model.dart';

part 'quicksplit_event.dart';
part 'quicksplit_state.dart';

class QuicksplitBloc extends Bloc<QuicksplitEvent, QuicksplitState> {
  final QuicksplitRepository quicksplitRepository;

  QuicksplitBloc(this.quicksplitRepository) : super(QuicksplitInitial()) {
    on<QuicksplitFetch>(_quicksplitFetch);
  }

  void _quicksplitFetch(
    QuicksplitFetch event,
    Emitter<QuicksplitState> emit,
  ) async {
    emit(QuicksplitLoading());
    try {
      List<QuickSplitModel> data = await quicksplitRepository.fetchData(
        "niriif@kff.ed",
      );
      return emit(QuicksplitFetchSuccess(data));
    } catch (e) {
      return emit(QuicksplitFailure(e.toString()));
    }
  }
}
