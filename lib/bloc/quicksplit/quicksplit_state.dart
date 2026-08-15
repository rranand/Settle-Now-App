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
  final String? toastMessage;

  QuicksplitFetchSuccess({
    required this.data,
    required this.hasMoreData,
    this.isLoadingMore = false,
    this.toastMessage,
  }) : dataList = data.values.toList();

  QuicksplitFetchSuccess copyWith({
    LinkedHashMap<String, QuicksplitTransactionModel>? data,
    bool? hasMoreData,
    bool? isLoadingMore,
    String? toastMessage,
  }) {
    return QuicksplitFetchSuccess(
      data: data ?? this.data,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      toastMessage: toastMessage,
    );
  }
}

final class QuicksplitFailure extends QuicksplitState {
  final String error;

  QuicksplitFailure({required this.error});
}
