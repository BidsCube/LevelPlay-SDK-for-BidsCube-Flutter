import 'package:flutter/services.dart';

import 'bidscube_levelplay_config.dart';
import 'bidscube_levelplay_flutter_platform_interface.dart';

class MethodChannelBidscubeLevelPlayFlutter
    extends BidscubeLevelPlayFlutterPlatform {
  static const MethodChannel _channel =
      MethodChannel('bidscube_levelplay_flutter');

  @override
  Future<void> initialize(BidscubeLevelPlayConfig config) async {
    await _channel.invokeMethod<void>('initialize', config.toMap());
  }

  @override
  Future<String> getNativeSdkVersion() async {
    final version = await _channel.invokeMethod<String>('getNativeSdkVersion');
    return version ?? 'unknown';
  }

  @override
  Future<String> getAdapterVersion() async {
    final version = await _channel.invokeMethod<String>('getAdapterVersion');
    return version ?? 'unknown';
  }
}
