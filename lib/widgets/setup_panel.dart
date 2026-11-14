import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

class SetupPanel extends StatelessWidget {
  final VoidCallback onShowGuide;
  final VoidCallback onLoadJson;
  final VoidCallback onLoadArchive;

  const SetupPanel({
    super.key,
    required this.onShowGuide,
    required this.onLoadJson,
    required this.onLoadArchive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF1976D2) : const Color(0xFF1565C0);
    final border = colors.outlineVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            key: const Key('setup-intro-card'),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF0D47A1), Color(0xFF12325B)]
                    : const [Color(0xFF1565C0), Color(0xFF0D47A1)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: accent),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 6,
                              color: Colors.lightBlueAccent,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                context.l10n.required,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        size: 22,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.setUpReport,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.setUpReportDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            key: const Key('setup-files-card'),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.getCardBg(context),
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    Text(
                      context.l10n.requiredFiles,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        letterSpacing: 0.7,
                      ),
                    ),
                    Text(
                      context.l10n.standardJson,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Divider(color: border, height: 16),
                const SizedBox(height: 8),
                const Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoChip(
                      icon: Icons.people_outline,
                      label: 'followers_*.json',
                      color: Colors.blue,
                    ),
                    _InfoChip(
                      icon: Icons.person_add_outlined,
                      label: 'following_*.json',
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Material(
                  color: colors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: border.withValues(alpha: 0.5)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    onTap: onShowGuide,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.menu_book_outlined,
                        size: 21,
                        color: colors.primary,
                      ),
                    ),
                    title: Text(
                      context.l10n.exportGuide,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final jsonButton = _ImportButton(
                      label: context.l10n.loadJson,
                      icon: Icons.cloud_upload_outlined,
                      iconColor: isDark
                          ? Colors.lightBlueAccent
                          : Colors.blue.shade700,
                      onPressed: onLoadJson,
                    );
                    final archiveButton = _ImportButton(
                      label: context.l10n.loadZip,
                      icon: Icons.folder_zip_outlined,
                      iconColor: isDark ? Colors.amber : Colors.amber.shade900,
                      onPressed: onLoadArchive,
                    );
                    if (constraints.maxWidth < 280 ||
                        MediaQuery.textScalerOf(context).scale(14) > 20) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          jsonButton,
                          const SizedBox(height: 12),
                          archiveButton,
                        ],
                      );
                    }
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: jsonButton),
                          const SizedBox(width: 12),
                          Expanded(child: archiveButton),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportButton extends StatelessWidget {
  const _ImportButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 72),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 10),
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    ),
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}
