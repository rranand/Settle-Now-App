// This file is only compiled on web (dart.library.html is available).
// On mobile, token_storage_stub.dart is used instead.

import 'package:web/web.dart' as web_interop;

void setItem(String key, String value) {
  web_interop.window.localStorage.setItem(key, value);
}

String? getItem(String key) {
  final value = web_interop.window.localStorage.getItem(key);
  return value;
}

void removeItem(String key) {
  web_interop.window.localStorage.removeItem(key);
}
