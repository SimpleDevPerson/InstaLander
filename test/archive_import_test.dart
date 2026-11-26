import 'dart:convert';
import 'dart:io';

import 'package:android_file_picker/android_file_picker.dart';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/models/import_snapshot.dart';
import 'package:instalander/models/username_change.dart';
import 'package:instalander/providers/app_provider.dart';
import 'package:instalander/providers/theme_provider.dart';
import 'package:instalander/screens/main_screen.dart';
import 'package:instalander/services/data_service.dart';
import 'package:instalander/services/history_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<int> _profiles(List<String> users) => utf8.encode(
  jsonEncode([
    for (final user in users)
      {
        'string_list_data': [
          {'value': user, 'timestamp': 1},
        ],
      },
  ]),
);

final class _ZipFile extends PlatformFile {
  _ZipFile(Map<String, List<int>> files) : bytes = _encode(files);
  static Uint8List _encode(Map<String, List<int>> files) {
    final archive = Archive();
    for (final entry in files.entries) {
      archive.add(
        ArchiveFile(
          'followers_and_following/${entry.key}',
          entry.value.length,
          entry.value,
        ),
      );
    }
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  final Uint8List bytes;
  @override
  Future<Uint8List> readAsBytes() async => bytes;
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _ImportProvider extends AppProvider {
  _ImportProvider(this.existing);
  final bool existing;
  final imports = <(ArchiveImportMode, DateTime?)>[];
  @override
  bool get isLoading => false;
  @override
  bool get hasData => existing;
  @override
  bool get hasFollowersFile => existing;
  @override
  bool get hasFollowingFile => existing;
  @override
  bool get shouldShowOnboarding => false;
  @override
  Future<void> initialize() async {}
  @override
  Future<void> loadInstagramArchive(
    PlatformFile archiveFile, {
    DateTime? exportDate,
    ArchiveImportMode mode = ArchiveImportMode.all,
    ResolveUsernameChanges? resolveUsernameChanges,
  }) async => imports.add((mode, exportDate));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  const pickerChannel = MethodChannel('miguelruivo.flutter.plugins.filepicker');
  const metadataChannel = MethodChannel(
    'com.simpledevperson.instalander/file_metadata',
  );
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('instalander_zip_');
    SharedPreferences.setMockInitialValues({
      'instagram_export_notice_shown': true,
    });
    messenger.setMockMethodCallHandler(
      pathChannel,
      (_) async => directory.path,
    );
  });
  tearDown(() async {
    for (final channel in [pathChannel, pickerChannel, metadataChannel]) {
      messenger.setMockMethodCallHandler(channel, null);
    }
    await directory.delete(recursive: true);
  });

  Future<void> seed() => HistoryService.importFiles(
    {
      'followers_1.json': _profiles(['kept', 'lost']),
      'following.json': _profiles(['kept', 'lost', 'manual']),
    },
    date: DateTime(2026, 1, 1),
    path: directory.path,
  );

  test('followers-only ZIP keeps following and history', () async {
    await seed();
    await DataService.saveWhitelist({'manual'});
    await DataService.saveInstagramArchive(
      _ZipFile({
        'followers_1.json': _profiles(['kept']),
        'following.json': _profiles(['replacement']),
      }),
      exportDate: DateTime(2026, 2, 1),
      mode: ArchiveImportMode.followersOnly,
    );
    final history = await HistoryService.load(path: directory.path);
    expect(history, hasLength(2));
    expect(history.last.followers.keys, ['kept']);
    expect(history.last.following.keys, ['kept', 'lost', 'manual']);
    expect(history.last.followingImported, isFalse);
    expect((await DataService.loadWhitelist()), contains('manual'));
    expect(
      (await HistoryService.loadTimeline(
        path: directory.path,
      )).single.users.single.username,
      'lost',
    );
  });

  test(
    'restart accepts same ZIP, replaces history and clears whitelist',
    () async {
      await seed();
      await DataService.saveWhitelist({'manual'});
      await DataService.saveInstagramArchive(
        _ZipFile({
          'followers_1.json': _profiles(['kept', 'lost']),
          'following.json': _profiles(['replacement']),
        }),
        exportDate: DateTime(2025, 12, 1),
        mode: ArchiveImportMode.restart,
      );
      final history = await HistoryService.load(path: directory.path);
      expect(history, hasLength(1));
      expect(history.single.following.keys, ['replacement']);
      expect(await DataService.loadWhitelist(), isEmpty);
      expect(await HistoryService.loadTimeline(path: directory.path), isEmpty);
    },
  );

