import 'dart:async';

/// Broadcasts "the refresh token is no longer valid" from the network layer
/// so the UI can send the user back to Login.
class SessionExpiry {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() {
    if (!_controller.isClosed) _controller.add(null);
  }
}
