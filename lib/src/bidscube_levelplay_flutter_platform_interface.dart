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

  /// Current publisher user id, or `null` if unset / not initialized.
  Future<String?> getUserId();

  /// Whether native Bidscube SDK has been initialized.
  Future<bool> isInitialized();

  /// Tear down native Bidscube SDK.
  ///
  /// For QA / hot-restart only — do not call during active LevelPlay mediation.
  Future<void> cleanup();

  /// Android TV / Leanback video fullscreen policy (applied to native Bidscube SDK).
  Future<void> setVideoFullscreenPolicy(LevelPlayVideoFullscreenPolicy policy);

  Future<LevelPlayVideoFullscreenPolicy> getVideoFullscreenPolicy();

  Future<String> getNativeSdkVersion();

  Future<String> getAdapterVersion();
}
