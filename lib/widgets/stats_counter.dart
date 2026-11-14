import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';

List<Color> statsCounterGradientColors(BuildContext context, int count) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return count < 10
      ? isDark
            ? const [Color(0xFF1B5E20), Color(0xFF43A047)]
            : const [Color(0xFF2E7D32), Color(0xFF66BB6A)]
      : count <= 50
      ? isDark
            ? const [Color(0xFF0D47A1), Color(0xFF1976D2)]
            : const [Color(0xFF1565C0), Color(0xFF42A5F5)]
      : isDark
      ? const [Color(0xFF542326), Color(0xFFAD3942)]
      : const [Color(0xFFC62828), Color(0xFFEF5350)];
}

class StatsCounter extends StatelessWidget {
  final int count;
  final String? label;
  final String? semanticsLabel;
  final IconData? indicatorIcon;
  final String? zeroCountLabel;

  const StatsCounter({
    super.key,
    required this.count,
    this.label,
    this.semanticsLabel,
    this.indicatorIcon,
    this.zeroCountLabel,
  });

  @override
  Widget build(BuildContext context) {
    final label = this.label ?? context.l10n.reviewCountLabel;
    final semanticsLabel =
        this.semanticsLabel ?? context.l10n.reviewCountSemantics;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = statsCounterGradientColors(context, count);
    final accent = gradientColors.last;
    final isComplete = count == 0 && zeroCountLabel != null;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: gradientColors.last, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: isDark ? 0.50 : 0.36),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: gradientColors.first.withValues(
                      alpha: isDark ? 0.28 : 0.20,
                    ),
                    blurRadius: 44,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: isComplete
                  ? SizedBox(
                      height: 44,
                      child: Center(
                        child: Text(
                          zeroCountLabel!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: count),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Text(
                              value.toString(),
                              style: const TextStyle(
                                fontSize: 44,
                                height: 1,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Semantics(
                label: isComplete ? zeroCountLabel : semanticsLabel,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: gradientColors.first.withValues(
                      alpha: isDark ? 0.9 : 0.82,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.16),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: isDark ? 0.24 : 0.16),
                      ),
                      child: Icon(
                        indicatorIcon ??
                            (count == 0
                                ? Icons.check_rounded
                                : Icons.priority_high_rounded),
                        color: accent,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
