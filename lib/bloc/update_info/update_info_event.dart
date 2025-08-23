part of 'update_info_bloc.dart';

@immutable
sealed class UpdateInfoEvent {}

class UpdateInfoFetchRequested extends UpdateInfoEvent {
  final FirebaseRemote remoteConfigService;

  UpdateInfoFetchRequested(this.remoteConfigService);
}
