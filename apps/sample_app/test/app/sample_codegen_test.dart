import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sample_domain/sample_domain.dart';
import '../../lib/app/features/sample_feature.dart';

void main() {
  test('sample DI is opt-in and isolated to the supplied container', () async {
    final enabled = GetIt.asNewInstance();
    final disabled = GetIt.asNewInstance();
    addTearDown(enabled.reset);
    addTearDown(disabled.reset);
    expect(disabled.isRegistered<SampleRepository>(), isFalse);
    registerSampleDependencies(enabled);
    expect(enabled<SampleRepository>(), same(enabled<SampleRepository>()));
    expect(enabled<GetSample>(), isA<GetSample>());
    expect(enabled<CreateSampleItem>(), isA<CreateSampleItem>());
    expect(enabled<UpdateSampleItem>(), isA<UpdateSampleItem>());
    expect(enabled<DeleteSampleItem>(), isA<DeleteSampleItem>());
    expect(disabled.isRegistered<SampleRepository>(), isFalse);
  });

  test('typed sample route agrees with the shell registration', () {
    final container = GetIt.asNewInstance();
    expect(const SampleRoute().location, '/sample');
    expect(createSampleBranch(container).routes, hasLength(1));
  });
}
