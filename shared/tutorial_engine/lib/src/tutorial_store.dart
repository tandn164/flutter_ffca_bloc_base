abstract class TutorialStore {
  bool hasSeen(String tourId);
  Future<void> markSeen(String tourId);
  Future<void> forget(String tourId);
}

class MemoryTutorialStore implements TutorialStore {
  final Set<String> _seen = {};

  @override
  bool hasSeen(String tourId) => _seen.contains(tourId);

  @override
  Future<void> markSeen(String tourId) async => _seen.add(tourId);

  @override
  Future<void> forget(String tourId) async => _seen.remove(tourId);
}

/// Persistence adapter without coupling this package to a storage provider.
class CallbackTutorialStore implements TutorialStore {
  const CallbackTutorialStore({
    required this.read,
    required this.write,
    this.keyPrefix = 'tutorial_seen_',
  });

  final bool Function(String key) read;
  final Future<void> Function(String key, bool value) write;
  final String keyPrefix;

  String _key(String tourId) => '$keyPrefix$tourId';

  @override
  bool hasSeen(String tourId) => read(_key(tourId));

  @override
  Future<void> markSeen(String tourId) => write(_key(tourId), true);

  @override
  Future<void> forget(String tourId) => write(_key(tourId), false);
}
