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

  static Future<String> getNativeSdkVersion() {
    return BidscubeLevelPlayFlutterPlatform.instance.getNativeSdkVersion();
  }

  static Future<String> getAdapterVersion() {
    return BidscubeLevelPlayFlutterPlatform.instance.getAdapterVersion();
  }
}
