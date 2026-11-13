import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/import_snapshot.dart';
import '../models/user.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final intervals = provider.timeline;
    // Keep profiles lazy even when an interval contains thousands of users.
    final rows = <(UnfollowInterval, InstagramUser?)>[
      for (final interval in intervals) ...[
        (interval, null),
        for (final user in interval.users) (interval, user),
      ],
    ];
    final bottomPadding = context.watch<ThemeProvider>().isSamsungTheme
        ? 100.0
        : 24.0;
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 66,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timeline,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Timeline',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Chi non compare più nei follower, tra le date delle esportazioni. '
              'L’intervallo non indica il giorno esatto dell’unfollow. '
              'Include i profili in whitelist.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : intervals.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Carica due esportazioni dei follower per iniziare la timeline.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final dateWidth = ((constraints.maxWidth - 32) * 0.25)
                          .clamp(88.0, 112.0);
                      return ListView.builder(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
                        itemCount: rows.length,
                        itemBuilder: (context, index) => _TimelineRow(
                          key: ValueKey('timeline-row-$index'),
                          interval: rows[index].$1,
                          user: rows[index].$2,
                          dateWidth: dateWidth,
                          isFirst: index == 0,
                          isLast: index == rows.length - 1,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    super.key,
    required this.interval,
    required this.dateWidth,
    required this.isFirst,
    required this.isLast,
    this.user,
  });
  final UnfollowInterval interval;
  final InstagramUser? user;
  final double dateWidth;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final profile = user;
    final isHeader = profile == null;
    const railWidth = 32.0;
    final nodeY = isHeader ? 28.0 : 26.0;
    return CustomPaint(
      painter: _TimelineLinePainter(
        x: dateWidth + railWidth / 2,
        nodeY: nodeY,
        color: colors.outlineVariant,
        isFirst: isFirst,
        isLast: isLast,
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: dateWidth,
                child: isHeader ? _IntervalDates(interval: interval) : null,
              ),
              const SizedBox(width: railWidth + 12),
              Expanded(
                child: isHeader
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 104),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 14, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                interval.users.isEmpty
                                    ? 'Nessun unfollow'
                                    : interval.users.length == 1
                                    ? '1 profilo non più tra i follower'
                                    : '${interval.users.length} profili non più tra i follower',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Confronto tra esportazioni',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              if (interval.previous.estimatedDate) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Data iniziale stimata dal vecchio JSON.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: colors.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () =>
                                _openProfile(context, profile.username),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '@${profile.username}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.open_in_new,
                                    size: 16,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          Positioned(
            left: dateWidth + (isHeader ? 0 : 12),
            top: nodeY - (isHeader ? 16 : 4),
            child: ExcludeSemantics(
              child: Container(
                key: const ValueKey('timeline-node'),
                width: isHeader ? 32 : 8,
                height: isHeader ? 32 : 8,
                decoration: BoxDecoration(
                  color: isHeader ? colors.primary : colors.surface,
                  shape: BoxShape.circle,
                  border: isHeader
                      ? null
                      : Border.all(color: colors.primary, width: 2),
                ),
                child: isHeader
                    ? Icon(
                        interval.users.isEmpty
                            ? Icons.check
                            : Icons.person_remove_outlined,
                        size: 18,
                        color: colors.onPrimary,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openProfile(BuildContext context, String username) async {
    try {
      final opened = await launchUrl(
        Uri.https('www.instagram.com', '/$username/'),
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    } on Exception {
      // Report unavailable handlers in the UI.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aprire il profilo.')),
      );
    }
  }
}

class _IntervalDates extends StatelessWidget {
  const _IntervalDates({required this.interval});
  final UnfollowInterval interval;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final format = DateFormat('dd/MM/yyyy');
    final previous = format.format(interval.previous.date);
    final current = format.format(interval.current.date);
    return Semantics(
      label: 'Dal $previous al $current',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, right: 12, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'dal',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              previous,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'al',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              current,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Each lazy row paints its portion of the same axis, without gaps between rows.
class _TimelineLinePainter extends CustomPainter {
  const _TimelineLinePainter({
    required this.x,
    required this.nodeY,
    required this.color,
    required this.isFirst,
    required this.isLast,
  });
  final double x;
  final double nodeY;
  final Color color;
  final bool isFirst;
  final bool isLast;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(x, isFirst ? nodeY : 0),
      Offset(x, isLast ? nodeY : size.height),
      Paint()
        ..color = color
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_TimelineLinePainter oldDelegate) =>
      x != oldDelegate.x ||
      nodeY != oldDelegate.nodeY ||
      color != oldDelegate.color ||
      isFirst != oldDelegate.isFirst ||
      isLast != oldDelegate.isLast;
}
