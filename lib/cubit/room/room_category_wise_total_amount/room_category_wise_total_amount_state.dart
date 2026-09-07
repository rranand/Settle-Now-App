part of 'room_category_wise_total_amount_cubit.dart';

@immutable
sealed class RoomCategoryWiseTotalAmountState {}

final class RoomCategoryWiseTotalAmountInitial
    extends RoomCategoryWiseTotalAmountState {}

final class RoomCategoryWiseTotalAmountLoading
    extends RoomCategoryWiseTotalAmountState {
  final String id;
  RoomCategoryWiseTotalAmountLoading({required this.id});
}

final class RoomCategoryWiseTotalAmountSuccess
    extends RoomCategoryWiseTotalAmountState {
  final String id;
  final List<CategoryAmountModel> dataList;
  final LinkedHashMap<String, CategoryAmountModel> data;

  RoomCategoryWiseTotalAmountSuccess({required this.id, required this.data})
    : dataList = data.values.toList();

  RoomCategoryWiseTotalAmountSuccess copyWith({
    String? id,
    LinkedHashMap<String, CategoryAmountModel>? data,
  }) {
    return RoomCategoryWiseTotalAmountSuccess(
      id: id ?? this.id,
      data: data ?? this.data,
    );
  }
}

final class RoomCategoryWiseTotalAmountFailure
    extends RoomCategoryWiseTotalAmountState {
  final String id;
  final String error;

  RoomCategoryWiseTotalAmountFailure({required this.id, required this.error});
}
