import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_strings.dart';
import '../models/username_change.dart';

class UsernameChangesDialog extends StatefulWidget {
  const UsernameChangesDialog({super.key, required this.candidates});
  final List<UsernameChangeCandidate> candidates;

  @override
  State<UsernameChangesDialog> createState() => _UsernameChangesDialogState();
}

class _UsernameChangesDialogState extends State<UsernameChangesDialog> {
  final _selected = <String, String>{};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.possibleUsernameChanges),
      content: SizedBox(
        width: 560,
        height: (MediaQuery.sizeOf(context).height * 0.45).clamp(160.0, 360.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.usernameChangesDescription),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: widget.candidates.length,
                separatorBuilder: (_, _) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final candidate = widget.candidates[index];
                  final oldName = candidate.previous.username;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@$oldName',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        context.l10n.followDate(
                          (DateFormat(
                            context.l10n.localeName == 'it'
                                ? 'dd/MM/yyyy HH:mm:ss'
                                : 'MM/dd/yyyy HH:mm:ss',
                          ).format(candidate.previous.followedAt!)).toString(),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        key: ValueKey('rename-$oldName'),
                        initialValue: _selected[oldName] ?? '',
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: context.l10n.newUsername,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: '',
                            child: Text(context.l10n.noMatch),
                          ),
                          for (final user in candidate.possibleMatches)
                            DropdownMenuItem(
                              value: user.username,
                              enabled: !_selected.entries.any(
                                (e) =>
                                    e.key != oldName &&
                                    e.value == user.username,
                              ),
                              child: Text(
                                '@${user.username}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (name) => setState(() {
                          if (name == null || name.isEmpty) {
                            _selected.remove(oldName);
                          } else {
                            _selected[oldName] = name;
                          }
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancelImport),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, <String, String>{}),
          child: Text(context.l10n.ignoreAll),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, Map<String, String>.of(_selected)),
          child: Text(context.l10n.confirmImport),
        ),
      ],
    );
  }
}
