import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      title: const Text('Possibili profili “fantasma”'),
      content: const SingleChildScrollView(
        child: Text(
          'Nei JSON esportati da Instagram possono comparire profili '
          '“fantasma”: account che non segui più oppure che sono stati '
          'eliminati.\n\n'
          'Queste incongruenze dipendono dai dati forniti da Instagram, '
          'non da un errore dell’app. InstaLander elabora le informazioni '
          'presenti nei file che hai caricato.',
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ho capito'),
        ),
      ],
    ),
  );
  await preferences.setBool(preferenceKey, true);
}
