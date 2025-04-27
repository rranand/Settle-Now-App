part of 'quicksplit_bloc.dart';

@immutable
sealed class QuicksplitState {
  final bool hasData;

  const QuicksplitState({this.hasData = false});
}

final class QuicksplitInitial extends QuicksplitState {
  const QuicksplitInitial() : super(hasData: false);
}

final class QuicksplitLoading extends QuicksplitState {
  const QuicksplitLoading() : super(hasData: false);
}

final class QuicksplitFetchSuccess extends QuicksplitState {
  final List<QuickSplitModel> data;

  const QuicksplitFetchSuccess(this.data) : super(hasData: true);
}

final class QuicksplitFailure extends QuicksplitState {
  final String error;

  const QuicksplitFailure(this.error) : super(hasData: false);
}
