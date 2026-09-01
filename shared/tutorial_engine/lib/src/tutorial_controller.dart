import 'package:flutter/widgets.dart';

import 'tutorial_store.dart';

class TutorialController extends ChangeNotifier {
  TutorialController({TutorialStore? store})
      : store = store ?? MemoryTutorialStore();

  final TutorialStore store;

  String? _activeTourId;
  GlobalKey? _spotlightKey;

  String? get activeTourId => _activeTourId;
  bool get isActive => _activeTourId != null;

  bool start(String tourId, {bool force = false}) {
    if (!force && store.hasSeen(tourId)) return false;
    _activeTourId = tourId;
    notifyListeners();
    return true;
  }

  Future<void> complete() async {
    final id = _activeTourId;
    _activeTourId = null;
    notifyListeners();
    if (id != null) await store.markSeen(id);
  }

  void cancel() {
    if (_activeTourId == null) return;
    _activeTourId = null;
    notifyListeners();
  }

  void bindSpotlight(GlobalKey? key) {
    _spotlightKey = key;
  }

  Rect? spotlightRect() {
    final context = _spotlightKey?.currentContext;
    final box = context?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}
