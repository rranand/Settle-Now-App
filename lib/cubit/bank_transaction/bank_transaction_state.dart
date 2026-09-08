part of 'bank_transaction_cubit.dart';

@immutable
sealed class BankTransactionState {}

final class BankTransactionInitial extends BankTransactionState {}

final class BankTransactionLoading extends BankTransactionState {
  BankTransactionLoading();
}

final class BankTransactionSuccess extends BankTransactionState {
  final List<BankTransactionModel> data;

  BankTransactionSuccess({required this.data});

  BankTransactionSuccess copyWith({List<BankTransactionModel>? data}) {
    return BankTransactionSuccess(data: data ?? this.data);
  }
}

final class BankTransactionFailure extends BankTransactionState {
  final String error;

  BankTransactionFailure({required this.error});
}
