import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';

part 'room_category_wise_total_amount_state.dart';

class RoomCategoryWiseTotalAmountCubit
    extends Cubit<RoomCategoryWiseTotalAmountState> {
  final RoomRepository repo;

  RoomCategoryWiseTotalAmountCubit(this.repo)
    : super(RoomCategoryWiseTotalAmountInitial());

  void fetchData(String id) async {
    if (state is RoomCategoryWiseTotalAmountLoading &&
        (state as RoomCategoryWiseTotalAmountLoading).id == id) {
      return;
    }

    emit(RoomCategoryWiseTotalAmountLoading(id: id));

    try {
      final data = await repo.fetchCategoryWiseTotalAmount(id);

      LinkedHashMap<String, CategoryAmountModel> categoryWiseAmount =
          LinkedHashMap<String, CategoryAmountModel>.fromEntries(
            data.map((t) => MapEntry(t.category, t)),
          );
      return emit(
        RoomCategoryWiseTotalAmountSuccess(id: id, data: categoryWiseAmount),
      );
    } catch (e) {
      return emit(
        RoomCategoryWiseTotalAmountFailure(id: id, error: e.toString()),
      );
    }
  }

  void onUpdate(String id, String category, double amount) {
    if (state is RoomCategoryWiseTotalAmountSuccess &&
        (state as RoomCategoryWiseTotalAmountSuccess).id == id) {
      final currentState = state as RoomCategoryWiseTotalAmountSuccess;
      final updatedData = LinkedHashMap<String, CategoryAmountModel>.from(
        currentState.data,
      );

      if (updatedData.containsKey(category)) {
        final updatedAmount = updatedData[category]!.amount + amount;

        if (updatedAmount <= 0) {
          updatedData.remove(category);
        } else {
          updatedData[category] = CategoryAmountModel(
            category: category,
            amount: updatedAmount,
          );
        }
      } else {
        updatedData[category] = CategoryAmountModel(
          category: category,
          amount: amount,
        );
      }

      emit(RoomCategoryWiseTotalAmountSuccess(id: id, data: updatedData));
    }
  }
}
