import 'dart:async';

import 'overlay_feedback.dart';

class ToastItem {
  const ToastItem({
    required this.id,
    required this.type,
    required this.message,
    required this.dedupeKey,
    required this.duration,
  });

  final String id;
  final ToastType type;
  final String message;
  final String dedupeKey;
  final Duration duration;
}

/// A bounded FIFO queue with exactly one visible toast.
class ToastQueue {
  ToastQueue(this._onChange, {this.maxQueued = 5});

  final void Function() _onChange;
  final int maxQueued;
  final List<ToastItem> _pending = [];
  ToastItem? _active;
  Timer? _timer;
  int _nextId = 0;

  List<ToastItem> get items =>
      _active == null ? const [] : List.unmodifiable([_active!]);
  int get length => _pending.length + (_active == null ? 0 : 1);

  void show({
    required ToastType type,
    required String message,
    required Duration duration,
    String? dedupeKey,
  }) {
    final key = dedupeKey ?? '$type|$message';
    if (_active?.dedupeKey == key ||
        _pending.any((toast) => toast.dedupeKey == key)) {
      return;
    }

    _pending.add(
      ToastItem(
        id: 'toast-${_nextId++}',
        type: type,
        message: message,
        dedupeKey: key,
        duration: duration,
      ),
    );
    while (length > maxQueued && _pending.isNotEmpty) {
      _pending.removeAt(0);
    }
    _activateNext();
  }

  void dismiss(String id) {
    if (_active?.id == id) {
      _timer?.cancel();
      _timer = null;
      _active = null;
      _activateNext();
      return;
    }
    final before = _pending.length;
    _pending.removeWhere((toast) => toast.id == id);
    if (_pending.length != before) _onChange();
  }

  void _activateNext() {
    if (_active != null) {
      _onChange();
      return;
    }
    if (_pending.isEmpty) {
      _onChange();
      return;
    }
    final next = _pending.removeAt(0);
    _active = next;
    _timer = Timer(next.duration, () => dismiss(next.id));
    _onChange();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _active = null;
    _pending.clear();
  }
}
