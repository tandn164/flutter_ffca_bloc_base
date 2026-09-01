import 'package:api_client/api_client.dart';
import 'package:app_result/app_result.dart';
import 'package:feed_domain/feed_domain.dart';

import '../api/feed_api.dart';
import '../dtos/feed_item_dto.dart';

/// Feed reads go through [DataGateway] so cache/TTL/offline follow [RequestPolicy].
/// Path comes from [FeedApi] (Chopper).
class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({
    required this.gateway,
    this.policy = const RequestPolicy(
      read: ReadStrategy.cacheFirst,
      ttl: Duration(minutes: 2),
    ),
    String Function()? operationId,
  }) : operationId = operationId ?? _nextOperationId;

  final DataGateway gateway;
  final RequestPolicy policy;
  final String Function() operationId;

  @override
  Future<Result<FeedChunk>> getFeed({int page = 1, bool forceNetwork = false}) {
    return gateway.read(
      path: FeedApi.feedPath,
      query: {
        'page': '$page',
        'limit': '${FeedRepository.pageSize}',
      },
      policy: RequestPolicy(
        read: forceNetwork ? ReadStrategy.networkOnly : policy.read,
        ttl: policy.ttl,
        retryOnReconnect: policy.retryOnReconnect,
        idempotencyKey: policy.idempotencyKey,
      ),
      decode: (json) {
        final map = json as Map<String, dynamic>;
        return FeedChunk(
          items: [
            for (final dto in FeedItemDto.listFromJson(json)) dto.toEntity(),
          ],
          hasMore: map['hasMore'] as bool? ?? false,
        );
      },
    );
  }

  @override
  Future<Result<FeedItem>> createItem({required String title}) {
    return gateway.write(
      request: ApiRequest(
        method: 'POST',
        path: FeedApi.feedPath,
        body: {'title': title},
        policy: RequestPolicy(
          retryOnReconnect: true,
          idempotencyKey: operationId(),
        ),
      ),
      decode: _item,
      invalidatePaths: [FeedApi.feedPath],
    );
  }

  @override
  Future<Result<FeedItem>> updateItem({
    required String id,
    String? title,
    bool? done,
  }) {
    return gateway.write(
      request: ApiRequest(
        method: 'PATCH',
        path: FeedApi.itemPath(id),
        body: {
          if (title != null) 'title': title,
          if (done != null) 'done': done,
        },
        policy: RequestPolicy(
          retryOnReconnect: true,
          idempotencyKey: operationId(),
        ),
      ),
      decode: _item,
      invalidatePaths: [FeedApi.feedPath],
    );
  }

  @override
  Future<Result<FeedItem>> deleteItem({required String id}) {
    return gateway.write(
      request: ApiRequest(
        method: 'DELETE',
        path: FeedApi.itemPath(id),
        policy: RequestPolicy(
          retryOnReconnect: true,
          idempotencyKey: operationId(),
        ),
      ),
      decode: _item,
      invalidatePaths: [FeedApi.feedPath],
    );
  }

  static FeedItem _item(Object json) {
    return FeedItemDto.fromJson(json as Map<String, dynamic>).toEntity();
  }
}

var _operationSequence = 0;

String _nextOperationId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  return 'feed-$timestamp-${_operationSequence++}';
}
