part of 'room_bloc.dart';

@immutable
sealed class RoomState {}

final class RoomInitial extends RoomState {}

final class RoomLoading extends RoomState {
  final String id;

  RoomLoading({required this.id});
}

final class RoomFetchSuccess extends RoomState {
  final String id;
  final LinkedHashMap<String, RoomTransactionModel> data;
  final List<RoomTransactionModel> dataList;
  final bool hasMoreData;
  final bool isLoadingMore;
  final String? toastMessage;

  RoomFetchSuccess({
    required this.id,
    required this.data,
    required this.hasMoreData,
    this.isLoadingMore = false,
    this.toastMessage,
  }) : dataList = data.values.toList();

  RoomFetchSuccess copyWith({
    String? id,
    LinkedHashMap<String, RoomTransactionModel>? data,
    bool? hasMoreData,
    bool? isLoadingMore,
    String? toastMessage,
  }) {
    return RoomFetchSuccess(
      id: id ?? this.id,
      data: data ?? this.data,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      toastMessage: toastMessage,
    );
  }
}

final class RoomFailure extends RoomState {
  final String error;

  RoomFailure({required this.error});
}
