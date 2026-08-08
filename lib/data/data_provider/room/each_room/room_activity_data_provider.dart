part of 'room_data_provider.dart';

extension RoomActivityDataProvider on RoomDataProvider {
  Future<List<ActivityModel>> fetchActivity(String id) async {
    try {
      final response = await createAPICall('room/$id/activity', "get", {});

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<ActivityModel> arr = [];
        for (int i = 0; i < data['data'].length; i++) {
          arr.add(ActivityModel.fromMap(data['data'][i]));
        }
        return arr;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
