part of 'user_update_profile_cubit.dart';

@immutable
class UserUpdateProfileState {
  final bool isLoading;
  final bool isUpdated;
  final String? error;

  const UserUpdateProfileState({
    this.isLoading = false,
    this.isUpdated = false,
    this.error,
  });

  UserUpdateProfileState copyWith({
    bool? isLoading,
    bool? isUpdated,
    String? error,
  }) {
    return UserUpdateProfileState(
      isLoading: isLoading ?? this.isLoading,
      isUpdated: isUpdated ?? this.isUpdated,
      error: error ?? this.error,
    );
  }
}
