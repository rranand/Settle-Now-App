import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/lenden_repository.dart';
import 'package:settlenow_v2/model/lenden_model.dart';

part 'lenden_event.dart';
part 'lenden_state.dart';


class LendenBloc extends Bloc<LendenEvent, LendenState> {
  final LendenRepository lendenRepository;

  LendenBloc(this.lendenRepository) : super(LendenInitial()) {
    on<LendenFetch>(_lendenFetch);
  }

  void _lendenFetch(LendenFetch event, Emitter<LendenState> emit) async {
    emit(LendenLoading());
    try {
      List<LendenModel> data = await lendenRepository.fetchData(
        "niriif@kff.ed",
      );
      return emit(LendenFetchSuccess(data));
    } catch (e) {
      return emit(LendenFailure(e.toString()));
    }
  }
}
