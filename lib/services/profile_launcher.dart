import 'package:flutter/services.dart';

class ProfileLauncher {
  static const _channel = MethodChannel(
    'com.simpledevperson.instalander/profiles',
  );

  static Future<bool> open(String username, {required bool inBrowser}) async {
    try {
      return await _channel.invokeMethod<bool>('open', {
            'username': username,
            'inBrowser': inBrowser,
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
