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
    case "getNativeSdkVersion":
      result(Constants.sdkVersion)
    case "getAdapterVersion":
      result(LevelPlayMediationBidscubeAdapterManifest.adapterVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
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

    let builder = SDKConfig.Builder()
      .enableLogging(enableLogging)
      .enableDebugMode(enableDebugMode)

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
