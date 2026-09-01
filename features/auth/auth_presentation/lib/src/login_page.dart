import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

import 'bloc/login_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    required this.createBloc,
    required this.onSignup,
    required this.onForgotPassword,
    this.demoEmail = '',
    this.demoPassword = '',
    this.onNotice,
    this.onBusy,
    super.key,
  });

  final LoginBloc Function() createBloc;
  final VoidCallback onSignup;
  final VoidCallback onForgotPassword;
  final String demoEmail;
  final String demoPassword;
  final void Function(BuildContext context, AuthNotice notice)? onNotice;
  final void Function(bool busy)? onBusy;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc(),
      child: _LoginView(
        demoEmail: demoEmail,
        demoPassword: demoPassword,
        onNotice: onNotice,
        onBusy: onBusy,
        onSignup: onSignup,
        onForgotPassword: onForgotPassword,
      ),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({
    required this.demoEmail,
    required this.demoPassword,
    required this.onSignup,
    required this.onForgotPassword,
    this.onNotice,
    this.onBusy,
  });

  final String demoEmail;
  final String demoPassword;
  final VoidCallback onSignup;
  final VoidCallback onForgotPassword;
  final void Function(BuildContext context, AuthNotice notice)? onNotice;
  final void Function(bool busy)? onBusy;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _busyPushed = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.demoEmail);
    _password = TextEditingController(text: widget.demoPassword);
  }

  @override
  void dispose() {
    if (_busyPushed) widget.onBusy?.call(false);
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _syncBusy(bool busy) {
    if (busy == _busyPushed) return;
    _busyPushed = busy;
    widget.onBusy?.call(busy);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LoginBloc, LoginState>(
          listenWhen: (previous, current) => previous.busy != current.busy,
          listener: (_, state) => _syncBusy(state.busy),
        ),
        BlocListener<LoginBloc, LoginState>(
          listenWhen: (previous, current) =>
              current.notice != null && current.notice != previous.notice,
          listener: (context, state) {
            final notice = state.notice;
            if (notice != null) widget.onNotice?.call(context, notice);
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Log in')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kFormMaxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                  child: FormScope(
                    formKey: _formKey,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppMark(),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome back',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to your tasks.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Demo: ${widget.demoEmail} / ${widget.demoPassword}',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          AppTextField(
                            controller: _email,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validators: [
                              requiredField('This field is required'),
                              emailField('Enter a valid email'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _password,
                            label: 'Password',
                            obscureText: true,
                            validators: [
                              requiredField('This field is required')
                            ],
                          ),
                          const SizedBox(height: 24),
                          Builder(
                            builder: (context) {
                              return FilledButton(
                                onPressed: () {
                                  if (!FormScope.of(context).validateAll()) {
                                    return;
                                  }
                                  context.read<LoginBloc>().add(
                                        LoginSubmitted(
                                          email: _email.text,
                                          password: _password.text,
                                        ),
                                      );
                                },
                                child: const Text('Log in'),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: widget.onSignup,
                            child: const Text('Create an account'),
                          ),
                          TextButton(
                            onPressed: widget.onForgotPassword,
                            child: const Text('Forgot password'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
