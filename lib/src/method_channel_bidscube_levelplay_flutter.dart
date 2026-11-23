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
  Future<void> setUserId(String? userId) async {
    await _channel.invokeMethod<void>('setUserId', {'userId': userId});
  }

  @override
  Future<String?> getUserId() async {
    return _channel.invokeMethod<String?>('getUserId');
  }

  @override
  Future<bool> isInitialized() async {
    final value = await _channel.invokeMethod<bool>('isInitialized');
    return value ?? false;
  }

  @override
  Future<void> cleanup() async {
    await _channel.invokeMethod<void>('cleanup');
  }

  @override
  Future<void> setVideoFullscreenPolicy(
    LevelPlayVideoFullscreenPolicy policy,
  ) async {
    await _channel.invokeMethod<void>('setVideoFullscreenPolicy', {
      'policy': policy.stableString,
    });
  }

  @override
  Future<LevelPlayVideoFullscreenPolicy> getVideoFullscreenPolicy() async {
    final value =
        await _channel.invokeMethod<String>('getVideoFullscreenPolicy');
    return LevelPlayVideoFullscreenPolicyX.fromStableString(value);
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
