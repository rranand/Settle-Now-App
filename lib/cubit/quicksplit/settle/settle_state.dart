part of 'settle_cubit.dart';

class SettleState {
  Set<String> settlingExpense;

  SettleState({this.settlingExpense = const {}});

  SettleState copyWith({Set<String>? settlingExpense}) {
    return SettleState(
      settlingExpense: settlingExpense ?? this.settlingExpense,
    );
  }

  @override
  String toString() {
    return 'SettleState(TransactionIDs: $settlingExpense)';
  }
}
