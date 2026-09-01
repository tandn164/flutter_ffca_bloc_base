import 'dart:async';

import 'package:app_result/app_result.dart';

import 'api_client.dart';
import 'api_types.dart';
import 'cache_store.dart';
import 'connectivity_hint.dart';
import 'outbox.dart';
import 'request_policy.dart';
import 'safe_decode.dart';

/// Policy engine for reads/writes.
///
/// [cache] and [outbox] are optional (FR-09). When omitted, every read hits
/// the network and writes are never queued.
class DataGateway {
  DataGateway({
    required this.client,
    required this.connectivity,
    this.cache,
    this.outbox,
    this.userId = 'anon',
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final ApiClient client;
  final CacheStore? cache;
  final ConnectivityHint connectivity;
  final Outbox? outbox;
  final String userId;
  final DateTime Function() now;

  final Map<String, Future<Result<dynamic>>> _inflight = {};

  Future<Result<T>> read<T>({
    required String path,
    required T Function(Object json) decode,
    RequestPolicy policy = const RequestPolicy(),
    Map<String, String> query = const {},
    void Function(Result<T> refreshed)? onRevalidate,
  }) async {
    final key = cacheKey(
      userId: userId,
      method: 'GET',
      path: path,
      query: query,
    );
    final cached = cache?.get(key);
    final offline = connectivity.isSureOffline;
    final strategy = cache == null ? ReadStrategy.networkOnly : policy.read;

    switch (strategy) {
      case ReadStrategy.networkOnly:
        if (offline) return const Err(NetworkFailure());
        return _fetchStore(path, query, decode, policy, key);
      case ReadStrategy.cacheFirst:
        if (cached != null && (cached.isFresh(now()) || offline)) {
          return safeDecode(cached.body, decode);
        }
        if (offline) return const Err(NetworkFailure());
        return _fetchStore(path, query, decode, policy, key);
      case ReadStrategy.staleWhileRevalidate:
        if (cached != null) {
          if (!offline) {
            final pending = _fetchStore(path, query, decode, policy, key);
            if (onRevalidate != null) {
              unawaited(pending.then(onRevalidate));
            }
          }
          return safeDecode(cached.body, decode);
        }
        if (offline) return const Err(NetworkFailure());
        return _fetchStore(path, query, decode, policy, key);
      case ReadStrategy.networkFirst:
        if (offline) {
          if (cached != null) return safeDecode(cached.body, decode);
          return const Err(NetworkFailure());
        }
        final remote = await _fetchStore(path, query, decode, policy, key);
        if (remote.failureOrNull is NetworkFailure && cached != null) {
          return safeDecode(cached.body, decode);
        }
        return remote;
    }
  }

  Future<Result<T>> _fetchStore<T>(
    String path,
    Map<String, String> query,
    T Function(Object json) decode,
    RequestPolicy policy,
    String key,
  ) {
    final existing = _inflight[key];
    if (existing != null) {
      return existing.then(_cast<T>);
    }
    final typed = _doFetch<T>(path, query, decode, policy, key);
    final stored = typed.then<Result<dynamic>>((result) => result);
    _inflight[key] = stored;
    return typed.whenComplete(() {
      if (identical(_inflight[key], stored)) {
        _inflight.remove(key);
      }
    });
  }

  Future<Result<T>> _doFetch<T>(
    String path,
    Map<String, String> query,
    T Function(Object json) decode,
    RequestPolicy policy,
    String key,
  ) async {
    final request = ApiRequest(
      method: 'GET',
      path: path,
      query: query,
      policy: policy,
    );
    try {
      final response = await _sendGet(request);
      if (!response.isOk) {
        if (response.statusCode == 401) {
          if (connectivity.isSureOffline) return const Err(NetworkFailure());
          return const Err(AuthFailure());
        }
        return Err(ServerFailure('HTTP ${response.statusCode}'));
      }
      final decoded = safeDecode(response.body, decode);
      if (decoded.isOk) {
        cache?.put(
          key,
          CacheEntry(body: response.body, storedAt: now(), ttl: policy.ttl),
        );
      }
      return decoded;
    } catch (_) {
      return const Err(NetworkFailure());
    }
  }

  /// One extra GET attempt on transport failure. Never retries 4xx or decode.
  Future<ApiResponse> _sendGet(ApiRequest request) async {
    try {
      return await client.send(request);
    } catch (_) {
      return await client.send(request);
    }
  }

  Future<Result<T>> write<T>({
    required ApiRequest request,
    required T Function(Object json) decode,
    Iterable<String> invalidatePaths = const [],
  }) async {
    final offline = connectivity.isSureOffline;
    if (offline) {
      if (request.policy.isWriteRetryable) {
        await outbox?.enqueue(request);
        return const Err(NetworkFailure('Queued until online'));
      }
      return const Err(NetworkFailure());
    }
    try {
      final response = await client.send(request);
      if (!response.isOk) {
        if (response.statusCode == 401) {
          if (connectivity.isSureOffline) return const Err(NetworkFailure());
          return const Err(AuthFailure());
        }
        return Err(ServerFailure('HTTP ${response.statusCode}'));
      }
      final decoded = safeDecode(response.body, decode);
      if (decoded.isOk) {
        _invalidate(invalidatePaths);
      }
      return decoded;
    } catch (_) {
      if (request.policy.isWriteRetryable) {
        await outbox?.enqueue(request);
      }
      return const Err(NetworkFailure());
    }
  }

  void _invalidate(Iterable<String> paths) {
    final store = cache;
    if (store == null) return;
    for (final path in paths) {
      store.invalidateWhere((key) => key.contains('|$path'));
    }
  }
}

Result<T> _cast<T>(Result<dynamic> result) {
  return result.fold(
    ok: (value) => Ok<T>(value as T),
    err: (failure) => Err<T>(failure),
  );
}
