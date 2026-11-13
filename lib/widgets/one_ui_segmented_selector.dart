import 'package:flutter/material.dart';

class SelectorOption<T> {
  const SelectorOption(this.value, this.label, {this.icon, this.key});
  final T value;
  final String label;
  final IconData? icon;
  final Key? key;
}

/// Shared One UI selector used by brightness and reminder frequency.
class OneUiSegmentedSelector<T> extends StatelessWidget {
  const OneUiSegmentedSelector({
    super.key,
    required this.value,
    required this.options,
    this.onChanged,
  });
  final T value;
  final List<SelectorOption<T>> options;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedIndex = options.indexWhere((option) => option.value == value);
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
              alignment: AlignmentDirectional(
                -1 + 2 * selectedIndex / (options.length - 1),
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / options.length,
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
              for (final option in options)
                Expanded(
                  child: Semantics(
                    selected: value == option.value,
                    inMutuallyExclusiveGroup: true,
                    child: TextButton(
                      key: option.key,
                      onPressed: onChanged == null
                          ? null
                          : () => onChanged!(option.value),
                      style: TextButton.styleFrom(
                        foregroundColor: value == option.value
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
                          if (option.icon != null) ...[
                            Icon(option.icon, size: 18),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              option.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: value == option.value
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
