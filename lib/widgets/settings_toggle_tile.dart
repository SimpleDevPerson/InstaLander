import 'package:flutter/material.dart';

/// Shared switch styling for advertising and reminder settings.
class SettingsToggleTile extends StatelessWidget {
  const SettingsToggleTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isSamsung,
    this.onChanged,
  });
  final String title;
  final String subtitle;
  final bool value;
  final bool isSamsung;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: ListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onChanged == null ? null : () => onChanged!(!value),
        trailing: SizedBox(
          width: 52,
          height: 48,
          child: Center(
            child: Transform.scale(
              scale: isSamsung ? 0.85 : 1,
              child: Switch(
                value: value,
                onChanged: onChanged,
                thumbColor: isSamsung
                    ? const WidgetStatePropertyAll(Colors.white)
                    : null,
                activeTrackColor: isSamsung ? const Color(0xFF0381FE) : null,
                inactiveTrackColor: isSamsung
                    ? (theme.brightness == Brightness.dark
                          ? const Color(0xFF555558)
                          : const Color(0xFFB6B6BB))
                    : null,
                trackOutlineColor: isSamsung
                    ? const WidgetStatePropertyAll(Colors.transparent)
                    : null,
                thumbIcon: isSamsung
                    ? const WidgetStatePropertyAll(Icon(null))
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
