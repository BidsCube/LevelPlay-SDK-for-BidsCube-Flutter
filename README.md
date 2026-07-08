# bidscube_levelplay_flutter

Lightweight Flutter package that wires **Bidscube native LevelPlay adapters** into Android and iOS builds.

**This Flutter package does not implement LevelPlay mediation in Dart.**  
It only wires Bidscube native LevelPlay adapters into Android/iOS builds.  
Ad loading/showing must be done through Unity's official **`unity_levelplay_mediation`** Flutter plugin.

## Mediation flow

```text
Flutter app
    ↓
unity_levelplay_mediation
    ↓
native LevelPlay SDK
    ↓
Bidscube LevelPlay custom adapter
    ↓
Bidscube native SDK
```

## Installation

```yaml
dependencies:
  unity_levelplay_mediation: ^9.2.0
  bidscube_levelplay_flutter:
    path: ../LevelPlay-SDK-Flutter
```

Or from pub.dev after publish:

```yaml
dependencies:
  unity_levelplay_mediation: ^9.2.0
  bidscube_levelplay_flutter: ^2.0.0
```

### Android

This plugin adds:

```gradle
implementation "com.bidscube:levelplay-bidscube-adapter:1.0.0"
```

The adapter pulls `com.bidscube:bidscube-sdk` transitively.

**Host app must add LevelPlay / IronSource mediation SDK separately** (via `unity_levelplay_mediation` and your LevelPlay dashboard setup).

### iOS

This plugin's podspec adds:

```ruby
s.dependency 'LevelPlayMediationBidscubeAdapter', '~> 1.0.0'
```

`BidscubeSDK` and `IronSourceSDK` come from the adapter podspec. Use CocoaPods integration in the host app.

## Usage

```dart
import 'package:bidscube_levelplay_flutter/bidscube_levelplay_flutter.dart';

await BidscubeLevelPlayFlutter.initialize(
  config: const BidscubeLevelPlayConfig(
    enableLogging: true,
  ),
);

// Then use unity_levelplay_mediation for LevelPlay init/load/show.
```

```dart
final sdkVersion = await BidscubeLevelPlayFlutter.getNativeSdkVersion();
final adapterVersion = await BidscubeLevelPlayFlutter.getAdapterVersion();
```

## Warning

**Do not call Bidscube direct SDK rendering APIs in LevelPlay mode.**  
**Do not mix direct Bidscube ads and LevelPlay-mediated Bidscube ads for the same inventory.**

## Supported formats

**Supported through LevelPlay native adapters:**

- Banner
- Interstitial (static/image)
- Rewarded
- MREC only if native LevelPlay adapter and dashboard setup support it

**Not supported:**

- Native LevelPlay

## LevelPlay dashboard (custom network)

| Role | Android class |
|------|-----------------|
| Base | `com.ironsource.adapters.custom.bidscube.BidscubeCustomAdapter` |
| Banner | `com.ironsource.adapters.custom.bidscube.BidscubeCustomBanner` |
| Interstitial | `com.ironsource.adapters.custom.bidscube.BidscubeCustomInterstitial` |
| Rewarded | `com.ironsource.adapters.custom.bidscube.BidscubeCustomRewardedVideo` |

| Role | iOS class |
|------|-----------|
| Base | `ISBidscubeCustomAdapter` |
| Banner | `ISBidscubeCustomBanner` |
| Interstitial | `ISBidscubeCustomInterstitial` |
| Rewarded | `ISBidscubeCustomRewardedVideo` |

**Instance parameter:** `placementId`

**Reserved server parameters** (logged; not fully applied until native SDK supports them):

`request_authority`, `ssp_host`, `stats_authority`, `openrtb_pod_metadata_enabled`, `video_pod_duration_validation_mode`, `video_pod_skip_policy`, `video_pod_continue_on_slot_error`, `video_pod_show_counter`

On iOS, `requestAuthority` / `sspHost` from `BidscubeLevelPlayConfig` map to `SDKConfig.baseURL` when provided.

## OpenRTB

OpenRTB 2.6-style response parsing is handled only by native Android/iOS Bidscube SDKs when supported.  
This Flutter package does not parse OpenRTB responses.  
This Flutter package does not build or POST OpenRTB bid requests.

**Current release status:** OpenRTB 2.6-style response parsing is **not implemented yet**.

## QA test app

Sibling project: `../BidscubeFlutterLevelPlayTestApp` (not inside this package).

## Validation

```bash
chmod +x scripts/validate-package.sh
./scripts/validate-package.sh
```

Clean source archive:

```bash
git archive --format=zip --output ../LevelPlay-SDK-Flutter-release.zip HEAD
```

## License

MIT. See `LICENSE`.
