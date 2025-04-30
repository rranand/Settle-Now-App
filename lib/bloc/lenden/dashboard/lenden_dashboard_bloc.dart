import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/lenden/dashboard/lenden_dashboard_repository.dart';
import 'package:settlenow_v2/model/lenden_dashboard_model.dart';

part 'lenden_dashboard_event.dart';
part 'lenden_dashboard_state.dart';


class LendenDashboardBloc extends Bloc<LendenDashboardEvent, LendenDashboardState> {
  final LendenDashboardRepository lendenDashboardRepository;

  LendenDashboardBloc(this.lendenDashboardRepository) : super(LendenDashboardInitial()) {
    on<LendenDashboardFetch>(_lendenDashboardFetch);
  }

  void _lendenDashboardFetch(LendenDashboardFetch event, Emitter<LendenDashboardState> emit) async {
    emit(LendenDashboardLoading());
    try {
      List<LendenDashboardModel> data = await lendenDashboardRepository.fetchData(
        "niriif@kff.ed",
      );
      return emit(LendenDashboardFetchSuccess(data));
    } catch (e) {
      return emit(LendenDashboardFailure(e.toString()));
    }
  }
}
