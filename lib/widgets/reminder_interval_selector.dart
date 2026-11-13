import 'package:flutter/material.dart';
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

  static const options = [
    SelectorOption(1, 'Ogni mese', key: ValueKey('reminder-months-1')),
    SelectorOption(3, 'Ogni 3 mesi', key: ValueKey('reminder-months-3')),
    SelectorOption(6, 'Ogni 6 mesi', key: ValueKey('reminder-months-6')),
  ];

  @override
  Widget build(BuildContext context) {
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
