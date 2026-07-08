class BidscubeLevelPlayConfig {
  final String? requestAuthority;
  final String? sspHost;
  final bool enableLogging;
  final bool enableDebugMode;

  const BidscubeLevelPlayConfig({
    this.requestAuthority,
    this.sspHost,
    this.enableLogging = false,
    this.enableDebugMode = false,
  });

  Map<String, Object?> toMap() => {
        'requestAuthority': requestAuthority,
        'sspHost': sspHost,
        'enableLogging': enableLogging,
        'enableDebugMode': enableDebugMode,
      };
}
