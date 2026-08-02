part of 'new_transaction_cubit.dart';

@immutable
sealed class NewTransactionState {}

final class NewTransactionInitial extends NewTransactionState {}

final class NewTransactionLoading extends NewTransactionState {}

final class NewTransactionSuccess extends NewTransactionState {
  final BaseTransactionModel data;

  NewTransactionSuccess({required this.data});
}

final class NewTransactionFailure extends NewTransactionState {
  final String error;

  NewTransactionFailure({required this.error});
}
