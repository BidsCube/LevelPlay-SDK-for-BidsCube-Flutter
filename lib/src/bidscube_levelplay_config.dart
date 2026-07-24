class BidscubeLevelPlayConfig {
  final String? requestAuthority;
  final String? sspHost;
  final bool enableLogging;
  final bool enableDebugMode;

  /// Publisher user id sent to SSP as query param `user_id` (for postback).
  final String? userId;

  const BidscubeLevelPlayConfig({
    this.requestAuthority,
    this.sspHost,
    this.enableLogging = false,
    this.enableDebugMode = false,
    this.userId,
  });

  Map<String, Object?> toMap() => {
        'requestAuthority': requestAuthority,
        'sspHost': sspHost,
        'enableLogging': enableLogging,
        'enableDebugMode': enableDebugMode,
        'userId': userId,
      };
}
