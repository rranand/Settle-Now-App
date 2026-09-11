import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'add_to_personal_expense_event.dart';
part 'add_to_personal_expense_state.dart';

class AddToPersonalExpenseBloc
    extends Bloc<AddToPersonalExpenseEvent, AddToPersonalExpenseState> {
  final QuicksplitRepository _quickSplitRepo;
  final QuicksplitBloc _quicksplitBloc;
  final RoomBloc _roomBloc;
  final RoomRepository _roomRepository;

  AddToPersonalExpenseBloc(
    this._quicksplitBloc,
    this._quickSplitRepo,
    this._roomBloc,
    this._roomRepository,
  ) : super(AddToPersonalExpenseState()) {
    on<AddToPersonalExpenseRequested>(_addToPersonalExpenseRequested);
    on<AddToPersonalExpenseReset>(_addToPersonalExpenseReset);
  }

  void _addToPersonalExpenseRequested(
    AddToPersonalExpenseRequested event,
    Emitter<AddToPersonalExpenseState> emit,
  ) async {
    if (state.addingExpenseToPersonalExpense.contains(event.transactionID)) {
      return;
    }
    Set<String> oldProcessingIDs = Set.from(
      state.addingExpenseToPersonalExpense,
    );

    switch (event.transactionType) {
      case TransactionType.quicksplit:
        {
          oldProcessingIDs.add(event.transactionID);
          try {
            emit(
              state.copyWith(addingExpenseToPersonalExpense: oldProcessingIDs),
            );
            String personalExpenseID = await _quickSplitRepo
                .addToPersonalExpense(event.transactionID);
            oldProcessingIDs.remove(event.transactionID);
            _quicksplitBloc.add(
              QuicksplitAddToPersonalExpense(
                transactionID: event.transactionID,
                personalExpenseID: personalExpenseID,
              ),
            );
            return emit(
              state.copyWith(addingExpenseToPersonalExpense: oldProcessingIDs),
            );
          } catch (e) {
            oldProcessingIDs.remove(event.transactionID);
            return emit(
              state.copyWith(addingExpenseToPersonalExpense: oldProcessingIDs),
            );
          }
        }
      case TransactionType.room:
        {
          oldProcessingIDs.add(event.transactionID);
          try {
            emit(
              state.copyWith(addingExpenseToPersonalExpense: oldProcessingIDs),
            );
            String personalExpenseID = await _roomRepository
                .addToPersonalExpense(event.roomID, event.transactionID);
            oldProcessingIDs.remove(event.transactionID);
            _roomBloc.add(
              RoomAddToPersonalExpense(
                id: event.roomID,
                expenseID: event.transactionID,
                personalExpenseID: personalExpenseID,
              ),
            );
            return emit(
              state.copyWith(addingExpenseToPersonalExpense: oldProcessingIDs),
            );
          } catch (e) {
            oldProcessingIDs.remove(event.transactionID);
            return emit(
              state.copyWith(addingExpenseToPersonalExpense: oldProcessingIDs),
            );
          }
        }
      default:
        {}
    }
  }

  void _addToPersonalExpenseReset(
    AddToPersonalExpenseReset event,
    Emitter<AddToPersonalExpenseState> emit,
  ) {
    return emit(AddToPersonalExpenseState());
  }
}
