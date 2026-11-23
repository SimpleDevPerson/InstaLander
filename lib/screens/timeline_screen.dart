import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/import_snapshot.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/one_ui_segmented_selector.dart';

enum _TimelineView { profiles, files }

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  _TimelineView _view = _TimelineView.profiles;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
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
                        context.l10n.timeline,
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: OneUiSegmentedSelector(
              value: _view,
              options: [
                SelectorOption(
                  _TimelineView.profiles,
                  context.l10n.timelineProfilesView,
                  icon: Icons.people_outline,
                ),
                SelectorOption(
                  _TimelineView.files,
                  context.l10n.timelineFilesView,
                  icon: Icons.insert_drive_file_outlined,
                ),
              ],
              onChanged: (view) => setState(() => _view = view),
            ),
          ),
          if (_view == _TimelineView.profiles)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                context.l10n.timelineDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _view == _TimelineView.profiles
                ? _buildTimeline(provider, bottomPadding)
                : _buildFiles(provider, bottomPadding),
          ),
        ],
      ),
    );
  }

  Widget _buildFiles(AppProvider provider, double bottomPadding) {
    return FutureBuilder<List<ImportFileEntry>>(
      future: provider.savedImports,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: provider.retryImports,
              child: Text(context.l10n.retry),
            ),
          );
        }
        final files = snapshot.data ?? const <ImportFileEntry>[];
        if (files.isEmpty) {
          return Center(child: Text(context.l10n.timelineFilesEmpty));
        }
        // A following file can be reimported separately for the same export.
        // Keep its original entry for removal, but display it with that day.
        final byDay = <DateTime, List<ImportFileEntry>>{};
        for (final file in files) {
          byDay.putIfAbsent(DateUtils.dateOnly(file.date), () => []).add(file);
        }
        final rows = <(List<ImportFileEntry>, ImportFileEntry?)>[
          for (final batch in byDay.values) ...[
            (batch, null),
            for (final file in batch)
              if (_isFollowersFile(file)) (batch, file),
            for (final file in batch)
              if (!_isFollowersFile(file)) (batch, file),
          ],
        ];
        return _buildRail(
          const PageStorageKey('timeline-files'),
          bottomPadding,
          rows.length,
          (context, index, dateWidth) {
            final (batch, file) = rows[index];
            final strings = context.l10n;
            final colors = Theme.of(context).colorScheme;
            final title = file?.name ?? strings.timelineLegacyImport;
            return _TimelineRow(
              key: file == null ? null : ValueKey(file),
              dateWidth: dateWidth,
              isFirst: index == 0,
              isLast: index == rows.length - 1,
              headerIcon: file == null ? Icons.file_upload_outlined : null,
              date: file == null ? _ImportDate(batch.first.date) : null,
              content: file == null
                  ? _TimelineHeading(
                      title: strings.timelineFileCount(batch.length),
                    )
                  : _TimelineCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              file.name == null
                                  ? Icons.folder_outlined
                                  : Icons.data_object,
                              size: 22,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: _TimelineItemTitle(title)),
                            IconButton(
                              tooltip: strings.timelineRemoveFile,
                              icon: const Icon(Icons.close, size: 18),
                              color: colors.onSurfaceVariant,
                              onPressed: () =>
                                  _confirmRemove(provider, file, title),
                            ),
                          ],
                        ),
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  bool _isFollowersFile(ImportFileEntry file) =>
      file.name?.toLowerCase().startsWith('followers') ?? false;

  Future<void> _confirmRemove(
    AppProvider provider,
    ImportFileEntry file,
    String title,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.timelineRemoveFile),
        content: Text(context.l10n.timelineRemoveFileDescription(title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.remove),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await provider.removeImportedFile(file);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.timelineRemoveFileError)),
      );
    }
  }

  Widget _buildTimeline(AppProvider provider, double bottomPadding) {
    final savedTimeline = provider.savedTimeline;
    return FutureBuilder<List<UnfollowInterval>>(
      future: savedTimeline,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (savedTimeline != null && snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.initializationError(snapshot.error.toString()),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: provider.retryTimeline,
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }
        return _buildIntervals(context, [
          ...provider.debugTimeline,
          if (savedTimeline != null) ...?snapshot.data,
        ], bottomPadding);
      },
    );
  }

  Widget _buildIntervals(
    BuildContext context,
    List<UnfollowInterval> intervals,
    double bottomPadding,
  ) {
    if (intervals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(context.l10n.timelineEmpty, textAlign: TextAlign.center),
        ),
      );
    }

    final rows = <(UnfollowInterval, TimelineProfile?)>[
      for (final interval in intervals) ...[
        (interval, null),
        for (final profile in interval.profiles) (interval, profile),
      ],
    ];
    return _buildRail(
      const PageStorageKey('timeline-profiles'),
      bottomPadding,
      rows.length,
      (context, index, dateWidth) {
        final (interval, profile) = rows[index];
        final colors = Theme.of(context).colorScheme;
        final strings = context.l10n;
        return _TimelineRow(
          key: ValueKey('timeline-row-$index'),
          dateWidth: dateWidth,
          isFirst: index == 0,
          isLast: index == rows.length - 1,
          headerIcon: profile == null
              ? (interval.users.isEmpty
                    ? Icons.check
                    : Icons.person_remove_outlined)
              : null,
          date: profile == null ? _IntervalDates(interval: interval) : null,
          content: profile == null
              ? _TimelineHeading(
                  title: switch (interval.users.length) {
                    0 => strings.noUnfollows,
                    1 => strings.oneLostFollower,
                    final n => strings.lostFollowers('$n'),
                  },
                  subtitle: [
                    strings.exportComparison,
                    if (interval.estimatedDate) strings.estimatedDate,
                  ],
                  minHeight: 104,
                )
              : _TimelineCard(
                  onTap: () => _openProfile(context, profile.user.username),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TimelineProfileDetails(profile: profile),
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
        );
      },
    );
  }

  Widget _buildRail(
    PageStorageKey<String> key,
    double bottomPadding,
    int length,
    Widget Function(BuildContext, int, double) rowBuilder,
  ) => LayoutBuilder(
    builder: (context, constraints) {
      final dateWidth = ((constraints.maxWidth - 32) * 0.25).clamp(88.0, 112.0);
      return ListView.builder(
        key: key,
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
        itemCount: length,
        itemBuilder: (context, index) => rowBuilder(context, index, dateWidth),
      );
    },
  );

  Future<void> _openProfile(BuildContext context, String username) async {
    try {
      final opened = await context.read<AppProvider>().openProfile(username);
      if (opened) return;
    } on Exception {
      // Report unavailable handlers in the UI.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.cannotOpenProfile)));
    }
  }
}

