import 'package:bidscube_levelplay_flutter/bidscube_levelplay_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BidscubeLevelPlayConfig toMap includes LevelPlay-safe fields', () {
    const config = BidscubeLevelPlayConfig(
      requestAuthority: 'https://ssp.example.com',
      sspHost: 'ssp.example.com',
      enableLogging: true,
      enableDebugMode: false,
      userId: 'user-123',
      defaultAdTimeout: 25000,
      enableTestMode: true,
      gdpr: 1,
      gdprConsent: 'CPEXAMPLE',
      usPrivacy: '1YNN',
      coppa: false,
      openRtbPodMetadataEnabled: false,
      videoPodDurationValidationMode: LevelPlayPodDurationValidationMode.strict,
      videoPodSkipPolicy: LevelPlayPodSkipPolicy.failEntirePod,
      videoPodContinueOnSlotError: false,
      videoPodShowCounter: false,
      videoFullscreenPolicy: LevelPlayVideoFullscreenPolicy.forceFullscreen,
    );

    expect(config.toMap(), {
      'requestAuthority': 'https://ssp.example.com',
      'sspHost': 'ssp.example.com',
      'enableLogging': true,
      'enableDebugMode': false,
      'userId': 'user-123',
      'defaultAdTimeout': 25000,
      'enableTestMode': true,
      'gdpr': 1,
      'gdprConsent': 'CPEXAMPLE',
      'usPrivacy': '1YNN',
      'coppa': false,
      'openRtbPodMetadataEnabled': false,
      'videoPodDurationValidationMode': 'strict',
      'videoPodSkipPolicy': 'failEntirePod',
      'videoPodContinueOnSlotError': false,
      'videoPodShowCounter': false,
      'videoFullscreenPolicy': 'forceFullscreen',
    });
  });

  test('BidscubeLevelPlayConfig defaults', () {
    const config = BidscubeLevelPlayConfig();
    expect(config.toMap()['defaultAdTimeout'], 30000);
    expect(config.toMap()['openRtbPodMetadataEnabled'], true);
    expect(config.toMap()['videoPodDurationValidationMode'], 'lenient');
    expect(config.toMap()['videoPodSkipPolicy'], 'skipCurrentAndContinue');
    expect(config.toMap()['videoPodContinueOnSlotError'], true);
    expect(config.toMap()['videoPodShowCounter'], true);
    expect(config.toMap()['videoFullscreenPolicy'], 'auto');
  });

  test('LevelPlayVideoFullscreenPolicy stable strings', () {
    expect(
      LevelPlayVideoFullscreenPolicyX.fromStableString('windowed'),
      LevelPlayVideoFullscreenPolicy.forceWindowed,
    );
    expect(
      LevelPlayVideoFullscreenPolicyX.fromStableString('fullscreen'),
      LevelPlayVideoFullscreenPolicy.forceFullscreen,
    );
    expect(
      LevelPlayVideoFullscreenPolicyX.fromStableString(null),
      LevelPlayVideoFullscreenPolicy.auto,
    );
  });
}
