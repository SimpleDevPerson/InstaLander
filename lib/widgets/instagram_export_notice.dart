import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_strings.dart';

/// Shown after the first successful import of both follower lists.
Future<void> showInstagramExportNoticeIfNeeded(BuildContext context) async {
  const preferenceKey = 'instagram_export_notice_shown';
  final preferences = await SharedPreferences.getInstance();
  if (!context.mounted || preferences.getBool(preferenceKey) == true) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.info_outline_rounded),
      title: Text(context.l10n.ghostProfilesTitle),
      content: SingleChildScrollView(
        child: Text(context.l10n.ghostProfilesDescription),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.gotIt),
        ),
      ],
    ),
  );
  await preferences.setBool(preferenceKey, true);
}
