/// How the host app delivers Bidscube inventory.
///
/// - [directSdk]: Flutter (or native channel) requests and shows ads via this SDK.
/// - [levelPlayMediation]: Ads are loaded and shown through **LevelPlay / IronSource**
///   mediation; native `Bidscube` SDK must be initialized early so custom adapters work.
enum BidscubeIntegrationMode {
  /// Direct integration — use `getBannerAdView` / `FlutterOnlyBidscube` / native views.
  directSdk,

  /// LevelPlay mediation — use IronSource/LevelPlay Flutter or native APIs for load/show;
  /// call [BidscubeSDK.initialize] (native path) so adapters can use the same SDK instance.
  levelPlayMediation,
}

extension BidscubeIntegrationModeWire on BidscubeIntegrationMode {
  String get wireValue {
    switch (this) {
      case BidscubeIntegrationMode.directSdk:
        return 'direct';
      case BidscubeIntegrationMode.levelPlayMediation:
        return 'levelPlay';
    }
  }
}

BidscubeIntegrationMode bidscubeIntegrationModeFromWire(String? value) {
  switch (value) {
    case 'levelPlay':
      return BidscubeIntegrationMode.levelPlayMediation;
    default:
      return BidscubeIntegrationMode.directSdk;
  }
}
