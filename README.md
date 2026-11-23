# bidscube_levelplay_flutter

Lightweight Flutter package that wires **Bidscube native LevelPlay adapters** into Android and iOS builds.

**This Flutter package does not implement LevelPlay mediation in Dart.**  
It only wires Bidscube native LevelPlay adapters into Android/iOS builds.  
Ad loading/showing must be done through Unity's official **`unity_levelplay_mediation`** Flutter plugin.

## Base SDK vs LevelPlay wiring

| Concern | [`bidscube_sdk_flutter`](https://github.com/BidsCube/bidscube-sdk-flutter) (direct) | This package (LevelPlay) |
|---------|--------------------------------------------------------------------------------------|---------------------------|
| Init / logging / `userId` | `BidscubeSDK.initialize` + `SDKConfig` | `BidscubeLevelPlayFlutter.initialize` + `BidscubeLevelPlayConfig` |
| Runtime `userId` | config only (read via `config?.userId`) | `setUserId` / `getUserId` |
| Privacy at init | request query defaults | Android: `gdpr` / `gdprConsent` / `usPrivacy` / `coppa` on pre-init |
| OpenRTB pod flags | Dart parsers + config | Forwarded on Android pre-init; reserved on iOS |
| Banner / video / rewarded / native widgets | Yes (`getBannerAdView`, …) | **No** — use `unity_levelplay_mediation` |
| Consent form UI | Stub APIs | **No** — use LevelPlay / CMP |
| Android TV video policy | `setVideoFullscreenPolicy` | `videoFullscreenPolicy` + `setVideoFullscreenPolicy` (Android); Apple TV LevelPlay N/A |

## Mediation flow

```text
Flutter app
    ↓
bidscube_levelplay_flutter  (optional pre-init / userId)
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
    git:
      url: https://github.com/BidsCube/LevelPlay-SDK-for-BidsCube-Flutter.git
      ref: v1.0.4
```

Or path / pub.dev when published:

```yaml
dependencies:
  unity_levelplay_mediation: ^9.2.0
  bidscube_levelplay_flutter: ^1.0.4
```

### Android

This plugin adds:

```gradle
implementation "com.bidscube:levelplay-bidscube-adapter:1.1.0"
```

The adapter pulls `com.bidscube:bidscube-sdk-full-video` **1.2.12** transitively (Android TV fullscreen contract included).

**Host app must add LevelPlay / IronSource mediation SDK separately** (via `unity_levelplay_mediation` and your LevelPlay dashboard setup).

### iOS

This plugin's podspec adds:

```ruby
s.dependency 'LevelPlayMediationBidscubeAdapter', '~> 1.0.2'
```

`BidscubeSDK` and `IronSourceSDK` come from the adapter podspec. Use CocoaPods integration in the host app.

## Usage

```dart
import 'package:bidscube_levelplay_flutter/bidscube_levelplay_flutter.dart';

await BidscubeLevelPlayFlutter.initialize(
  config: const BidscubeLevelPlayConfig(
    enableLogging: true,
    userId: 'YOUR_USER_ID', // optional — sent as user_id for postback
    defaultAdTimeout: 30000,
    // Android TV: auto = fullscreen on Leanback (default)
    videoFullscreenPolicy: LevelPlayVideoFullscreenPolicy.auto,
    // Android pre-init privacy (ignored as reserved on current iOS SDKConfig):
    gdpr: 1,
    gdprConsent: 'YOUR_TC_STRING',
    usPrivacy: '1YNN',
    coppa: false,
  ),
);

print(await BidscubeLevelPlayFlutter.isInitialized()); // true
print(await BidscubeLevelPlayFlutter.getUserId()); // YOUR_USER_ID

// Optional: update user id after login / identity change
await BidscubeLevelPlayFlutter.setUserId('UPDATED_USER_ID');

// Optional: force fullscreen / windowed on Android TV (QA)
await BidscubeLevelPlayFlutter.setVideoFullscreenPolicy(
  LevelPlayVideoFullscreenPolicy.forceFullscreen,
);

// Then use unity_levelplay_mediation for LevelPlay init/load/show.
```

```dart
final sdkVersion = await BidscubeLevelPlayFlutter.getNativeSdkVersion();
final adapterVersion = await BidscubeLevelPlayFlutter.getAdapterVersion();
```

`cleanup()` is for QA / hot-restart only — do not call it during active LevelPlay mediation.

**Android note:** Flutter pre-init enables `videoAdsEnabled(true)` so rewarded/interstitial video stay available when this package initializes Bidscube before the LevelPlay adapter.

**Android TV:** default `videoFullscreenPolicy: auto` matches native LevelPlay (`FullscreenPolicy.AUTO` — fullscreen on Leanback, D-pad focus via adapter). Dashboard can also set `video_fullscreen_policy`. **Apple TV + LevelPlay is not supported** (IronSource has no tvOS binary).

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

On iOS, `requestAuthority` / `sspHost` from `BidscubeLevelPlayConfig` map to `SDKConfig.baseURL` when provided. On Android those fields are logged and not applied.

## OpenRTB

OpenRTB 2.6-style response parsing is handled only by native Android/iOS Bidscube SDKs when supported.  
This Flutter package does not parse OpenRTB responses.  
This Flutter package does not build or POST OpenRTB bid requests.

Pod-related flags on `BidscubeLevelPlayConfig` are forwarded to Android `SDKConfig` on pre-init; on iOS they are reserved (logged).

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
