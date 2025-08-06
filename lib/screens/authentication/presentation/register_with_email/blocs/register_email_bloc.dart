import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';

import '../models/models.dart';
import '../../login_with_email/models/email.dart';
import '../../login_with_email/models/password.dart';
import '../../../domain/entities/register_email_params.dart';
import '../../../domain/usecase/register_email_usecase.dart';
import '../../../../../core/error/exceptions.dart';

part 'register_email_event.dart';
part 'register_email_state.dart';

class RegisterEmailBloc extends Bloc<RegisterEmailEvent, RegisterEmailState> {
  RegisterEmailBloc(
      {required this.registerEmailUseCase})
      : super(const RegisterEmailState()) {
    on<UsernameChanged>(_onUsernameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  final RegisterEmailUseCase registerEmailUseCase;

  _onUsernameChanged(
    UsernameChanged event,
    Emitter<RegisterEmailState> emit,
  ) {
    final username = Username.dirty(event.username);
    emit(
      state.copyWith(
        username: username,
        isInfoValid: Formz.validate([username, state.password, state.email]),
      ),
    );
  }

  _onEmailChanged(
    EmailChanged event,
    Emitter<RegisterEmailState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isInfoValid: Formz.validate([state.username, email, state.password]),
      ),
    );
  }

  _onPasswordChanged(
    PasswordChanged event,
    Emitter<RegisterEmailState> emit,
  ) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
        isInfoValid: Formz.validate([state.username, state.email, password]),
      ),
    );
  }

  _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterEmailState> emit,
  ) async {
    emit(state.copyWith(status: RegisterEmailStatus.registerProcess));
    try {
      var result = await registerEmailUseCase(RegisterEmailParams(
          username: state.username.value,
          email: state.email.value,
          password: state.password.value));
      await result.fold(
              (l) async => emit(state.copyWith(
              status: RegisterEmailStatus.registerFail,
              errorMessage: l.message)), (r) async => emit(
          state.copyWith(status: RegisterEmailStatus.registerSuccess)));
    } on ServerException catch (error) {
      emit(state.copyWith(
          status: RegisterEmailStatus.registerFail,
          errorMessage: error.message));
    }
  }
}
