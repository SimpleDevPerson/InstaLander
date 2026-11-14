import 'package:android_file_picker/android_file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/services/data_service.dart';

final class _PickedFile extends PlatformFile {
  _PickedFile(this.name, this.uri);

  @override
  final String name;
  @override
  final Uri uri;
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(
    'com.simpledevperson.instalander/file_metadata',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final first = _PickedFile(
    'followers_1.json',
    Uri.parse('content://exports/1'),
  );
  final second = _PickedFile(
    'following.json',
    Uri.parse('content://exports/2'),
  );

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'Android reads the source document instead of the cached copy',
    () async {
      final source = Uri.parse('content://exports/original');
      final file = AndroidPlatformFile(
        name: 'followers_1.json',
        uri: Uri.file('/cache/copied.json'),
        safHandle: AndroidSAFHandle(
          accessMode: AndroidSAFAccessMode.readOnly,
          uri: source,
        ),
      );
      final date = DateTime(2026, 5, 3);
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.arguments, source.toString());
        return date.millisecondsSinceEpoch;
      });
      expect(await DataService.jsonFilesCreationDate([file]), date);
      expect(
        await DataService.jsonFilesCreationDate([
          AndroidPlatformFile(name: file.name, uri: file.uri),
        ]),
        isNull,
      );
    },
  );

  test(
    'reads creation metadata from original URI and chooses latest file',
    () async {
      final earlier = DateTime(2026, 5, 3, 9);
      final later = DateTime(2026, 5, 3, 10);
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'creationDate');
        expect(
          call.arguments,
          anyOf(first.uri.toString(), second.uri.toString()),
        );
        return (call.arguments == first.uri.toString() ? earlier : later)
            .millisecondsSinceEpoch;
      });
      expect(await DataService.jsonFilesCreationDate([first, second]), later);
    },
  );

  test('requests manual date if any file has no creation time', () async {
    for (final missing in [null, 0, -1]) {
      messenger.setMockMethodCallHandler(
        channel,
        (call) async => call.arguments == first.uri.toString()
            ? DateTime(2026, 5, 3).millisecondsSinceEpoch
            : missing,
      );
      expect(await DataService.jsonFilesCreationDate([first, second]), isNull);
    }
  });

  test(
    'unavailable platform and metadata read errors allow manual date',
    () async {
      expect(await DataService.jsonFilesCreationDate([first]), isNull);
      messenger.setMockMethodCallHandler(channel, (_) async {
        throw PlatformException(code: 'access_denied');
      });
      expect(await DataService.jsonFilesCreationDate([first]), isNull);
      expect(await DataService.jsonFilesCreationDate([]), isNull);
    },
  );
}
