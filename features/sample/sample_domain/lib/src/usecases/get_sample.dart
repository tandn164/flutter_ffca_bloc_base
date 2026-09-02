import 'package:app_result/app_result.dart';

import '../entities/sample_chunk.dart';
import '../repositories/sample_repository.dart';

class GetSample {
  GetSample(this._repository);

  final SampleRepository _repository;

  Future<Result<SampleChunk>> execute(
      {int page = 1, bool forceNetwork = false}) {
    return _repository.getSample(page: page, forceNetwork: forceNetwork);
  }
}
