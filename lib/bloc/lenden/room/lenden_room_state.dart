part of 'lenden_room_bloc.dart';

@immutable
sealed class LendenRoomState {}

final class LendenRoomInitial extends LendenRoomState {}

final class LendenRoomLoading extends LendenRoomState {}

final class LendenRoomFetchSuccess extends LendenRoomState {
  final String id;
  final LendenDashboardModel roomData;
  final LinkedHashMap<String, LendenTransactionModel> data;
  final List<LendenTransactionModel> dataList;
  final bool hasMoreData;
  final bool isLoadingMore;
  final String? toastMessage;

  LendenRoomFetchSuccess({
    required this.id,
    required this.roomData,
    required this.data,
    required this.hasMoreData,
    this.isLoadingMore = false,
    this.toastMessage,
  }) : dataList = data.values.toList();

  LendenRoomFetchSuccess copyWith({
    String? id,
    LendenDashboardModel? roomData,
    LinkedHashMap<String, LendenTransactionModel>? data,
    bool? hasMoreData,
    bool? isLoadingMore,
    String? toastMessage,
  }) {
    return LendenRoomFetchSuccess(
      id: id ?? this.id,
      roomData: roomData ?? this.roomData,
      data: data ?? this.data,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      toastMessage: toastMessage,
    );
  }
}

final class LendenRoomFailure extends LendenRoomState {
  final String error;

  LendenRoomFailure({required this.error});
}
