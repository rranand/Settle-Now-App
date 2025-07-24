part of 'user_update_profile_cubit.dart';

@immutable
class UserUpdateProfileState {
  final bool isLoading;
  final bool isUpdated;
  final UserModel? newUserData;
  final String? error;

  const UserUpdateProfileState({
    this.isLoading = false,
    this.isUpdated = false,
    this.newUserData,
    this.error,
  });

  UserUpdateProfileState copyWith({
    bool? isLoading,
    bool? isUpdated,
    String? error,
    UserModel? newUserData,
  }) {
    return UserUpdateProfileState(
      isLoading: isLoading ?? this.isLoading,
      isUpdated: isUpdated ?? this.isUpdated,
      error: error ?? this.error,
      newUserData: newUserData ?? this.newUserData,
    );
  }
}
