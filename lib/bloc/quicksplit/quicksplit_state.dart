part of 'quicksplit_bloc.dart';

@immutable
sealed class QuicksplitState {}

final class QuicksplitInitial extends QuicksplitState {}

final class QuicksplitLoading extends QuicksplitState {}

final class QuicksplitFetchSuccess extends QuicksplitState {
  final List<QuickSplitModel> data;

  QuicksplitFetchSuccess(this.data);
}

final class QuicksplitFailure extends QuicksplitState {
  final String error;

  QuicksplitFailure(this.error);
}
