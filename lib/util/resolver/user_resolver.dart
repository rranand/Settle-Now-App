import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/custom/typedefs.dart';

class UserResolver {
  UserResolver._();
  static final UserResolver instance = UserResolver._();

  final Map<String, UserModel> _cache = {};
  static String _loggedInUserId = "";

  void initializer(UserPreferenceBundle userPreferenceBundle) {
    _loggedInUserId = userPreferenceBundle.user.id;
    _cache[_loggedInUserId] = userPreferenceBundle.user;

    for (final f in userPreferenceBundle.friends) {
      _cache[f.id] = f;
    }
  }

  UserModel resolve(String userId) {
    return _cache[userId] ?? UserModel.empty();
  }

  UserModel getLoggedInUser() {
    return _cache[_loggedInUserId] ?? UserModel.empty();
  }

  List<UserModel> getFriends() {
    List<UserModel> arr = [];

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