class _TimelineHeading extends StatelessWidget {
  const _TimelineHeading({
    required this.title,
    this.subtitle = const [],
    this.minHeight = 56,
  });

  final String title;
  final List<String> subtitle;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            for (final line in subtitle) ...[
              const SizedBox(height: 6),
              Text(
                line,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? child : InkWell(onTap: onTap, child: child),
    ),
  );
}

class _TimelineItemTitle extends StatelessWidget {
  const _TimelineItemTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
  );
}

class _ImportDate extends StatelessWidget {
  const _ImportDate(this.date);
  final DateTime date;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 12, 8),
    child: Text(
      MaterialLocalizations.of(context).formatCompactDate(date),
      textAlign: TextAlign.end,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    super.key,
    required this.dateWidth,
    required this.isFirst,
    required this.isLast,
    required this.content,
    this.date,
    this.headerIcon,
  });

  final double dateWidth;
  final bool isFirst;
  final bool isLast;
  final Widget content;
  final Widget? date;
  final IconData? headerIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isHeader = headerIcon != null;
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
              SizedBox(width: dateWidth, child: date),
              const SizedBox(width: railWidth + 12),
              Expanded(child: content),
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
                    ? Icon(headerIcon, size: 18, color: colors.onPrimary)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineProfileDetails extends StatelessWidget {
  const _TimelineProfileDetails({required this.profile});

  final TimelineProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final previous = profile.previousUsername;
    final tag = switch (profile.kind) {
      TimelineProfileKind.missing => null,
      TimelineProfileKind.renamed => context.l10n.timelineRenamed,
      TimelineProfileKind.possiblyDeleted =>
        context.l10n.timelinePossiblyDeleted,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimelineItemTitle('@${profile.user.username}'),
        if (previous != null)
          Text(
            context.l10n.timelinePreviousUsername('@$previous'),
            style: theme.textTheme.bodySmall,
          ),
        if (tag != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tag,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _IntervalDates extends StatelessWidget {
  const _IntervalDates({required this.interval});
  final UnfollowInterval interval;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final format = DateFormat(
      context.l10n.localeName == 'it' ? 'dd/MM/yyyy' : 'MM/dd/yyyy',
    );
    final previous = format.format(interval.previousDate);
    final current = format.format(interval.currentDate);
    return Semantics(
      label: context.l10n.dateInterval(
        (previous).toString(),
        (current).toString(),
      ),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, right: 12, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              context.l10n.from,
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
              context.l10n.to,
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
