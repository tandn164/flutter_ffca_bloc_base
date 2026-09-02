import 'package:api_client/api_client.dart';
import 'package:app_result/app_result.dart';
import 'package:sample_domain/sample_domain.dart';

import '../api/sample_api.dart';
import '../dtos/sample_item_dto.dart';

/// Sample reads go through [DataGateway] so cache/TTL/offline follow [RequestPolicy].
/// Path comes from [SampleApi] (Chopper).
class SampleRepositoryImpl implements SampleRepository {
  SampleRepositoryImpl({
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
  Future<Result<SampleChunk>> getSample(
      {int page = 1, bool forceNetwork = false}) {
    return gateway.read(
      path: SampleApi.samplePath,
      query: {
        'page': '$page',
        'limit': '${SampleRepository.pageSize}',
      },
      policy: RequestPolicy(
        read: forceNetwork ? ReadStrategy.networkOnly : policy.read,
        ttl: policy.ttl,
        retryOnReconnect: policy.retryOnReconnect,
        idempotencyKey: policy.idempotencyKey,
      ),
      decode: (json) {
        final map = json as Map<String, dynamic>;
        return SampleChunk(
          items: [
            for (final dto in SampleItemDto.listFromJson(json)) dto.toEntity(),
          ],
          hasMore: map['hasMore'] as bool? ?? false,
        );
      },
    );
  }

  @override
  Future<Result<SampleItem>> createItem({required String title}) {
    return gateway.write(
      request: ApiRequest(
        method: 'POST',
        path: SampleApi.samplePath,
        body: {'title': title},
        policy: RequestPolicy(
          retryOnReconnect: true,
          idempotencyKey: operationId(),
        ),
      ),
      decode: _item,
      invalidatePaths: [SampleApi.samplePath],
    );
  }

  @override
  Future<Result<SampleItem>> updateItem({
    required String id,
    String? title,
    bool? done,
  }) {
    return gateway.write(
      request: ApiRequest(
        method: 'PATCH',
        path: SampleApi.itemPath(id),
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
      invalidatePaths: [SampleApi.samplePath],
    );
  }

  @override
  Future<Result<SampleItem>> deleteItem({required String id}) {
    return gateway.write(
      request: ApiRequest(
        method: 'DELETE',
        path: SampleApi.itemPath(id),
        policy: RequestPolicy(
          retryOnReconnect: true,
          idempotencyKey: operationId(),
        ),
      ),
      decode: _item,
      invalidatePaths: [SampleApi.samplePath],
    );
  }

  static SampleItem _item(Object json) {
    return SampleItemDto.fromJson(json as Map<String, dynamic>).toEntity();
  }
}

var _operationSequence = 0;

String _nextOperationId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  return 'sample-$timestamp-${_operationSequence++}';
}
