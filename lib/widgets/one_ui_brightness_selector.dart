import 'package:flutter/material.dart';

import '../providers/theme_provider.dart';

class OneUiBrightnessSelector extends StatelessWidget {
  const OneUiBrightnessSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AppBrightnessMode value;
  final ValueChanged<AppBrightnessMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        border: Border.all(color: colors.outlineVariant, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: AlignmentDirectional(value.index - 1.0, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / 3,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final mode in AppBrightnessMode.values)
                Expanded(
                  child: Semantics(
                    selected: value == mode,
                    inMutuallyExclusiveGroup: true,
                    child: TextButton(
                      key: ValueKey('brightness-mode-${mode.name}'),
                      onPressed: () => onChanged(mode),
                      style: TextButton.styleFrom(
                        foregroundColor: value == mode
                            ? colors.primary
                            : colors.onSurfaceVariant,
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(mode.icon, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              switch (mode) {
                                AppBrightnessMode.system => 'Sistema',
                                AppBrightnessMode.light => 'Chiaro',
                                AppBrightnessMode.dark => 'Scuro',
                              },
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: value == mode
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
