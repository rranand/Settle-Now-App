part of 'bank_transaction_cubit.dart';

@immutable
sealed class BankTransactionState {}

final class BankTransactionInitial extends BankTransactionState {}

final class BankTransactionLoading extends BankTransactionState {
  BankTransactionLoading();
}

final class BankTransactionSuccess extends BankTransactionState {
  final List<BankTransactionModel> data;
  final List<Bank> banks;
  final List<PaymentMode> paymentModes;

  BankTransactionSuccess({
    required this.data,
    required this.banks,
    required this.paymentModes,
  });

  BankTransactionSuccess copyWith({
    List<BankTransactionModel>? data,
    List<Bank>? banks,
    List<PaymentMode>? paymentModes,
  }) {
    return BankTransactionSuccess(
      data: data ?? this.data,
      banks: banks ?? this.banks,
      paymentModes: paymentModes ?? this.paymentModes,
    );
  }
}

final class BankTransactionFailure extends BankTransactionState {
  final String error;

  BankTransactionFailure({required this.error});
}
