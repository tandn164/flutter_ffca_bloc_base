import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:local_storage/local_storage.dart';

import 'sync_event.dart';

class PersistentOutbox implements Outbox {
  PersistentOutbox({
    required this.store,
    this.storageKey = 'offline_sync.outbox.v1',
    this.deadLetterKey = 'offline_sync.dead_letters.v1',
    this.maxAttempts = 6,
    this.baseDelay = const Duration(seconds: 2),
    this.onEvent,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final KeyValueStore store;
  final String storageKey;
  final String deadLetterKey;
  final int maxAttempts;
  final Duration baseDelay;
  final void Function(SyncEvent event)? onEvent;
  final DateTime Function() now;

  final List<_StoredOperation> _pending = [];
  final List<_StoredOperation> _deadLetters = [];
  bool _initialized = false;
  bool _draining = false;
  int _nextId = 0;

  @override
  int get length => _pending.length;
  int get deadLetterCount => _deadLetters.length;

  @override
  DateTime? get nextRetryAt =>
      _pending.isEmpty ? null : _pending.first.nextAttemptAt;

  Future<void> initialize() async {
    if (_initialized) return;
    _pending.addAll(await _read(storageKey));
    _deadLetters.addAll(await _read(deadLetterKey));
    _nextId = _pending.length + _deadLetters.length;
    _initialized = true;
  }

  @override
  Future<void> enqueue(ApiRequest request) async {
    await initialize();
    if (!request.policy.isWriteRetryable) {
      throw ArgumentError(
        'Only retryOnReconnect requests with an idempotency key can be queued.',
      );
    }
    _ensureJsonEncodable(request.body);
    final operation = _StoredOperation(
      id: '${now().microsecondsSinceEpoch}-${_nextId++}',
      request: request,
      enqueuedAt: now(),
    );
    _pending.add(operation);
    await _persistPending();
    onEvent?.call(
      SyncEvent(
        type: SyncEventType.queued,
        operationId: operation.id,
        path: request.path,
      ),
    );
  }

  @override
  Future<void> drain(
    Future<ApiResponse> Function(ApiRequest request) send,
  ) async {
    await initialize();
    if (_draining) return;
    _draining = true;
    try {
      while (_pending.isNotEmpty) {
        final operation = _pending.first;
        final retryAt = operation.nextAttemptAt;
        if (retryAt != null && retryAt.isAfter(now())) return;

        try {
          final response = await send(operation.request);
          if (response.isOk) {
            _pending.removeAt(0);
            await _persistPending();
            _emit(SyncEventType.sent, operation);
            continue;
          }
          if (_isPermanent(response.statusCode)) {
            await _moveToDeadLetter(
              operation,
              'HTTP ${response.statusCode}',
            );
            continue;
          }
          await _scheduleRetry(operation, 'HTTP ${response.statusCode}');
          return;
        } catch (error) {
          await _scheduleRetry(operation, error.runtimeType.toString());
          return;
        }
      }
    } finally {
      _draining = false;
    }
  }

  Future<void> retryDeadLetters() async {
    await initialize();
    if (_deadLetters.isEmpty) return;
    for (final operation in _deadLetters) {
      _pending.add(
        operation.copyWith(attempts: 0, clearNextAttemptAt: true),
      );
    }
    _deadLetters.clear();
    await Future.wait([_persistPending(), _persistDeadLetters()]);
  }

  Future<void> clearDeadLetters() async {
    await initialize();
    _deadLetters.clear();
    await _persistDeadLetters();
  }

  bool _isPermanent(int statusCode) =>
      statusCode >= 400 &&
      statusCode < 500 &&
      statusCode != 408 &&
      statusCode != 429;

  Future<void> _scheduleRetry(
    _StoredOperation operation,
    String message,
  ) async {
    final attempts = operation.attempts + 1;
    if (attempts >= maxAttempts) {
      await _moveToDeadLetter(
        operation.copyWith(attempts: attempts),
        message,
      );
      return;
    }
    final exponent = attempts - 1;
    final multiplier = 1 << exponent.clamp(0, 10).toInt();
    final updated = operation.copyWith(
      attempts: attempts,
      nextAttemptAt: now().add(baseDelay * multiplier),
      lastError: message,
    );
    _pending[0] = updated;
    await _persistPending();
    _emit(SyncEventType.retryScheduled, updated, message);
  }

  Future<void> _moveToDeadLetter(
    _StoredOperation operation,
    String message,
  ) async {
    _pending.removeAt(0);
    final failed = operation.copyWith(lastError: message);
    _deadLetters.add(failed);
    await Future.wait([_persistPending(), _persistDeadLetters()]);
    _emit(SyncEventType.permanentlyFailed, failed, message);
  }

  void _emit(
    SyncEventType type,
    _StoredOperation operation, [
    String? message,
  ]) {
    onEvent?.call(
      SyncEvent(
        type: type,
        operationId: operation.id,
        path: operation.request.path,
        attempt: operation.attempts,
        message: message,
      ),
    );
  }

  Future<List<_StoredOperation>> _read(String key) async {
    final raw = await store.readString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in list)
          _StoredOperation.fromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      return [];
    }
  }

