import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';

class SimulateOfflineTile extends StatefulWidget {
  const SimulateOfflineTile({required this.hint, super.key});

  final ConnectivityHint hint;

  @override
  State<SimulateOfflineTile> createState() => _SimulateOfflineTileState();
}

class _SimulateOfflineTileState extends State<SimulateOfflineTile> {
  FakeConnectivity? _hint;

  @override
  void initState() {
    super.initState();
    final hint = widget.hint;
    if (hint is FakeConnectivity) {
      _hint = hint;
      hint.addListener(_onChange);
    }
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hint?.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hint = _hint;
    if (hint == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Simulate offline'),
        value: hint.isSureOffline,
        onChanged: hint.setOffline,
      ),
    );
  }
}
