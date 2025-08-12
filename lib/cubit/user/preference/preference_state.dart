part of 'preference_cubit.dart';

@immutable
sealed class PreferenceState {}

final class PreferenceInitial extends PreferenceState {}

final class PreferenceSuccess extends PreferenceState {}

final class PreferenceFailure extends PreferenceState {
  final String error;

  PreferenceFailure(this.error);
}
