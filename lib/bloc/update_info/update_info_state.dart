part of 'update_info_bloc.dart';

@immutable
sealed class UpdateInfoState {}

final class UpdateInfoInitial extends UpdateInfoState {}

final class UpdateInfoLoading extends UpdateInfoState {}

final class UpdateInfoSuccess extends UpdateInfoState {
  final UpdateInfoModel data;

  UpdateInfoSuccess({required this.data});
}

final class UpdateInfoFailure extends UpdateInfoState {
  final String error;

  UpdateInfoFailure(this.error);
}
