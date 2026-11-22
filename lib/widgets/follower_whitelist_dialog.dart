import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_strings.dart';
import '../services/profile_photo_service.dart';

class FollowerWhitelistDialog extends StatefulWidget {
  const FollowerWhitelistDialog({
    super.key,
    required this.usernames,
    required this.addProfiles,
    this.profileService,
  });

  final List<String> usernames;
  final Future<int> Function(Set<String>) addProfiles;
  final ProfilePhotoService? profileService;

  @override
  State<FollowerWhitelistDialog> createState() =>
      _FollowerWhitelistDialogState();
}

class _FollowerWhitelistDialogState extends State<FollowerWhitelistDialog>
    with WidgetsBindingObserver {
  int? _threshold;
  int _checked = 0;
  int _unavailable = 0;
  int? _added;
  bool _checking = false;
  bool _saving = false;
  bool _cancelled = false;
  bool _rateLimited = false;
  String? _error;
  Completer<void>? _resume;
  int _foregroundGeneration = 0;

  bool get _needsResults => mounted && !_cancelled;

  @override
  void initState() {
    super.initState();
    final binding = WidgetsBinding.instance;
    binding.addObserver(this);
    final lifecycle = binding.lifecycleState;
    if (lifecycle != null) didChangeAppLifecycleState(lifecycle);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _releaseScan();
    } else if (_resume == null) {
      _resume = Completer<void>();
      _foregroundGeneration++;
    }
  }

  void _releaseScan() {
    _resume?.complete();
    _resume = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelled = true;
    _releaseScan();
    super.dispose();
  }

  Future<void> _scan(int threshold) async {
    setState(() => _checking = true);
    final service = widget.profileService ?? ProfilePhotoService.instance;
    final matches = <String>{};
    while (_needsResults && _checked < widget.usernames.length) {
      final resume = _resume;
      if (resume != null) {
        await resume.future;
        continue;
      }
      final username = widget.usernames[_checked];
      final generation = _foregroundGeneration;
      final count = await service.loadFollowerCount(
        username,
        isNeeded: () => _needsResults && generation == _foregroundGeneration,
      );
      if (!_needsResults) return;
      // A quick lock and unlock can finish before the old request returns.
      // Discard that result and retry the same profile in the foreground.
      if (generation != _foregroundGeneration) continue;
      if (count == null && service.isRateLimited) {
        _rateLimited = true;
        break;
      }
      if (count == null) {
        _unavailable++;
      } else if (count > threshold) {
        matches.add(username);
      }
      setState(() => _checked++);
    }
    if (!_needsResults) return;
    setState(() {
      _checking = false;
      _saving = true;
    });
    try {
      final added = await widget.addProfiles(matches);
      if (mounted) setState(() => _added = added);
    } catch (error) {
      if (mounted) {
        setState(() => _error = context.l10n.saveWhitelistError('$error'));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final threshold = _threshold;
    final added = _added;
    final error = _error;
    final finished = added != null || error != null;

    return PopScope(
      canPop: !_saving && !_checking,
      child: AlertDialog(
        title: Text(strings.followerWhitelistTitle),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (finished) ...[
              if (added != null)
                Text(
                  strings.followerWhitelistResult('$added', '$_unavailable'),
                ),
              if (error != null) Text(error),
              if (_rateLimited && added != null) ...[
                const SizedBox(height: 12),
                Text(strings.followerWhitelistRateLimited),
              ],
            ] else if (_checking || _saving) ...[
              LinearProgressIndicator(
                value: _saving ? null : _checked / widget.usernames.length,
              ),
              const SizedBox(height: 12),
              Text(
                strings.followerWhitelistProgress(
                  '$_checked',
                  '${widget.usernames.length}',
                ),
              ),
            ] else ...[
              Text(strings.followerWhitelistDescription),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: strings.followerWhitelistThreshold,
                ),
                onChanged: (value) =>
                    setState(() => _threshold = int.tryParse(value)),
              ),
            ],
          ],
        ),
        actions: [
          if (!_saving)
            TextButton(
              onPressed: () {
                _cancelled = true;
                _releaseScan();
                Navigator.of(context).pop();
              },
              child: Text(
                finished
                    ? MaterialLocalizations.of(context).closeButtonLabel
                    : strings.cancel,
              ),
            ),
          if (!finished && !_checking && !_saving)
            FilledButton(
              onPressed: threshold == null || widget.usernames.isEmpty
                  ? null
                  : () => _scan(threshold),
              child: Text(strings.followerWhitelistStart),
            ),
        ],
      ),
    );
  }
}