  Future<void> _persistPending() =>
      store.writeString(storageKey, jsonEncode(_pending));
  Future<void> _persistDeadLetters() =>
      store.writeString(deadLetterKey, jsonEncode(_deadLetters));

  static void _ensureJsonEncodable(Object? body) {
    try {
      jsonEncode(body);
    } catch (_) {
      throw ArgumentError('Queued request bodies must be JSON encodable.');
    }
  }
}

class _StoredOperation {
  const _StoredOperation({
    required this.id,
    required this.request,
    required this.enqueuedAt,
    this.attempts = 0,
    this.nextAttemptAt,
    this.lastError,
  });

  final String id;
  final ApiRequest request;
  final DateTime enqueuedAt;
  final int attempts;
  final DateTime? nextAttemptAt;
  final String? lastError;

  _StoredOperation copyWith({
    int? attempts,
    DateTime? nextAttemptAt,
    bool clearNextAttemptAt = false,
    String? lastError,
  }) {
    return _StoredOperation(
      id: id,
      request: request,
      enqueuedAt: enqueuedAt,
      attempts: attempts ?? this.attempts,
      nextAttemptAt:
          clearNextAttemptAt ? null : nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'request': _requestToJson(request),
        'enqueuedAt': enqueuedAt.toIso8601String(),
        'attempts': attempts,
        'nextAttemptAt': nextAttemptAt?.toIso8601String(),
        'lastError': lastError,
      };

  factory _StoredOperation.fromJson(Map<String, dynamic> json) {
    return _StoredOperation(
      id: json['id'] as String,
      request: _requestFromJson(json['request'] as Map<String, dynamic>),
      enqueuedAt: DateTime.parse(json['enqueuedAt'] as String),
      attempts: json['attempts'] as int? ?? 0,
      nextAttemptAt: json['nextAttemptAt'] == null
          ? null
          : DateTime.parse(json['nextAttemptAt'] as String),
      lastError: json['lastError'] as String?,
    );
  }
}

Map<String, dynamic> _requestToJson(ApiRequest request) => {
      'method': request.method,
      'path': request.path,
      'query': request.query,
      'headers': request.headers,
      'body': request.body,
      'policy': {
        'read': request.policy.read.name,
        'ttlMs': request.policy.ttl.inMilliseconds,
        'retryOnReconnect': request.policy.retryOnReconnect,
        'idempotencyKey': request.policy.idempotencyKey,
      },
    };

ApiRequest _requestFromJson(Map<String, dynamic> json) {
  final policy = json['policy'] as Map<String, dynamic>;
  return ApiRequest(
    method: json['method'] as String,
    path: json['path'] as String,
    query: Map<String, String>.from(json['query'] as Map),
    headers: Map<String, String>.from(json['headers'] as Map),
    body: json['body'],
    policy: RequestPolicy(
      read: ReadStrategy.values.byName(policy['read'] as String),
      ttl: Duration(milliseconds: policy['ttlMs'] as int),
      retryOnReconnect: policy['retryOnReconnect'] as bool,
      idempotencyKey: policy['idempotencyKey'] as String?,
    ),
  );
}
