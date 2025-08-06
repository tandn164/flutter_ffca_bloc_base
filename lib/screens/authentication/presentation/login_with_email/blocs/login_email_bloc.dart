import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';

import '../models/models.dart';
import '../../../domain/entities/login_param.dart';
import '../../../domain/usecase/login_usecase.dart';
import '../../../../../core/error/exceptions.dart';

part 'login_email_event.dart';
part 'login_email_state.dart';

class LoginEmailBloc extends Bloc<LoginEmailEvent, LoginEmailState> {
  LoginEmailBloc({
    required LoginUseCase loginUseCase,
  })  : _loginUseCase = loginUseCase,
        super(const LoginEmailState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  final LoginUseCase _loginUseCase;

  _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginEmailState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        status: LoginEmailStatus.emailEditing,
        email: email,
        isValid: Formz.validate([state.password, email]),
      ),
    );
  }

  _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginEmailState> emit,
  ) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        status: LoginEmailStatus.passwordEditing,
        password: password,
        isValid: Formz.validate([password, state.email]),
      ),
    );
  }

  _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginEmailState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: LoginEmailStatus.loginProcess));
      try {
        var result = await _loginUseCase(LoginParams(
            email: state.email.value, password: state.password.value));
        await result.fold(
            (l) async => emit(state.copyWith(
                status: LoginEmailStatus.loginFail,
                errorMessage: l.message)),
                (r) async => emit(state.copyWith(status: LoginEmailStatus.loginSuccess))
        );
      } on ServerException catch (error) {
        emit(state.copyWith(
            status: LoginEmailStatus.loginFail, errorMessage: error.message));
      }
    }
  }
}
