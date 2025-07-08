import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/quicksplit/quicksplit_bloc.dart';
import 'package:settlenow_v2/bloc/room/each_room/room_bloc.dart';
import 'package:settlenow_v2/data/repository/quicksplit_repository.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow_v2/util/enum/transaction_type.dart';

part 'add_to_personal_expense_event.dart';
part 'add_to_personal_expense_state.dart';

class AddToPersonalExpenseBloc
    extends Bloc<AddToPersonalExpenseEvent, AddToPersonalExpenseState> {
  final QuicksplitRepository quickSplitRepo;
  final QuicksplitBloc quicksplitBloc;
  final RoomBloc roomBloc;
  final RoomRepository roomRepository;

  AddToPersonalExpenseBloc(
    this.quicksplitBloc,
    this.quickSplitRepo,
    this.roomBloc,
    this.roomRepository,
  ) : super(AddToPersonalExpenseState()) {
    on<AddToPersonalExpenseRequested>(_addToPersonalExpenseRequested);
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
            await quickSplitRepo.addToPersonalExpense(
              event.transactionID,
              event.authToken,
            );
            oldProcessingIDs.remove(event.transactionID);
            quicksplitBloc.add(
              QuicksplitAddToPersonalExpense(event.transactionID),
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
            await roomRepository.addToPersonalExpense(
              event.roomID,
              event.transactionID,
              event.splitType,
              event.authToken,
            );
            oldProcessingIDs.remove(event.transactionID);
            roomBloc.add(
              RoomAddToPersonalExpense(event.roomID, event.transactionID),
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
}
