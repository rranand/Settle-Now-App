part of 'room_settle_cubit.dart';

@immutable
sealed class RoomSettleState {}

final class RoomSettleInitial extends RoomSettleState {}

final class RoomSettleLoading extends RoomSettleState {
  final String id;

  RoomSettleLoading({required this.id});
}

final class RoomSettleSuccess extends RoomSettleState {
  final String id;
  final LinkedHashMap<String, RoomSettleModel> data;
  final List<RoomSettleModel> dataList;
  final bool hasMoreData;
  final bool isLoadingMore;
  final String? toastMessage;

  RoomSettleSuccess({
    required this.id,
    required this.data,
    required this.hasMoreData,
    this.isLoadingMore = false,
    this.toastMessage,
  }) : dataList = data.values.toList();

  RoomSettleSuccess copyWith({
    String? id,
    LinkedHashMap<String, RoomSettleModel>? data,
    bool? hasMoreData,
    bool? isLoadingMore,
    String? toastMessage,
  }) {
    return RoomSettleSuccess(
      id: id ?? this.id,
      data: data ?? this.data,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      toastMessage: toastMessage,
    );
  }
}

final class RoomSettleFailure extends RoomSettleState {
  final String error;

  RoomSettleFailure({required this.error});
}
