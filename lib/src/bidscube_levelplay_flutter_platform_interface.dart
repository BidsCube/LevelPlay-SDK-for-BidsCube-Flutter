import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bidscube_levelplay_config.dart';
import 'method_channel_bidscube_levelplay_flutter.dart';

abstract class BidscubeLevelPlayFlutterPlatform extends PlatformInterface {
  BidscubeLevelPlayFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static BidscubeLevelPlayFlutterPlatform _instance =
      MethodChannelBidscubeLevelPlayFlutter();

  static BidscubeLevelPlayFlutterPlatform get instance => _instance;

  static set instance(BidscubeLevelPlayFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize(BidscubeLevelPlayConfig config);

  /// Update publisher user id after [initialize]. Sent as SSP `user_id` for postback.
  Future<void> setUserId(String? userId);

  Future<String> getNativeSdkVersion();

  Future<String> getAdapterVersion();
}
