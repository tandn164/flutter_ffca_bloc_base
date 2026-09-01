import 'package:app_result/app_result.dart';

import '../api/profile_api.dart';
import '../chopper_result.dart';
import '../dtos/user_profile_dto.dart';

class ProfileNetworkDs {
  ProfileNetworkDs(this._api);

  final ProfileApi _api;

  Future<Result<UserProfileDto>> me() async {
    try {
      final response = await _api.me();
      return resultFromChopper(response, UserProfileDto.fromJson);
    } catch (_) {
      return const Err(NetworkFailure());
    }
  }

  Future<Result<UserProfileDto>> updateMe({required String name}) async {
    try {
      final response = await _api.updateMe({'name': name});
      return resultFromChopper(response, UserProfileDto.fromJson);
    } catch (_) {
      return const Err(NetworkFailure());
    }
  }
}
