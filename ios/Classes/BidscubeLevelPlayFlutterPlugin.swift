import BidscubeSDK
import Flutter
import LevelPlayMediationBidscubeAdapter
import UIKit

public class BidscubeLevelPlayFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "bidscube_levelplay_flutter",
      binaryMessenger: registrar.messenger()
    )
    let instance = BidscubeLevelPlayFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      initializeBidscubeIfNeeded(call: call, result: result)
    case "setUserId":
      setUserId(call: call, result: result)
    case "getUserId":
      getUserId(result: result)
    case "isInitialized":
      result(BidscubeSDK.isInitialized())
    case "cleanup":
      cleanup(result: result)
    case "setVideoFullscreenPolicy":
      setVideoFullscreenPolicy(call: call, result: result)
    case "getVideoFullscreenPolicy":
      // LevelPlay has no tvOS slice; keep Dart API stable with Android default.
      result("auto")
    case "getNativeSdkVersion":
      result(Constants.sdkVersion)
    case "getAdapterVersion":
      result(LevelPlayMediationBidscubeAdapterManifest.adapterVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func setVideoFullscreenPolicy(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    let policy = args?["policy"] as? String ?? "auto"
    NSLog(
      "[BidscubeLevelPlayFlutter] setVideoFullscreenPolicy(%@) ignored on iOS LevelPlay — IronSource has no tvOS slice; use BidscubeSDK directly on Apple TV.",
      policy
    )
    result(nil)
  }

  private func setUserId(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard BidscubeSDK.isInitialized() else {
      result(
        FlutterError(
          code: "not_initialized",
          message: "Call BidscubeLevelPlayFlutter.initialize before setUserId",
          details: nil
        )
      )
      return
    }
    let args = call.arguments as? [String: Any]
    let userId = args?["userId"] as? String
    BidscubeSDK.setUserId(userId)
    result(nil)
  }

  private func getUserId(result: @escaping FlutterResult) {
    guard BidscubeSDK.isInitialized() else {
      result(nil)
      return
    }
    result(BidscubeSDK.getUserId())
  }

  private func cleanup(result: @escaping FlutterResult) {
    if BidscubeSDK.isInitialized() {
      BidscubeSDK.cleanup()
    }
    result(nil)
  }

  private func initializeBidscubeIfNeeded(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if BidscubeSDK.isInitialized() {
      result(nil)
      return
    }

    let args = call.arguments as? [String: Any]
    let requestAuthority = args?["requestAuthority"] as? String
    let sspHost = args?["sspHost"] as? String
    let enableLogging = args?["enableLogging"] as? Bool ?? false
    let enableDebugMode = args?["enableDebugMode"] as? Bool ?? false
    let userId = args?["userId"] as? String
    let defaultAdTimeout = (args?["defaultAdTimeout"] as? NSNumber)?.intValue ?? 30000
    let enableTestMode = args?["enableTestMode"] as? Bool ?? false

    // Android-only / reserved on current iOS SDKConfig — log so publishers know.
    if args?["gdpr"] != nil
      || args?["gdprConsent"] != nil
      || args?["usPrivacy"] != nil
      || args?["coppa"] != nil
    {
      NSLog(
        "[BidscubeLevelPlayFlutter] privacy fields received but not applied on this iOS SDKConfig version."
      )
    }
    if args?["openRtbPodMetadataEnabled"] != nil
      || args?["videoPodDurationValidationMode"] != nil
      || args?["videoPodSkipPolicy"] != nil
      || args?["videoPodContinueOnSlotError"] != nil
      || args?["videoPodShowCounter"] != nil
    {
      NSLog(
        "[BidscubeLevelPlayFlutter] OpenRTB pod flags received but reserved/not applied on this iOS SDKConfig version."
      )
    }
    if enableTestMode {
      NSLog(
        "[BidscubeLevelPlayFlutter] enableTestMode received; no dedicated iOS SDK flag — logged only."
      )
    }
    if let policy = args?["videoFullscreenPolicy"] as? String, !policy.isEmpty {
      NSLog(
        "[BidscubeLevelPlayFlutter] videoFullscreenPolicy(%@) reserved on iOS LevelPlay (no Apple TV mediation).",
        policy
      )
    }

    let builder = SDKConfig.Builder()
      .enableLogging(enableLogging)
      .enableDebugMode(enableDebugMode)
      .defaultAdTimeout(defaultAdTimeout)

    if let authority = requestAuthority, !authority.isEmpty {
      builder.baseURL(authority)
    } else if let host = sspHost, !host.isEmpty {
      builder.baseURL(host)
    }

    if let userId = userId, !userId.isEmpty {
      builder.userId(userId)
    }

    BidscubeSDK.initialize(config: builder.build())
    result(nil)
  }
}
