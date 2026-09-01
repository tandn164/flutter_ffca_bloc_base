import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

import 'bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    required this.createBloc,
    this.onNotice,
    this.onBusy,
    this.footer,
    super.key,
  });

  final ProfileBloc Function() createBloc;
  final void Function(BuildContext context, ProfileNotice notice)? onNotice;
  final void Function(bool busy)? onBusy;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc()..add(const ProfileStarted()),
      child: _ProfileView(
        onNotice: onNotice,
        onBusy: onBusy,
        footer: footer,
      ),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView({this.onNotice, this.onBusy, this.footer});

  final void Function(BuildContext context, ProfileNotice notice)? onNotice;
  final void Function(bool busy)? onBusy;
  final Widget? footer;

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  String? _boundId;
  bool _busyPushed = false;

  @override
  void dispose() {
    if (_busyPushed) widget.onBusy?.call(false);
    _name.dispose();
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
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) => previous.busy != current.busy,
          listener: (_, state) => _syncBusy(state.busy),
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) =>
              current.notice != null && current.notice != previous.notice,
          listener: (context, state) {
            final notice = state.notice;
            if (notice != null) widget.onNotice?.call(context, notice);
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileData && state.profile.id != _boundId) {
              _boundId = state.profile.id;
              _name.text = state.profile.name;
            }
          },
          builder: (context, state) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kFormMaxWidth),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: switch (state) {
                    ProfileLoading() => const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ProfileError(:final message) => Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(message, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () =>
                                    context.read<ProfileBloc>().add(const ProfileStarted()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ProfileData(:final profile) => Card(
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
                                    profile.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontSize: 22),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile.email,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 24),
                                  AppTextField(
                                    controller: _name,
                                    label: 'Name',
                                    validators: [requiredField('This field is required')],
                                  ),
                                  const SizedBox(height: 16),
                                  Builder(
                                    builder: (context) {
                                      return FilledButton(
                                        onPressed: () {
                                          if (!FormScope.of(context).validateAll()) return;
                                          context.read<ProfileBloc>().add(ProfileSaved(_name.text));
                                        },
                                        child: const Text('Save profile'),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: () =>
                                        context.read<ProfileBloc>().add(const ProfileSignedOut()),
                                    child: const Text('Log out'),
                                  ),
                                  if (widget.footer != null) widget.footer!,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
