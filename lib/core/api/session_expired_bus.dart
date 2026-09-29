import 'dart:async';

/// Global broadcast fired whenever [AuthInterceptor] determines the server
/// session is dead (refresh-token reuse revocation, refresh 401, retry 401).
///
/// This closes the redirect loop without a circular dependency:
/// interceptor → bus → [AuthCubit] emits `Unauthenticated` → GoRouter
/// `refreshListenable` fires → user lands on login.
///
/// Backend note: after the JWT secret rotation every stored token is dead,
/// and refresh-token reuse now revokes the whole session family (no more
/// 60s grace). Any 401-after-refresh therefore means "go to login, do not
/// retry in a loop".
class SessionExpiredBus {
  SessionExpiredBus._();

  static final SessionExpiredBus instance = SessionExpiredBus._();

  final StreamController<void> _controller =
      StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notifySessionExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  void dispose() => _controller.close();
}
