import 'package:app_result/app_result.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements AuthRepository {
  _Repo(this.result);
  Result<TokenPair> result;

  @override
  Future<Result<TokenPair>> login({required String email, required String password}) async =>
      result;

  @override
  Future<Result<TokenPair>> signup({
    required String email,
    required String password,
    required String name,
  }) async =>
      result;
}

void main() {
  test('LoginBloc calls onAuthenticated with tokens from UseCase', () async {
    TokenPair? received;
    final bloc = LoginBloc(
      login: LoginUseCase(
        _Repo(const Ok(TokenPair(accessToken: 'a', refreshToken: 'r'))),
      ),
      onAuthenticated: (tokens) async => received = tokens,
    );

    bloc.add(const LoginSubmitted(email: 'a@b.c', password: 'x'));
    await pumpEventQueue();

    expect(received?.accessToken, 'a');
    expect(received?.refreshToken, 'r');
    expect(bloc.state.busy, isFalse);
    expect(bloc.state.notice?.message, 'Signed in');
    expect(bloc.state.notice?.kind, AuthNoticeKind.success);
    await bloc.close();
  });

  test('LoginBloc does not authenticate on failure; busy is cleared', () async {
    var authenticated = false;
    final bloc = LoginBloc(
      login: LoginUseCase(_Repo(const Err(AuthFailure('bad')))),
      onAuthenticated: (_) async => authenticated = true,
    );

    bloc.add(const LoginSubmitted(email: 'a@b.c', password: 'x'));
    await pumpEventQueue();

    expect(authenticated, isFalse);
    expect(bloc.state.busy, isFalse);
    expect(bloc.state.notice?.message, 'bad');
    expect(bloc.state.notice?.kind, AuthNoticeKind.error);
    await bloc.close();
  });
}
