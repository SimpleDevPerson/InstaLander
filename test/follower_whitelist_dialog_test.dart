import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/services/profile_photo_service.dart';
import 'package:instalander/widgets/follower_whitelist_dialog.dart';

class _ControlledProfiles extends ProfilePhotoService {
  final requests = <String>[];
  final pending = <Completer<int?>>[];
  final needed = <bool Function()>[];

  @override
  Future<int?> loadFollowerCount(
    String username, {
    required bool Function() isNeeded,
  }) {
    requests.add(username);
    needed.add(isNeeded);
    final result = Completer<int?>();
    pending.add(result);
    return result.future;
  }
}

void main() {
  testWidgets('retries the interrupted profile and preserves scan progress', (
    tester,
  ) async {
    final service = _ControlledProfiles();
    final binding = tester.binding;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    Set<String>? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FollowerWhitelistDialog(
            usernames: const ['first', 'second', 'third'],
            addProfiles: (matches) async {
              saved = matches;
              return matches.length;
            },
            profileService: service,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '100');
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    service.pending[0].complete(200);
    await tester.pump();
    expect(service.requests, ['first', 'second']);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(service.needed[1](), isFalse);
    service.pending[1].complete(null);
    await tester.pump();
    expect(service.requests, ['first', 'second']);
    expect(saved, isNull);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(service.requests, ['first', 'second', 'second']);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(service.needed[2](), isFalse);
    service.pending[2].complete(null);
    await tester.pump();
    expect(service.requests, ['first', 'second', 'second', 'second']);
    service.pending[3].complete(150);
    await tester.pump();
    service.pending[4].complete(100);
    await tester.pumpAndSettle();

    expect(service.requests.last, 'third');
    expect(saved, {'first', 'second'});
    expect(find.textContaining('Conteggio non disponibile: 0'), findsOneWidget);
  });
}
