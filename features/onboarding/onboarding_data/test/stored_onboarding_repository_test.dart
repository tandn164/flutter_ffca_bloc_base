import 'package:local_storage/local_storage.dart';
import 'package:onboarding_data/onboarding_data.dart';
import 'package:test/test.dart';

void main() {
  test('persists completion by flow id', () async {
    final repository = StoredOnboardingRepository(MemoryKeyValueStore());
    expect(await repository.isCompleted('main-v1'), isFalse);
    await repository.complete('main-v1');
    expect(await repository.isCompleted('main-v1'), isTrue);
    expect(await repository.isCompleted('feature-v1'), isFalse);
  });
}
