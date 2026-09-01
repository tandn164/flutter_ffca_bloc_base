import 'package:auth_domain/auth_domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_notice.dart';

export 'auth_notice.dart';

sealed class SignupEvent extends Equatable {
  const SignupEvent();
  @override
  List<Object?> get props => [];
}

class SignupSubmitted extends SignupEvent {
  const SignupSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}

class SignupState extends Equatable {
  const SignupState({this.busy = false, this.notice});

  final bool busy;
  final AuthNotice? notice;

  @override
  List<Object?> get props => [busy, notice];
}

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc({
    required SignupUseCase signup,
    required Future<void> Function(TokenPair tokens) onAuthenticated,
  })  : _signup = signup,
        _onAuthenticated = onAuthenticated,
        super(const SignupState()) {
    on<SignupSubmitted>(_onSubmit);
  }

  final SignupUseCase _signup;
  final Future<void> Function(TokenPair tokens) _onAuthenticated;
  int _noticeId = 0;

  Future<void> _onSubmit(
      SignupSubmitted event, Emitter<SignupState> emit) async {
    emit(const SignupState(busy: true));
    try {
      final result = await _signup.execute(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      await result.fold<Future<void>>(
        ok: (tokens) async {
          await _onAuthenticated(tokens);
          emit(SignupState(
            notice: AuthNotice(
              message: 'Account created',
              kind: AuthNoticeKind.success,
              id: ++_noticeId,
            ),
          ));
        },
        err: (f) async {
          emit(SignupState(
            notice: AuthNotice(
              message: f.message,
              kind: AuthNoticeKind.error,
              id: ++_noticeId,
            ),
          ));
        },
      );
    } catch (e) {
      emit(SignupState(
        notice: AuthNotice(
          message: e.toString(),
          kind: AuthNoticeKind.error,
          id: ++_noticeId,
        ),
      ));
    }
  }
}
