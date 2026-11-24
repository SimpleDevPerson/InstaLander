import 'dart:io';

import 'package:flutter/services.dart';

class FollowerTrackingService {
  static const _channel = MethodChannel(
    'com.simpledevperson.instalander/follower_tracking',
  );

  static bool get supported => Platform.isAndroid;

  static Future<({String? username, bool enabled})> state() async {
    final value = await _channel.invokeMapMethod<String, Object?>('state');
    return (
      username: value?['username'] as String?,
      enabled: value?['enabled'] == true,
    );
  }

  static Future<bool> setEnabled(bool enabled) async =>
      await _channel.invokeMethod<bool>('setEnabled', enabled) ?? false;

  static Future<bool> setProfile(String? username) async =>
      await _channel.invokeMethod<bool>('setProfile', username) ?? false;

  static Future<void> clear() async {
    if (supported) await _channel.invokeMethod<void>('clear');
  }
}
