import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

class WhitelistFab extends StatefulWidget {
  final int count;
  final bool isOpen;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final List<String> whitelist;
  final Function(String) onRemove;

  const WhitelistFab({
    super.key,
    required this.count,
    required this.isOpen,
    required this.onTap,
    required this.onClose,
    required this.whitelist,
    required this.onRemove,
  });

  @override
  State<WhitelistFab> createState() => _WhitelistFabState();
}

class _WhitelistFabState extends State<WhitelistFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;
  late Animation<double> _borderRadiusAnimation;
  late Animation<double> _panelOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: 190,
      end: 320,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _heightAnimation = Tween<double>(
      begin: 52,
      end: 420,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _borderRadiusAnimation = Tween<double>(
      begin: 30,
      end: 16,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _panelOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.isOpen) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(WhitelistFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.isOpen ? null : widget.onTap,
          child: Container(
            width: _widthAnimation.value,
            height: _heightAnimation.value,
            decoration: BoxDecoration(
              color: AppTheme.getCardBg(context),
              border: Border.all(
                color: widget.isOpen
                    ? AppTheme.getBorderColor(context)
                    : (AppTheme.getBorderColor(context)),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(_borderRadiusAnimation.value),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Closed state content
                Opacity(
                  opacity: 1 - _controller.value,
                  child: Center(
                    child: Text(
                      context.l10n.manageWhitelist,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                  ),
                ),

                // Open state content
                Opacity(
                  opacity: _panelOpacityAnimation.value,
                  child: IgnorePointer(
                    ignoring: !widget.isOpen,
                    child: _buildPanel(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPanel(BuildContext context) {
    final sortedWhitelist = List<String>.from(widget.whitelist)..sort();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppTheme.getBorderColor(context)),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.yourWhitelist,
                style: Theme.of(
                  context,
                ).textTheme.displayMedium?.copyWith(fontSize: 18),
              ),
              GestureDetector(
                onTap: widget.onClose,
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: AppTheme.getSubTextColor(context),
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: sortedWhitelist.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      context.l10n.whitelistIsEmpty,
                      style: TextStyle(
                        color: AppTheme.getSubTextColor(context),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: sortedWhitelist.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppTheme.getBorderColor(context),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final username = sortedWhitelist[index];
                    return _WhitelistItem(
                      username: username,
                      onRemove: () => widget.onRemove(username),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _WhitelistItem extends StatelessWidget {
  final String username;
  final VoidCallback onRemove;

  const _WhitelistItem({required this.username, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '@$username',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.getTextColor(context),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(5),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.instagramRed,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  context.l10n.remove,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
