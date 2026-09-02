import 'package:app_result/app_result.dart';

import '../entities/sample_chunk.dart';
import '../entities/sample_item.dart';

abstract class SampleRepository {
  static const pageSize = 10;

  Future<Result<SampleChunk>> getSample(
      {int page = 1, bool forceNetwork = false});

  Future<Result<SampleItem>> createItem({required String title});

  Future<Result<SampleItem>> updateItem({
    required String id,
    String? title,
    bool? done,
  });

  Future<Result<SampleItem>> deleteItem({required String id});
}
