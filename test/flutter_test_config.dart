import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/l10n/app_strings.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    // Existing UI expectations use Italian; locale tests override this explicitly.
    binding.platformDispatcher.localeTestValue = const Locale('it');
    binding.platformDispatcher.localesTestValue = const [Locale('it')];
    AppStrings.useLanguage('it');
  });
  await testMain();
}
