import 'package:sample_domain/sample_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

import 'bloc/sample_bloc.dart';

class SamplePage extends StatelessWidget {
  const SamplePage({
    required this.createBloc,
    this.onNotice,
    super.key,
  });

  final SampleBloc Function() createBloc;
  final void Function(BuildContext context, SampleNotice notice)? onNotice;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc(),
      child: _SampleView(onNotice: onNotice),
    );
  }
}

class _SampleView extends StatelessWidget {
  const _SampleView({this.onNotice});

  final void Function(BuildContext context, SampleNotice notice)? onNotice;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SampleBloc, SampleState>(
      listenWhen: (previous, current) =>
          current.notice != null && current.notice != previous.notice,
      listener: (context, state) {
        final notice = state.notice;
        if (notice != null) onNotice?.call(context, notice);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Tasks')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _editTask(context),
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<SampleBloc, SampleState>(
          builder: (context, state) {
            final items = switch (state) {
              SampleData(:final items) => items,
              _ => const <SampleItem>[],
            };
            return AppList<SampleItem>(
              items: items,
              loading: state is SampleLoading,
              loadingMore: state is SampleData && state.loadingMore,
              hasMore: state is SampleData && state.hasMore,
              emptyLabel: 'No tasks yet',
              error: switch (state) {
                SampleError(:final message) => message,
                _ => null,
              },
              onReload: () =>
                  context.read<SampleBloc>().add(const SampleStarted()),
              onRefresh: () async {
                final bloc = context.read<SampleBloc>();
                bloc.add(const SampleRefreshed());
                await bloc.stream.first;
              },
              onLoadMore: () =>
                  context.read<SampleBloc>().add(const SampleLoadMore()),
              skeletonBuilder: (_, i) =>
                  SkeletonTile(delay: Duration(milliseconds: i * 80)),
              itemBuilder: (context, item, _) => _TaskTile(
                item: item,
                onToggle: () =>
                    context.read<SampleBloc>().add(SampleToggled(item.id)),
                onEdit: () => _editTask(context, item: item),
                onDelete: () =>
                    context.read<SampleBloc>().add(SampleDeleted(item.id)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final SampleItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async => true,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: scheme.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_outline, color: scheme.error),
      ),
      child: Card(
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 12, 8),
            child: Row(
              children: [
                Checkbox(
                  value: item.done,
                  onChanged: (_) => onToggle(),
                ),
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: item.done
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                          decoration:
                              item.done ? TextDecoration.lineThrough : null,
                          decorationColor: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: scheme.outline, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _editTask(BuildContext context, {SampleItem? item}) async {
  final title = await showTaskEditorDialog(
    context,
    isNew: item == null,
    initialTitle: item?.title ?? '',
  );
  if (!context.mounted || title == null || title.isEmpty) return;
  if (item == null) {
    context.read<SampleBloc>().add(SampleCreated(title));
  } else if (title != item.title) {
    context.read<SampleBloc>().add(SampleRenamed(item.id, title));
  }
}

@visibleForTesting
Future<String?> showTaskEditorDialog(
  BuildContext context, {
  required bool isNew,
  String initialTitle = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TaskEditorDialog(isNew: isNew, initialTitle: initialTitle),
  );
}

/// Owns the [TextEditingController] for the dialog route lifetime.
/// Disposing the controller in the caller (after [showDialog] returns) races
/// the close animation and throws "used after being disposed".
class _TaskEditorDialog extends StatefulWidget {
  const _TaskEditorDialog({required this.isNew, required this.initialTitle});

  final bool isNew;
  final String initialTitle;

  @override
  State<_TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<_TaskEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isNew ? 'New task' : 'Edit task'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'What needs doing?'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
          onPressed: _submit,
          child: Text(widget.isNew ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
