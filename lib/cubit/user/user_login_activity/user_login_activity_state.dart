part of 'user_login_activity_cubit.dart';

@immutable
class UserLoginActivityState {
  final bool isLoading;
  final List<LoginActivityModel> data;
  final String? error;

  const UserLoginActivityState({
    this.data = const [],
    this.isLoading = false,
    this.error,
  });

  UserLoginActivityState copyWith({
    bool? isLoading,
    List<LoginActivityModel>? data,
    String? error,
  }) {
    return UserLoginActivityState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}
