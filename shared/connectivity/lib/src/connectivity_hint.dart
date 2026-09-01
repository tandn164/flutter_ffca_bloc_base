/// A conservative connectivity signal.
///
/// `false` means "unknown or probably online", not a guarantee that a request
/// will succeed. Callers must still handle transport failures.
abstract class ConnectivityHint {
  bool get isSureOffline;

  void addListener(void Function() listener);

  void removeListener(void Function() listener);
}

/// A controllable implementation for demos and tests.
class FakeConnectivity implements ConnectivityHint {
  bool _offline = false;
  final List<void Function()> _listeners = [];

  @override
  bool get isSureOffline => _offline;

  @override
  void addListener(void Function() listener) => _listeners.add(listener);

  @override
  void removeListener(void Function() listener) => _listeners.remove(listener);

  void setOffline(bool value) {
    if (_offline == value) return;
    _offline = value;
    for (final listener in List<void Function()>.from(_listeners)) {
      listener();
    }
  }
}
