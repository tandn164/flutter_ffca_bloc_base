import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../models/auth_status.dart';
import '../../../../../core/usecases/usecase.dart';
// Removed firebase notification service - moved to composable_auth package
import '../../../../authentication/domain/usecase/logout_usecase.dart';
import '../../../../authentication/domain/usecase/token_usecase.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final TokenUseCase checkTokenUseCase;
  final LogoutUseCase logoutUseCase;

  AuthenticationBloc({
    required this.checkTokenUseCase,
    required this.logoutUseCase,
  }) : super(const AuthenticationState.initial()) {
    on<CheckAuthenticateEvent>(_onCheckAuth);
    on<LogoutEvent>(_onLogout);
    on<TokenExpiredEvent>(_onTokenExpired);
    on<AttachDeviceEvent>(_onAttachDevice);
    on<DetachDeviceEvent>(_onDetachDevice);
  }

  Future<void> _onCheckAuth(CheckAuthenticateEvent event, Emitter<AuthenticationState> emit) async {
    var result = await checkTokenUseCase(NoParams());
    result.fold((l) => emit(state.copyWith(authStatus: AuthStatus.guest)),
        (r) => emit(state.copyWith(authStatus: AuthStatus.user)));
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthenticationState> emit) async {
    var result = await logoutUseCase(NoParams());
    result.fold((l) => emit(state.copyWith(authStatus: AuthStatus.user)),
        (r) => emit(state.copyWith(authStatus: AuthStatus.guest)));
  }

  Future<void> _onTokenExpired(TokenExpiredEvent event, Emitter<AuthenticationState> emit) async {
    // Clear token and set auth status to guest when token expires
    emit(state.copyWith(authStatus: AuthStatus.guest));
  }

  Future<void> _onAttachDevice(AttachDeviceEvent event, Emitter<AuthenticationState> emit) async {
    // Device attachment is now handled by composable_auth AuthService
    // This event can be removed or refactored to use AuthService
  }

  Future<void> _onDetachDevice(DetachDeviceEvent event, Emitter<AuthenticationState> emit) async {
    // Device detachment is now handled by composable_auth AuthService  
    // This event can be removed or refactored to use AuthService
  }
}
