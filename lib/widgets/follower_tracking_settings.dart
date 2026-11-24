import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/follower_tracking_service.dart';
import 'settings_toggle_tile.dart';

class FollowerTrackingSettings extends StatefulWidget {
  const FollowerTrackingSettings({super.key, required this.isSamsung});

  final bool isSamsung;

  @override
  State<FollowerTrackingSettings> createState() =>
      _FollowerTrackingSettingsState();
}

class _FollowerTrackingSettingsState extends State<FollowerTrackingSettings> {
  static final _validUsername = RegExp(r'^[a-zA-Z0-9_.]{1,30}$');
  String? _username;
  bool _enabled = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (FollowerTrackingService.supported) _update();
  }

  Future<void> _update([Future<bool> Function()? action]) async {
    setState(() => _busy = true);
    try {
      final saved = await action?.call() ?? true;
      final state = await FollowerTrackingService.state();
      if (!mounted) return;
      setState(() {
        _username = state.username;
        _enabled = state.enabled;
      });
      if (!saved) _showMessage(context.l10n.followerTrackingUnavailable);
    } on Exception {
      if (mounted) _showMessage(context.l10n.followerTrackingError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editProfile() async {
    final form = GlobalKey<FormState>();
    var input = _username ?? '';
    String normalized() => input.trim().replaceFirst(RegExp(r'^@'), '');
    final username = await showDialog<String>(
      context: context,
      builder: (context) {
        void submit() {
          if (form.currentState?.validate() == true) {
            Navigator.of(context).pop(normalized());
          }
        }

        return AlertDialog(
          title: Text(
            _username == null
                ? context.l10n.followerTrackingAdd
                : context.l10n.followerTrackingEdit,
          ),
          content: Form(
            key: form,
            child: TextFormField(
              initialValue: input,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: context.l10n.followerTrackingUsername,
                prefixText: '@',
              ),
              onChanged: (value) => input = value,
              onFieldSubmitted: (_) => submit(),
              validator: (_) {
                final name = normalized().toLowerCase();
                return _validUsername.hasMatch(name) &&
                        name != '.' &&
                        name != '..' &&
                        !name.startsWith('debug_')
                    ? null
                    : context.l10n.followerTrackingInvalidUsername;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: submit,
              child: Text(context.l10n.followerTrackingSave),
            ),
          ],
        );
      },
    );
    if (!mounted || username == null) return;
    await _update(() => FollowerTrackingService.setProfile(username));
  }

  @override
  Widget build(BuildContext context) {
    final supported = FollowerTrackingService.supported;
    final username = _username;
    final strings = context.l10n;
    final description = strings.followerTrackingDescription;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          SettingsToggleTile(
            title: strings.followerTrackingAutomatic,
            subtitle: !supported
                ? strings.androidOnly
                : username == null
                ? '$description ${strings.followerTrackingChooseProfile}'
                : description,
            isSamsung: widget.isSamsung,
            value: _enabled,
            onChanged: supported && !_busy && username != null
                ? (value) =>
                      _update(() => FollowerTrackingService.setEnabled(value))
                : null,
          ),
          if (supported)
            ListTile(
              enabled: !_busy,
              leading: Icon(
                username == null
                    ? Icons.person_add_outlined
                    : Icons.edit_outlined,
              ),
              title: Text(
                username == null
                    ? context.l10n.followerTrackingAdd
                    : context.l10n.followerTrackingEdit,
              ),
              subtitle: username == null ? null : Text('@$username'),
              onTap: _busy ? null : _editProfile,
              trailing: username == null
                  ? null
                  : IconButton(
                      tooltip: context.l10n.followerTrackingRemove,
                      icon: const Icon(Icons.close),
                      onPressed: _busy
                          ? null
                          : () => _update(
                              () => FollowerTrackingService.setProfile(null),
                            ),
                    ),
            ),
        ],
      ),
    );
  }
}
