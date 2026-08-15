import 'dart:collection';

import 'package:settlenow/model/model_core.dart';

class RoomDashboardModel {
  LinkedHashMap<String, RoomInfoModel> data;
  List<RoomInfoModel> dataList;
  bool hasMoreData;
  bool isLoadingMore;

  RoomDashboardModel({
    required this.data,
    required this.hasMoreData,
    required this.isLoadingMore,
  }) : dataList = data.values.toList();

  RoomDashboardModel copyWith({
    LinkedHashMap<String, RoomInfoModel>? data,
    bool? hasMoreData,
    bool? isLoadingMore,
  }) {
    return RoomDashboardModel(
      data: data ?? this.data,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
