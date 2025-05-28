part of 'user_login_activity_cubit.dart';

@immutable
sealed class UserLoginActivityState {}

class UserLoginActivityDataState extends UserLoginActivityState {
  final bool isLoading;
  final List<LoginActivityModel> data;
  final String? error;

  UserLoginActivityDataState({
    this.data = const [],
    this.isLoading = false,
    this.error,
  });

  UserLoginActivityDataState copyWith({
    bool? isLoading,
    List<LoginActivityModel>? data,
    String? error,
  }) {
    return UserLoginActivityDataState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}
