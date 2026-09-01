import 'package:app_result/app_result.dart';

import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  GetProfile(this._repository);

  final ProfileRepository _repository;

  Future<Result<UserProfile>> execute() => _repository.me();
}

class UpdateProfile {
  UpdateProfile(this._repository);

  final ProfileRepository _repository;

  Future<Result<UserProfile>> execute({required String name}) {
    return _repository.update(name: name);
  }
}
