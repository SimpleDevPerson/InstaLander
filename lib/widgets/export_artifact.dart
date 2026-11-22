import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

class ExportArtifactsHeader extends StatelessWidget {
  const ExportArtifactsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Semantics(
        header: true,
        child: Text(
          context.l10n.exportArtifacts,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class ExportArtifactCard extends StatelessWidget {
  const ExportArtifactCard({super.key, required this.username, this.action});

  final String username;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text('@$username'),
        trailing: action,
      ),
    );
  }
}
