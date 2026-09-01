import 'package:app_result/app_result.dart';

import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Result<UserProfile>> me();
  Future<Result<UserProfile>> update({required String name});
}
