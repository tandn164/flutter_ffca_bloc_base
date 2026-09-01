import 'package:app_result/app_result.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:test/test.dart';

class _Repo implements AuthRepository {
  @override
  Future<Result<TokenPair>> login({required String email, required String password}) async {
    return const Ok(TokenPair(accessToken: 'a', refreshToken: 'r'));
  }

  @override
  Future<Result<TokenPair>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    return const Ok(TokenPair(accessToken: 'a', refreshToken: 'r'));
  }
}

void main() {
  test('LoginUseCase returns tokens and does not own Session', () async {
    final repo = _Repo();
    final result = await LoginUseCase(repo).execute(
      email: 'a@b.c',
      password: 'x',
    );
    expect(result.valueOrNull?.accessToken, 'a');
    expect(result.valueOrNull?.refreshToken, 'r');
  });
}
