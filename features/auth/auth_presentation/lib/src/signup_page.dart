import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

import 'bloc/signup_bloc.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({
    required this.createBloc,
    required this.onLogin,
    this.onNotice,
    this.onBusy,
    super.key,
  });

  final SignupBloc Function() createBloc;
  final VoidCallback onLogin;
  final void Function(BuildContext context, AuthNotice notice)? onNotice;
  final void Function(bool busy)? onBusy;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc(),
      child: _SignupView(
        onLogin: onLogin,
        onNotice: onNotice,
        onBusy: onBusy,
      ),
    );
  }
}

class _SignupView extends StatefulWidget {
  const _SignupView({
    required this.onLogin,
    this.onNotice,
    this.onBusy,
  });

  final VoidCallback onLogin;
  final void Function(BuildContext context, AuthNotice notice)? onNotice;
  final void Function(bool busy)? onBusy;

  @override
  State<_SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<_SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busyPushed = false;

  @override
  void dispose() {
    if (_busyPushed) widget.onBusy?.call(false);
    _name.dispose();
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
        BlocListener<SignupBloc, SignupState>(
          listenWhen: (previous, current) => previous.busy != current.busy,
          listener: (_, state) => _syncBusy(state.busy),
        ),
        BlocListener<SignupBloc, SignupState>(
          listenWhen: (previous, current) =>
              current.notice != null && current.notice != previous.notice,
          listener: (context, state) {
            final notice = state.notice;
            if (notice != null) widget.onNotice?.call(context, notice);
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign up')),
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
                            'Create account',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'A quiet list for what you need to do.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          AppTextField(
                            controller: _name,
                            label: 'Name',
                            validators: [
                              requiredField('This field is required')
                            ],
                          ),
                          const SizedBox(height: 12),
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
                              requiredField('This field is required'),
                              minLength(6, 'At least 6 characters'),
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
                                  context.read<SignupBloc>().add(
                                        SignupSubmitted(
                                          name: _name.text,
                                          email: _email.text,
                                          password: _password.text,
                                        ),
                                      );
                                },
                                child: const Text('Sign up'),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: widget.onLogin,
                            child:
                                const Text('Already have an account? Log in'),
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
