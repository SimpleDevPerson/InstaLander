import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_strings.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';

class UserCard extends StatefulWidget {
  final InstagramUser user;
  final bool isViewed;
  final Future<void> Function() onTap;
  final VoidCallback onWhitelist;

  const UserCard({
    super.key,
    required this.user,
    required this.isViewed,
    required this.onTap,
    required this.onWhitelist,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  static const _actionBackground = Color(0xFF2B2B2B);
  static const _actionBorder = Color(0xFF666666);
  static const _expansionDuration = Duration(milliseconds: 220);

  final _expandedOverlayKey = GlobalKey<_ExpandedUserCardOverlayState>();
  OverlayEntry? _expandedOverlayEntry;

  static const _avatarBlues = [
    Color(0xFF1565C0),
    Color(0xFF1976D2),
    Color(0xFF1E88E5),
    Color(0xFF0288D1),
    Color(0xFF039BE5),
    Color(0xFF3949AB),
    Color(0xFF3F51B5),
    Color(0xFF00838F),
  ];

  Color _avatarColor(String username) {
    final usernameHash = username.codeUnits.fold<int>(
      0,
      (hash, codeUnit) => hash * 31 + codeUnit,
    );
    return _avatarBlues[usernameHash.abs() % _avatarBlues.length];
  }

  void _showExpandedCard() {
    if (_expandedOverlayEntry != null) return;

    final cardRenderBox = context.findRenderObject()! as RenderBox;
    final overlay = Overlay.of(context, rootOverlay: true);
    final overlayRenderBox = overlay.context.findRenderObject()! as RenderBox;
    final cardOrigin = cardRenderBox.localToGlobal(
      Offset.zero,
      ancestor: overlayRenderBox,
    );
    final cardRect = cardOrigin & cardRenderBox.size;

    _expandedOverlayEntry = OverlayEntry(
      builder: (context) => _ExpandedUserCardOverlay(
        key: _expandedOverlayKey,
        user: widget.user,
        origin: cardRect,
        onOpenProfile: widget.onTap,
        onWhitelist: widget.onWhitelist,
        onDismissed: _removeExpandedCard,
      ),
    );
    overlay.insert(_expandedOverlayEntry!);
  }

  void _updateExpandedCardPointer(Offset position) {
    _expandedOverlayKey.currentState?.updatePointer(position);
  }

  void _finishExpandedCardPointer(Offset position) {
    _expandedOverlayKey.currentState?.finishPointer(position);
  }

  void _removeExpandedCard() {
    _expandedOverlayEntry?.remove();
    _expandedOverlayEntry?.dispose();
    _expandedOverlayEntry = null;
  }

  @override
  void dispose() {
    _removeExpandedCard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColor(widget.user.username);
    final colorScheme = Theme.of(context).colorScheme;
    final username = widget.user.username.isNotEmpty
        ? widget.user.username[0].toUpperCase()
        : '?';

    return GestureDetector(
      onLongPressStart: (_) => _showExpandedCard(),
      onLongPressMoveUpdate: (details) =>
          _updateExpandedCardPointer(details.globalPosition),
      onLongPressEnd: (details) =>
          _finishExpandedCardPointer(details.globalPosition),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 3,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: widget.onTap,
                        customBorder: const CircleBorder(),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (widget.isViewed
                                            ? AppTheme.instagramGradientMid
                                            : avatarColor)
                                        .withValues(alpha: 0.32),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: EdgeInsets.all(widget.isViewed ? 3 : 0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: widget.isViewed
                                  ? AppTheme.instagramGradient
                                  : null,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.isViewed ? null : avatarColor,
                                gradient: widget.isViewed
                                    ? AppTheme.instagramGradient
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.onTap,
                              borderRadius: BorderRadius.circular(4),
                              child: Text(
                                '@${widget.user.username}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 14,
                                color: AppTheme.getSubTextColor(context),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.user.followedAt == null
                                      ? context.l10n.unknownDate
                                      : DateFormat(
                                          context.l10n.localeName == 'it'
                                              ? 'dd/MM/yyyy'
                                              : 'MM/dd/yyyy',
                                        ).format(widget.user.followedAt!),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox.square(
                    dimension: 50,
                    child: _buildProfileButton(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onWhitelist,
                      icon: const Icon(Icons.favorite_border, size: 20),
                      label: Text(context.l10n.whitelist),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: _actionBorder),
                        backgroundColor: _actionBackground,
                        minimumSize: const Size(0, 50),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isViewed ? null : _actionBackground,
            gradient: widget.isViewed ? AppTheme.instagramGradient : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _actionBorder),
          ),
          child: const Icon(
            Icons.open_in_new_rounded,
            size: 22,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ExpandedUserCardOverlay extends StatefulWidget {
  final InstagramUser user;
  final Rect origin;
  final Future<void> Function() onOpenProfile;
  final VoidCallback onWhitelist;
  final VoidCallback onDismissed;

  const _ExpandedUserCardOverlay({
    super.key,
    required this.user,
    required this.origin,
    required this.onOpenProfile,
    required this.onWhitelist,
    required this.onDismissed,
  });

  @override
  State<_ExpandedUserCardOverlay> createState() =>
      _ExpandedUserCardOverlayState();
}

class _ExpandedUserCardOverlayState extends State<_ExpandedUserCardOverlay> {
  bool _isExpanded = false;
  bool _isDismissing = false;
  int? _hoveredAction;
  final _actionRowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isExpanded = true);
    });
  }

  void dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    setState(() => _isExpanded = false);
    Future<void>.delayed(_UserCardState._expansionDuration, () {
      if (mounted) widget.onDismissed();
    });
  }

  void updatePointer(Offset globalPosition) {
    if (_isDismissing) return;
    final hoveredAction = _actionAt(globalPosition);
    if (_hoveredAction != hoveredAction) {
      setState(() => _hoveredAction = hoveredAction);
    }
  }

  void finishPointer(Offset globalPosition) {
    final action = _actionAt(globalPosition) ?? _hoveredAction;
    dismiss();
    switch (action) {
      case 0:
        unawaited(widget.onOpenProfile());
      case 1:
        widget.onWhitelist();
      case null:
        break;
    }
  }

  int? _actionAt(Offset position) {
    final renderBox =
        _actionRowKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    final localPosition = renderBox.globalToLocal(position);
    if (!(Offset.zero & renderBox.size).contains(localPosition)) return null;
    return localPosition.dx < renderBox.size.width / 2 ? 0 : 1;
  }

  Widget _buildActionButton(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHovered = _hoveredAction == index;
    return AnimatedScale(
      scale: isHovered ? 1.04 : 1,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isHovered
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered ? colorScheme.primary : colorScheme.outlineVariant,
            width: isHovered ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: colorScheme.onSurface),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - 40).clamp(0.0, 360.0);
          final cardHeight = (constraints.maxHeight - 96).clamp(0.0, 420.0);
          final targetLeft = (constraints.maxWidth - cardWidth) / 2;
          final contentHeight = cardHeight + 80;
          final targetTop = (constraints.maxHeight - contentHeight) / 2;
          final originLeft = widget.origin.left
              .clamp(0.0, constraints.maxWidth)
              .toDouble();
          final originTop = widget.origin.top
              .clamp(0.0, constraints.maxHeight)
              .toDouble();

          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: dismiss,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: AnimatedContainer(
                        duration: _UserCardState._expansionDuration,
                        color: Colors.black.withValues(
                          alpha: _isExpanded ? 0.48 : 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: _UserCardState._expansionDuration,
                curve: Curves.easeOutCubic,
                left: _isExpanded ? targetLeft : originLeft,
                top: _isExpanded ? targetTop : originTop,
                width: _isExpanded ? cardWidth : widget.origin.width,
                height: _isExpanded ? cardHeight : widget.origin.height,
                child: Material(
                  color: colorScheme.surfaceContainerHighest,
                  elevation: 12,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: colorScheme.outline, width: 1.5),
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 140),
                    opacity: _isExpanded ? 1 : 0,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  context.l10n.profileDetails,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                child: Text(
                                  widget.user.username.isEmpty
                                      ? '?'
                                      : widget.user.username[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  '@${widget.user.username}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.followedOn,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        widget.user.followedAt == null
                                            ? context.l10n.unknownDate
                                            : DateFormat(
                                                context.l10n.localeName == 'it'
                                                    ? 'dd/MM/yyyy • HH:mm'
                                                    : 'MM/dd/yyyy • HH:mm',
                                              ).format(widget.user.followedAt!),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: colorScheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer.withValues(
                                alpha: 0.45,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_remove_outlined,
                                  size: 17,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  context.l10n.doesNotFollowBack,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.dragToSelect,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: _UserCardState._expansionDuration,
                curve: Curves.easeOutCubic,
                left: _isExpanded ? targetLeft : originLeft,
                top: _isExpanded
                    ? targetTop + cardHeight + 12
                    : originTop + widget.origin.height,
                width: _isExpanded ? cardWidth : widget.origin.width,
                height: 68,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 140),
                  opacity: _isExpanded ? 1 : 0,
                  child: Row(
                    key: _actionRowKey,
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          index: 0,
                          icon: Icons.open_in_new_rounded,
                          label: 'Instagram',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          index: 1,
                          icon: Icons.favorite_border,
                          label: context.l10n.whitelist,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
