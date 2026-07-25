import 'package:settlenow/model/model_core.dart';

class UserResolver {
  UserResolver._();
  static final UserResolver instance = UserResolver._();

  final Map<String, UserModel> _cache = {};

  void loadFriends(List<UserModel> friends) {
    for (final f in friends) {
      _cache[f.id] = f;
    }
  }

  UserModel resolve(String userId) {
    return _cache[userId] ?? UserModel.empty();
  }

  //TODO: In case of missing friends, get friend data from server

  void clear() => _cache.clear();
}
