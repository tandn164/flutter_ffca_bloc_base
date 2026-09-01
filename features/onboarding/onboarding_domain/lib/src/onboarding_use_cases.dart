import 'onboarding_repository.dart';

class ShouldShowOnboarding {
  const ShouldShowOnboarding(this.repository);
  final OnboardingRepository repository;

  Future<bool> call(String flowId) async =>
      !await repository.isCompleted(flowId);
}

class CompleteOnboarding {
  const CompleteOnboarding(this.repository);
  final OnboardingRepository repository;

  Future<void> call(String flowId) => repository.complete(flowId);
}
