import 'package:android_file_picker/android_file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/services/data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('miguelruivo.flutter.plugins.filepicker');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    final previousPlatform = FilePickerPlatform.instance;
    FilePickerAndroid.registerWith();
    addTearDown(() {
      FilePickerPlatform.instance = previousPlatform;
      messenger.setMockMethodCallHandler(channel, null);
    });
  });

  for (final extension in ['json', 'zip']) {
    test('$extension import requests only temporary read access', () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return <Map<String, Object?>>[];
      });

      final result = extension == 'json'
          ? await DataService.pickJsonFiles()
          : await DataService.pickInstagramArchive();

      expect(result, isNull); // Cancelling leaves the current import untouched.
      expect(calls, hasLength(1));
      expect(calls.single.method, 'custom');
      final args = calls.single.arguments as Map;
      expect(args['allowedExtensions'], [extension]);
      expect(args['allowMultipleSelection'], extension == 'json');
      expect(args['androidSafOptions'], {
        'grant': 'transient',
        'access': 'readOnly',
        'autoPersist': false,
      });
    });
  }
}