  test(
    'invalid or incomplete restart leaves all saved data untouched',
    () async {
      await seed();
      await DataService.saveWhitelist({'manual'});
      final state = File('${directory.path}/${HistoryService.fileName}');
      final before = await state.readAsString();
      for (final files in [
        {
          'followers_1.json': _profiles(['new']),
        },
        {
          'following.json': _profiles(['new']),
        },
        {
          'followers_1.json': _profiles(['new']),
          'following.json': utf8.encode('{bad'),
        },
      ]) {
        await expectLater(
          DataService.saveInstagramArchive(
            _ZipFile(files),
            mode: ArchiveImportMode.restart,
          ),
          throwsFormatException,
        );
        expect(await state.readAsString(), before);
      }
    },
  );

  for (final (choice, metadataAvailable, cancelCalendar) in [
    (null, true, false),
    (ArchiveImportMode.followersOnly, true, false),
    (ArchiveImportMode.restart, true, false),
    (ArchiveImportMode.all, true, false),
    (ArchiveImportMode.all, false, false),
    (ArchiveImportMode.all, false, true),
    (ArchiveImportMode.followersOnly, false, false),
    (ArchiveImportMode.restart, false, true),
  ]) {
    testWidgets(
      'ZIP choice $choice metadata $metadataAvailable cancel calendar $cancelCalendar',
      (tester) async {
        final existing = choice != ArchiveImportMode.all;
        final app = _ImportProvider(existing);
        final theme = ThemeProvider();
        final previousPicker = FilePickerPlatform.instance;
        FilePickerAndroid.registerWith();
        addTearDown(() => FilePickerPlatform.instance = previousPicker);
        messenger.setMockMethodCallHandler(
          pickerChannel,
          (_) async => [
            {
              'name': 'instagram.zip',
              'path': '${directory.path}/instagram.zip',
              'safHandle': {
                'uri': 'content://exports/instagram.zip',
                'access': 'readOnly',
              },
            },
          ],
        );
        final date = DateTime(2026, 5, 3);
        messenger.setMockMethodCallHandler(
          metadataChannel,
          (_) async => metadataAvailable ? date.millisecondsSinceEpoch : null,
        );
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AppProvider>.value(value: app),
              ChangeNotifierProvider<ThemeProvider>.value(value: theme),
            ],
            child: const MaterialApp(home: MainScreen()),
          ),
        );
        await tester.pumpAndSettle();
        final button = find.text(existing ? 'Importa' : 'Carica archivio ZIP');
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        if (existing || metadataAvailable) {
          expect(find.byType(DatePickerDialog), findsNothing);
        }
        if (existing) {
          expect(find.text('Come vuoi importare lo ZIP?'), findsOneWidget);
          await tester.tap(
            find.text(switch (choice) {
              ArchiveImportMode.followersOnly => 'Solo follower',
              ArchiveImportMode.restart => 'Ricomincia da zero',
              _ => 'Annulla',
            }),
          );
          await tester.pumpAndSettle();
        } else {
          expect(find.text('Come vuoi importare lo ZIP?'), findsNothing);
        }
        if (!metadataAvailable && choice != null) {
          final calendar = find.byType(DatePickerDialog);
          expect(calendar, findsOneWidget);
          expect(app.imports, isEmpty);
          await tester.tap(
            find.descendant(
              of: calendar,
              matching: find.text(cancelCalendar ? 'Annulla' : 'Importa'),
            ),
          );
          await tester.pumpAndSettle();
        }
        expect(find.byType(DatePickerDialog), findsNothing);
        if (choice == null || cancelCalendar) {
          expect(app.imports, isEmpty);
        } else if (metadataAvailable) {
          expect(app.imports, [(choice, date)]);
        } else {
          expect(app.imports.single.$1, choice);
          expect(
            DateUtils.dateOnly(app.imports.single.$2!),
            DateUtils.dateOnly(DateTime.now()),
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        app.dispose();
        theme.dispose();
      },
    );
  }
}
