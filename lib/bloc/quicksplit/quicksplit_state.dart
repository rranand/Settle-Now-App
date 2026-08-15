part of 'quicksplit_bloc.dart';

@immutable
sealed class QuicksplitState {}

final class QuicksplitInitial extends QuicksplitState {}

final class QuicksplitLoading extends QuicksplitState {}

final class QuicksplitFetchSuccess extends QuicksplitState {
  final LinkedHashMap<String, QuicksplitTransactionModel> data;
  final List<QuicksplitTransactionModel> dataList;
  final bool hasMoreData;
  final bool isLoadingMore;
  final String? error;

  QuicksplitFetchSuccess({
    required this.data,
    required this.hasMoreData,
    this.isLoadingMore = false,
    this.error,
  }) : dataList = data.values.toList();

  QuicksplitFetchSuccess copyWith({
    LinkedHashMap<String, QuicksplitTransactionModel>? data,
    bool? hasMoreData,
    bool? isLoadingMore,
    String? error,
  }) {
    return QuicksplitFetchSuccess(
      data: data ?? this.data,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

final class QuicksplitFailure extends QuicksplitState {
  final String error;

  QuicksplitFailure({required this.error});
}
