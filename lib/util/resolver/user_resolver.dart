import 'package:flutter/foundation.dart';
import 'package:settlenow/model/model_core.dart';

class UserResolver {
  UserResolver._();
  static final UserResolver instance = UserResolver._();

  final Map<String, UserModel> _cache = {};
  static String _loggedInUserId = "";

  void loadFriends(List<UserModel> friends) {
    for (final f in friends) {
      _cache[f.id] = f;
    }
  }

  void setLoggedInUser(UserModel user) {
    debugPrint("setLoggedInUser -> UserModel : ${user.id} : ${user.name}");
    _loggedInUserId = user.id;
    _cache[_loggedInUserId] = user;
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
