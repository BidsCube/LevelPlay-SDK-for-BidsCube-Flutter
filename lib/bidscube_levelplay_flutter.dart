export 'src/bidscube_levelplay_config.dart';
export 'src/bidscube_levelplay_flutter_platform_interface.dart';

import 'src/bidscube_levelplay_config.dart';
import 'src/bidscube_levelplay_flutter_platform_interface.dart';

/// Wires Bidscube native LevelPlay adapters into Android/iOS builds.
///
/// Does not load or show ads. Use [unity_levelplay_mediation] for mediation.
class BidscubeLevelPlayFlutter {
  static Future<void> initialize({
    BidscubeLevelPlayConfig config = const BidscubeLevelPlayConfig(),
  }) {
    return BidscubeLevelPlayFlutterPlatform.instance.initialize(config);
  }

  /// Update publisher user id after [initialize].
  ///
  /// Sent to SSP as query param `user_id` on subsequent ad requests (for postback).
  /// Pass `null` or empty string to clear.
  static Future<void> setUserId(String? userId) {
    return BidscubeLevelPlayFlutterPlatform.instance.setUserId(userId);
  }

  /// Current publisher user id, or `null` if unset / not initialized.
  static Future<String?> getUserId() {
    return BidscubeLevelPlayFlutterPlatform.instance.getUserId();
  }

  /// Whether native Bidscube SDK has been initialized.
  static Future<bool> isInitialized() {
    return BidscubeLevelPlayFlutterPlatform.instance.isInitialized();
  }

  /// Tear down native Bidscube SDK.
  ///
  /// For QA / hot-restart only — do not call during active LevelPlay mediation.
  static Future<void> cleanup() {
    return BidscubeLevelPlayFlutterPlatform.instance.cleanup();
  }

  /// Android TV / Leanback video fullscreen policy.
  ///
  /// Default [LevelPlayVideoFullscreenPolicy.auto]: fullscreen on TV; phone
  /// follows ad position. Also settable via [BidscubeLevelPlayConfig.videoFullscreenPolicy].
  /// LevelPlay does not run on Apple TV.
  static Future<void> setVideoFullscreenPolicy(
    LevelPlayVideoFullscreenPolicy policy,
  ) {
    return BidscubeLevelPlayFlutterPlatform.instance
        .setVideoFullscreenPolicy(policy);
  }

  static Future<LevelPlayVideoFullscreenPolicy> getVideoFullscreenPolicy() {
    return BidscubeLevelPlayFlutterPlatform.instance.getVideoFullscreenPolicy();
  }

  static Future<String> getNativeSdkVersion() {
    return BidscubeLevelPlayFlutterPlatform.instance.getNativeSdkVersion();
  }

  static Future<String> getAdapterVersion() {
    return BidscubeLevelPlayFlutterPlatform.instance.getAdapterVersion();
  }
}
