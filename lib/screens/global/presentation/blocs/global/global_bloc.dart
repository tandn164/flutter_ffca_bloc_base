import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../authentication/presentation/authentication/models/auth_status.dart';
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
  }

  _onCheckAuth(CheckAuthenticateEvent event, Emitter<GlobalState> emit) async {
    var result = await checkTokenUseCase(());
    result.fold((l) => emit(state.copyWith(authStatus: AuthStatus.guest)),
        (r) => emit(state.copyWith(authStatus: AuthStatus.user)));
  }

  _onLogout(LogoutEvent event, Emitter<GlobalState> emit) async {
    var result = await logoutUseCase(());
    result.fold((l) => emit(state.copyWith(authStatus: AuthStatus.user)),
        (r) => emit(state.copyWith(authStatus: AuthStatus.guest)));
  }

  _onChangeTab(ChangeTabEvent event, Emitter<GlobalState> emit) {
    emit(state.copyWith(tabBarIndex: event.index));
  }

  _onGetDeviceInfo(GetDeviceInfoEvent event, Emitter<GlobalState> emit) async {
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

  _onInitialLocale(InitialLocaleEvent event, Emitter<GlobalState> emit) {
    emit(state.copyWith(locale: S.supportedLocales.first));
  }

  _onChangeLocale(ChangeLocaleEvent event, Emitter<GlobalState> emit) {
    if (S.supportedLocales.indexOf(state.locale!) == 0) {
      emit(state.copyWith(locale: S.supportedLocales[1]));
    } else {
      emit(state.copyWith(locale: S.supportedLocales[0]));
    }
  }
}
