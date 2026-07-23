import 'dart:async';

class AuthEventBus {
  AuthEventBus._();
  static final AuthEventBus instance = AuthEventBus._();

  final _controller = StreamController<AuthEventEnum>.broadcast();
  Stream<AuthEventEnum> get stream => _controller.stream;

  void emitSessionExpired() => _controller.add(AuthEventEnum.sessionExpired);
}

enum AuthEventEnum { sessionExpired }
