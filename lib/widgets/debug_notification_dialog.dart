import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

class DebugNotificationDialog extends StatefulWidget {
  const DebugNotificationDialog({super.key});

  @override
  State<DebugNotificationDialog> createState() =>
      _DebugNotificationDialogState();
}

class _DebugNotificationDialogState extends State<DebugNotificationDialog> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController(text: '10');
  int _unit = 1000;

  int? _milliseconds(String? text) {
    final amount = double.tryParse((text ?? '').trim().replaceAll(',', '.'));
    if (amount == null || !amount.isFinite || amount <= 0) return null;
    final milliseconds = amount * _unit;
    if (milliseconds < 1 || milliseconds > 8000000000000000) return null;
    return milliseconds.round();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.scheduleTestNotification),
    content: SingleChildScrollView(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: context.l10n.notificationDelay,
              ),
              validator: (value) => _milliseconds(value) == null
                  ? context.l10n.invalidNotificationDelay
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _unit,
              decoration: InputDecoration(labelText: context.l10n.timeUnit),
              items: [
                DropdownMenuItem(
                  value: 1,
                  child: Text(context.l10n.milliseconds),
                ),
                DropdownMenuItem(
                  value: 1000,
                  child: Text(context.l10n.seconds),
                ),
                DropdownMenuItem(
                  value: 60000,
                  child: Text(context.l10n.minutes),
                ),
                DropdownMenuItem(
                  value: 3600000,
                  child: Text(context.l10n.hours),
                ),
                DropdownMenuItem(
                  value: 86400000,
                  child: Text(context.l10n.days),
                ),
              ],
              onChanged: (value) => setState(() => _unit = value!),
            ),
            const SizedBox(height: 16),
            Text(context.l10n.notificationDelayDescription),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(
              context,
              Duration(milliseconds: _milliseconds(_amount.text)!),
            );
          }
        },
        child: Text(context.l10n.schedule),
      ),
    ],
  );
}
