import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../providers/theme_provider.dart';
import 'one_ui_segmented_selector.dart';

class OneUiBrightnessSelector extends StatelessWidget {
  const OneUiBrightnessSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final AppBrightnessMode value;
  final ValueChanged<AppBrightnessMode> onChanged;

  @override
  Widget build(BuildContext context) =>
      OneUiSegmentedSelector<AppBrightnessMode>(
        value: value,
        onChanged: onChanged,
        options: [
          for (final mode in AppBrightnessMode.values)
            SelectorOption(
              mode,
              switch (mode) {
                AppBrightnessMode.system => context.l10n.system,
                AppBrightnessMode.light => context.l10n.light,
                AppBrightnessMode.dark => context.l10n.dark,
              },
              icon: mode.icon,
              key: ValueKey('brightness-mode-${mode.name}'),
            ),
        ],
      );
}
