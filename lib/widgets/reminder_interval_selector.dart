import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import 'one_ui_segmented_selector.dart';

class ReminderIntervalSelector extends StatelessWidget {
  const ReminderIntervalSelector({
    super.key,
    required this.value,
    required this.isSamsung,
    this.onChanged,
  });
  final int value;
  final bool isSamsung;
  final ValueChanged<int>? onChanged;

  List<SelectorOption<int>> options(BuildContext context) => [
    SelectorOption(
      1,
      context.l10n.everyMonth,
      key: const ValueKey('reminder-months-1'),
    ),
    SelectorOption(
      3,
      context.l10n.everyThreeMonths,
      key: const ValueKey('reminder-months-3'),
    ),
    SelectorOption(
      6,
      context.l10n.everySixMonths,
      key: const ValueKey('reminder-months-6'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final options = this.options(context);
    if (isSamsung) {
      return OneUiSegmentedSelector<int>(
        value: value,
        options: options,
        onChanged: onChanged,
      );
    }
    final colors = Theme.of(context).colorScheme;
    return SegmentedButton<int>(
      segments: [
        for (final option in options)
          ButtonSegment(value: option.value, label: Text(option.label)),
      ],
      selected: {value},
      showSelectedIcon: false,
      onSelectionChanged: onChanged == null
          ? null
          : (values) => onChanged!(values.first),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.onPrimary
              : colors.onSurfaceVariant,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : Colors.transparent,
        ),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.outline,
          ),
        ),
      ),
    );
  }
}
