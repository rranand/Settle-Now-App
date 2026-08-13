part of 'room_data_provider.dart';

extension RoomActivityDataProvider on RoomDataProvider {
  Future<Pair<List<ActivityModel>, bool>> fetchActivity(
    String id,
    DateTime cursor,
  ) async {
    try {
      final response = await createAPICall(
        'room/$id/activity?${addCursorInURL(cursor)}',
        "get",
        {},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        bool hasMore = data['has_more'];
        final allActivity = data['data'];
        List<ActivityModel> arr = [];

        if (allActivity != null) {
          for (int i = 0; i < allActivity.length; i++) {
            arr.add(ActivityModel.fromMap(allActivity[i]));
          }
        }
        return Pair(arr, hasMore);
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
