/// OpenRTB pod duration validation (aligned with base bidscube_sdk_flutter).
enum LevelPlayPodDurationValidationMode {
  lenient,
  strict,
}

/// OpenRTB pod skip policy (aligned with base bidscube_sdk_flutter naming).
enum LevelPlayPodSkipPolicy {
  skipCurrentAndContinue,
  failEntirePod,
}

/// Video fullscreen policy for Android TV / Leanback (mirrors native
/// `VideoUiDefaults.FullscreenPolicy` and base `VideoFullscreenPolicy`).
///
/// LevelPlay on Apple TV is not supported (IronSource has no tvOS slice).
enum LevelPlayVideoFullscreenPolicy {
  /// TV / Leanback → fullscreen. Phone: fullscreen for full-screen / unknown positions.
  auto,

  /// Always fullscreen (phone and TV).
  forceFullscreen,

  /// Always windowed, including on TV (QA compare).
  forceWindowed,
}

extension LevelPlayPodDurationValidationModeX
    on LevelPlayPodDurationValidationMode {
  String get stableString {
    switch (this) {
      case LevelPlayPodDurationValidationMode.lenient:
        return 'lenient';
      case LevelPlayPodDurationValidationMode.strict:
        return 'strict';
    }
  }
}

extension LevelPlayPodSkipPolicyX on LevelPlayPodSkipPolicy {
  String get stableString {
    switch (this) {
      case LevelPlayPodSkipPolicy.skipCurrentAndContinue:
        return 'skipCurrentAndContinue';
      case LevelPlayPodSkipPolicy.failEntirePod:
        return 'failEntirePod';
    }
  }
}

extension LevelPlayVideoFullscreenPolicyX on LevelPlayVideoFullscreenPolicy {
  String get stableString {
    switch (this) {
      case LevelPlayVideoFullscreenPolicy.auto:
        return 'auto';
      case LevelPlayVideoFullscreenPolicy.forceFullscreen:
        return 'forceFullscreen';
      case LevelPlayVideoFullscreenPolicy.forceWindowed:
        return 'forceWindowed';
    }
  }

  static LevelPlayVideoFullscreenPolicy fromStableString(String? value) {
    switch (value?.trim()) {
      case 'forceFullscreen':
      case 'fullscreen':
        return LevelPlayVideoFullscreenPolicy.forceFullscreen;
      case 'forceWindowed':
      case 'windowed':
        return LevelPlayVideoFullscreenPolicy.forceWindowed;
      case 'auto':
      default:
        return LevelPlayVideoFullscreenPolicy.auto;
    }
  }
}

/// Pre-init config for Bidscube native SDK in LevelPlay mediation mode.
///
/// Does not load/show ads — use `unity_levelplay_mediation` for that.
class BidscubeLevelPlayConfig {
  final String? requestAuthority;
  final String? sspHost;
  final bool enableLogging;
  final bool enableDebugMode;

  /// Publisher user id sent to SSP as query param `user_id` (for postback).
  final String? userId;

  /// Default ad request timeout in milliseconds.
  final int defaultAdTimeout;

  /// Reserved / logged when native SDK has no dedicated test-mode flag.
  final bool enableTestMode;

  /// GDPR applies flag (`0` / `1`), forwarded on Android pre-init.
  final int? gdpr;

  /// GDPR consent string, forwarded on Android pre-init.
  final String? gdprConsent;

  /// US privacy / CCPA string, forwarded on Android pre-init.
  final String? usPrivacy;

  /// COPPA flag, forwarded on Android pre-init.
  final bool? coppa;

  /// OpenRTB pod metadata parsing (Android pre-init; iOS reserved).
  final bool openRtbPodMetadataEnabled;

  final LevelPlayPodDurationValidationMode videoPodDurationValidationMode;
  final LevelPlayPodSkipPolicy videoPodSkipPolicy;
  final bool videoPodContinueOnSlotError;
  final bool videoPodShowCounter;

  /// Android TV / Leanback video presentation (default [LevelPlayVideoFullscreenPolicy.auto]).
  final LevelPlayVideoFullscreenPolicy videoFullscreenPolicy;

  const BidscubeLevelPlayConfig({
    this.requestAuthority,
    this.sspHost,
    this.enableLogging = false,
    this.enableDebugMode = false,
    this.userId,
    this.defaultAdTimeout = 30000,
    this.enableTestMode = false,
    this.gdpr,
    this.gdprConsent,
    this.usPrivacy,
    this.coppa,
    this.openRtbPodMetadataEnabled = true,
    this.videoPodDurationValidationMode =
        LevelPlayPodDurationValidationMode.lenient,
    this.videoPodSkipPolicy = LevelPlayPodSkipPolicy.skipCurrentAndContinue,
    this.videoPodContinueOnSlotError = true,
    this.videoPodShowCounter = true,
    this.videoFullscreenPolicy = LevelPlayVideoFullscreenPolicy.auto,
  });

  Map<String, Object?> toMap() => {
        'requestAuthority': requestAuthority,
        'sspHost': sspHost,
        'enableLogging': enableLogging,
        'enableDebugMode': enableDebugMode,
        'userId': userId,
        'defaultAdTimeout': defaultAdTimeout,
        'enableTestMode': enableTestMode,
        'gdpr': gdpr,
        'gdprConsent': gdprConsent,
        'usPrivacy': usPrivacy,
        'coppa': coppa,
        'openRtbPodMetadataEnabled': openRtbPodMetadataEnabled,
        'videoPodDurationValidationMode':
            videoPodDurationValidationMode.stableString,
        'videoPodSkipPolicy': videoPodSkipPolicy.stableString,
        'videoPodContinueOnSlotError': videoPodContinueOnSlotError,
        'videoPodShowCounter': videoPodShowCounter,
        'videoFullscreenPolicy': videoFullscreenPolicy.stableString,
      };
}
