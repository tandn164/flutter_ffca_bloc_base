import 'package:app_result/app_result.dart';
import 'package:profile_domain/profile_domain.dart';
import 'package:test/test.dart';

class _Repo implements ProfileRepository {
  @override
  Future<Result<UserProfile>> me() async =>
      const Ok(UserProfile(id: '1', name: 'A', email: 'a@b.c'));

  @override
  Future<Result<UserProfile>> update({required String name}) async =>
      Ok(UserProfile(id: '1', name: name, email: 'a@b.c'));
}

void main() {
  test('GetProfile returns repository profile', () async {
    final result = await GetProfile(_Repo()).execute();
    expect(result.valueOrNull?.name, 'A');
  });
}
