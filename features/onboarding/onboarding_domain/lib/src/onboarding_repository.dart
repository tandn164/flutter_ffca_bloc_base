abstract class OnboardingRepository {
  Future<bool> isCompleted(String flowId);
  Future<void> complete(String flowId);
  Future<void> reset(String flowId);
}
