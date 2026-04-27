 import 'package:flutter/services.dart' show MethodChannel;

const platform = MethodChannel('pip_channel');

Future<void> enablePip() async {
  await platform.invokeMethod('enterPip');
}