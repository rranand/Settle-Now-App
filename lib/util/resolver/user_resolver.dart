import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/custom/typedefs.dart';

class UserResolver {
  UserResolver._();
  static final UserResolver instance = UserResolver._();

  final Map<String, FriendUserModel> _cache = {};
  static String _loggedInUserId = "";

  void initializer(UserPreferenceBundle userPreferenceBundle) {
    _loggedInUserId = userPreferenceBundle.user.id;
    _cache[_loggedInUserId] = userPreferenceBundle.user;

    for (final f in userPreferenceBundle.friends) {
      _cache[f.id] = f;
    }
  }

  FriendUserModel resolve(String userId) {
    return _cache[userId] ?? FriendUserModel.unknownFriend();
  }

  FriendUserModel getLoggedInUser() {
    return _cache[_loggedInUserId] ?? FriendUserModel.empty();
  }

  List<FriendUserModel> getFriends() {
    List<FriendUserModel> arr = [];

    for (var ele in _cache.entries) {
      if (ele.key == _loggedInUserId) {
        continue;
      }
      arr.add(ele.value);
    }

    return arr;
  }

  void clear() {
    _loggedInUserId = "";
    _cache.clear();
  }
}
