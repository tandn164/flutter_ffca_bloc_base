import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:sample_data/sample_data.dart';
import 'package:sample_domain/sample_domain.dart';

import 'sample_di.config.dart';

// This initializer registers only the explicitly selected sample feature.
@InjectableInit(
  initializerName: 'initSampleFeature',
  generateForDir: ['lib/app/features/sample'],
)
void configureSampleDependencies(GetIt container) =>
    container.initSampleFeature();

@module
abstract class SampleModule {
  @lazySingleton
  SampleRepository repository() => LocalSampleRepository();

  @lazySingleton
  GetSample getSample(SampleRepository repository) => GetSample(repository);

  @lazySingleton
  CreateSampleItem createItem(SampleRepository repository) =>
      CreateSampleItem(repository);

  @lazySingleton
  UpdateSampleItem updateItem(SampleRepository repository) =>
      UpdateSampleItem(repository);

  @lazySingleton
  DeleteSampleItem deleteItem(SampleRepository repository) =>
      DeleteSampleItem(repository);
}
