import 'package:bidscube_levelplay_flutter/bidscube_levelplay_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BidscubeLevelPlayConfig toMap', () {
    const config = BidscubeLevelPlayConfig(
      requestAuthority: 'https://ssp.example.com',
      sspHost: 'ssp.example.com',
      enableLogging: true,
      enableDebugMode: false,
      userId: 'user-123',
    );

    expect(config.toMap(), {
      'requestAuthority': 'https://ssp.example.com',
      'sspHost': 'ssp.example.com',
      'enableLogging': true,
      'enableDebugMode': false,
      'userId': 'user-123',
    });
  });
}
