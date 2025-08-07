import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../../core/enums/auth_status.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../authentication/domain/usecase/logout_usecase.dart';
import '../../../../authentication/domain/usecase/token_usecase.dart';
import '../../../../../generated/l10n/l10n.dart';

part 'global_event.dart';
part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  final TokenUseCase checkTokenUseCase;
  final LogoutUseCase logoutUseCase;

  GlobalBloc({
    required this.checkTokenUseCase,
    required this.logoutUseCase,
  }) : super(const GlobalState.initial()) {
    on<CheckAuthenticateEvent>(_onCheckAuth);
    on<LogoutEvent>(_onLogout);
    on<ChangeTabEvent>(_onChangeTab);
    on<GetDeviceInfoEvent>(_onGetDeviceInfo);
    on<InitialLocaleEvent>(_onInitialLocale);
    on<ChangeLocaleEvent>(_onChangeLocale);
    on<TokenExpiredEvent>(_onTokenExpired);
  }

  Future<void> _onCheckAuth(CheckAuthenticateEvent event, Emitter<GlobalState> emit) async {
    var result = await checkTokenUseCase(NoParams());
    result.fold((l) => emit(state.copyWith(authStatus: AuthStatus.guest)),
        (r) => emit(state.copyWith(authStatus: AuthStatus.user)));
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<GlobalState> emit) async {
    var result = await logoutUseCase(NoParams());
    result.fold((l) => emit(state.copyWith(authStatus: AuthStatus.user)),
        (r) => emit(state.copyWith(authStatus: AuthStatus.guest)));
  }

  void _onChangeTab(ChangeTabEvent event, Emitter<GlobalState> emit) {
    emit(state.copyWith(tabBarIndex: event.index));
  }

  Future<void> _onGetDeviceInfo(GetDeviceInfoEvent event, Emitter<GlobalState> emit) async {
    if (Platform.isIOS) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.deviceInfo;
      final iosOsVersion =
          (deviceInfo as IosDeviceInfo).systemVersion.split('.').first;
      emit(state.copyWith(isIos: true, iosVersion: double.parse(iosOsVersion)));
    } else {
      emit(state.copyWith(isIos: false, iosVersion: 0));
    }
  }

  void _onInitialLocale(InitialLocaleEvent event, Emitter<GlobalState> emit) {
    Locale deviceLocale = PlatformDispatcher.instance.locale;
    List<Locale> supportedLocales = S.supportedLocales;
    Locale initialLocale = supportedLocales.contains(deviceLocale) ? deviceLocale : const Locale('en');
    emit(state.copyWith(locale: initialLocale));
  }

  void _onChangeLocale(ChangeLocaleEvent event, Emitter<GlobalState> emit) {
    emit(state.copyWith(locale: event.locale));
  }

  Future<void> _onTokenExpired(TokenExpiredEvent event, Emitter<GlobalState> emit) async {
    // Clear token and set auth status to guest when token expires
    emit(state.copyWith(authStatus: AuthStatus.guest));
  }
}
