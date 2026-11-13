import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ReminderService {
  static const _channel = MethodChannel(
    'com.simpledevperson.instalander/reminders',
  );
  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<bool> isEnabled() async => supported
      ? await _channel.invokeMethod<bool>('isEnabled') ?? false
      : false;

  static Future<int> getIntervalMonths() async => supported
      ? await _channel.invokeMethod<int>('getIntervalMonths') ?? 1
      : 1;

  static Future<void> setIntervalMonths(int months) async {
    if (![1, 3, 6].contains(months)) {
      throw ArgumentError.value(months, 'months');
    }
    if (supported) {
      await _channel.invokeMethod<void>('setIntervalMonths', months);
    }
  }

  /// Android schedules the notification itself; no Flutter background isolate.
  static Future<bool> setEnabled(bool enabled) async => supported
      ? await _channel.invokeMethod<bool>('setEnabled', enabled) ?? false
      : false;
}
