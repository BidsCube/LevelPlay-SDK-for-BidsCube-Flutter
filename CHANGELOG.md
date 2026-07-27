# Changelog

## 2.0.3

### Added

- `BidscubeLevelPlayFlutter.setUserId` — runtime update of publisher user id after initialize (SSP `user_id` for postback)

## 2.0.2

### Changed

- Native Android/iOS adapter dependency floor bumped to `1.0.2` (includes `setUserId` / `user_id` postback support)

## 2.0.1

### Added

- `BidscubeLevelPlayConfig.userId` — forwarded to native `SDKConfig.userId` and sent as SSP query param `user_id` (for postback)

### Changed

- Native Android/iOS adapter dependency floor bumped to `1.0.1`

## 2.0.0

**Breaking:** Replaced the heavy direct SDK plugin (`bidscube_sdk_flutter`) with a lightweight LevelPlay wiring package (`bidscube_levelplay_flutter`).

### Added

- Minimal Dart API: `BidscubeLevelPlayFlutter.initialize`, `getNativeSdkVersion`, `getAdapterVersion`
- Android dependency on `com.bidscube:levelplay-bidscube-adapter`
- iOS dependency on `LevelPlayMediationBidscubeAdapter`
- `scripts/validate-package.sh`

### Removed

- Direct ad widgets, PlatformViews, VAST/OpenRTB Dart parsers, HTTP ad client, example app, and multi-platform desktop/web targets

### Notes

- Load/show must use Unity's official `unity_levelplay_mediation` plugin
- OpenRTB 2.6 response parsing is not implemented yet in native SDKs

## 1.0.0

Legacy full direct SDK package (`bidscube_sdk_flutter`). Superseded by 2.0.0 for LevelPlay mediation use cases.
