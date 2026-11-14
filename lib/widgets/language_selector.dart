import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

/// Uses the same popup dimensions, surface and selection treatment as sorting.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final labels = {
      'system': context.l10n.languageSystem,
      'it': 'Italiano',
      'en': 'English',
    };
    final selected = value ?? 'system';
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.72),
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: PopupMenuButton<String>(
        key: ValueKey('language-$selected'),
        tooltip: context.l10n.language,
        onSelected: (code) => onChanged(code == 'system' ? null : code),
        position: PopupMenuPosition.under,
        offset: const Offset(0, 4),
        color: colors.surfaceContainerHighest,
        elevation: 8,
        constraints: const BoxConstraints(minWidth: 240, maxWidth: 240),
        menuPadding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colors.outline, width: 1.5),
        ),
        itemBuilder: (context) => [
          for (final entry in labels.entries)
            PopupMenuItem(
              value: entry.key,
              height: 56,
              padding: EdgeInsets.zero,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: entry.key == selected
                      ? colors.onSurface.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      entry.key == 'system'
                          ? Icons.phone_android_outlined
                          : Icons.language,
                      size: 26,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    if (entry.key == selected)
                      const Icon(Icons.check, color: Color(0xFF4CAF50)),
                  ],
                ),
              ),
            ),
        ],
        child: Row(
          children: [
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                labels[selected]!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
