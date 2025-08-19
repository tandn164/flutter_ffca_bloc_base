import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../../generated/l10n/l10n.dart';

part 'global_event.dart';
part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc() : super(const GlobalState.initial()) {
    on<ChangeTabEvent>(_onChangeTab);
    on<GetDeviceInfoEvent>(_onGetDeviceInfo);
    on<InitialLocaleEvent>(_onInitialLocale);
    on<ChangeLocaleEvent>(_onChangeLocale);
    on<SplashDisplayedEvent>(_onSplashDisplayed);
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

  void _onSplashDisplayed(SplashDisplayedEvent event, Emitter<GlobalState> emit) {
    emit(state.copyWith(splashDisplayed: true));
  }
}
