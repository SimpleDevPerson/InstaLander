import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Data sconosciuta';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  widget.user.username.isNotEmpty
                      ? widget.user.username[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Username button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient:
                        widget.isViewed ? AppTheme.instagramGradient : null,
                    color: widget.isViewed ? null : AppTheme.instagramBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '@${widget.user.username}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Whitelist button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onWhitelist,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.getTextColor(context),
                  side: BorderSide.none,
                  backgroundColor: AppTheme.getWlBtnBg(context),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: AppTheme.getSubTextColor(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Salva in Whitelist',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Timestamp (small text below)
            if (widget.user.followedAt != null) ...[
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Seguito il: ${_formatDate(widget.user.followedAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getSubTextColor(context),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
