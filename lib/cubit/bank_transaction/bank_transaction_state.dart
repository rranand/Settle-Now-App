part of 'bank_transaction_cubit.dart';

@immutable
sealed class BankTransactionState {}

final class BankTransactionInitial extends BankTransactionState {}

final class BankTransactionLoading extends BankTransactionState {
  BankTransactionLoading();
}

final class BankTransactionSuccess extends BankTransactionState {
  final List<BankTransactionModel> data;
  final bool hasMoreData;
  final bool isLoadingMore;
  final int messagesProcessedCount;

  BankTransactionSuccess({
    required this.data,
    required this.hasMoreData,
    required this.isLoadingMore,
    required this.messagesProcessedCount,
  });

  BankTransactionSuccess copyWith({
    List<BankTransactionModel>? data,
    bool? hasMoreData,
    bool? isLoadingMore,
    int? messagesProcessedCount,
  }) {
    return BankTransactionSuccess(
      data: data ?? this.data,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      messagesProcessedCount:
          messagesProcessedCount ?? this.messagesProcessedCount,
    );
  }
}

final class BankTransactionFailure extends BankTransactionState {
  final String error;

  BankTransactionFailure({required this.error});
}
