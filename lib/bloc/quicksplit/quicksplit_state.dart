part of 'quicksplit_bloc.dart';

@immutable
sealed class QuicksplitState {}

final class QuicksplitInitial extends QuicksplitState {}

final class QuicksplitLoading extends QuicksplitState {}

final class QuicksplitFetchSuccess extends QuicksplitState {
  final List<TransactionModel> data;
  final bool hasMoreData;

  QuicksplitFetchSuccess({required this.data, required this.hasMoreData});
}

final class QuicksplitFailure extends QuicksplitState {
  final String error;

  QuicksplitFailure({required this.error});
}
