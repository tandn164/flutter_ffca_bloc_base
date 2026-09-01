import 'package:local_storage/local_storage.dart';
import 'package:onboarding_domain/onboarding_domain.dart';

class StoredOnboardingRepository implements OnboardingRepository {
  const StoredOnboardingRepository(this.store,
      {this.keyPrefix = 'onboarding.'});

  final KeyValueStore store;
  final String keyPrefix;

  String _key(String flowId) => '$keyPrefix$flowId';

  @override
  Future<bool> isCompleted(String flowId) async =>
      await store.readString(_key(flowId)) == 'completed';

  @override
  Future<void> complete(String flowId) =>
      store.writeString(_key(flowId), 'completed');

  @override
  Future<void> reset(String flowId) => store.remove(_key(flowId));
}
