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

  static Future<String> getNativeSdkVersion() {
    return BidscubeLevelPlayFlutterPlatform.instance.getNativeSdkVersion();
  }

  static Future<String> getAdapterVersion() {
    return BidscubeLevelPlayFlutterPlatform.instance.getAdapterVersion();
  }
}
