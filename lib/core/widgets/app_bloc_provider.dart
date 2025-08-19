import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/app_state_manager.dart';
import '../../injection_container.dart';
import '../../screens/authentication/presentation/authentication/blocs/authentication_bloc.dart';
import '../../screens/global/presentation/blocs/global/global_bloc.dart';

/// Widget that provides app-level blocs and handles their state changes
class AppBlocProvider extends StatelessWidget {
  final Widget child;

  const AppBlocProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<GlobalBloc>()..add(InitialLocaleEvent()),
        ),
        BlocProvider(
          create: (_) => sl<AuthenticationBloc>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          // Global state listener
          BlocListener<GlobalBloc, GlobalState>(
            listenWhen: (previous, current) => 
                previous.splashDisplayed != current.splashDisplayed,
            listener: AppStateManager.handleGlobalStateChanges,
          ),
          // Authentication state listener
          BlocListener<AuthenticationBloc, AuthenticationState>(
            listenWhen: (previous, current) => 
                previous.authStatus != current.authStatus,
            listener: AppStateManager.handleAuthenticationStateChange,
          ),
        ],
        child: child,
      ),
    );
  }
}
