package com.bidscube.levelplay.flutter

import android.util.Log
import com.bidscube.sdk.BidscubeSDK
import com.bidscube.sdk.config.SDKConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Wires LevelPlay adapter artifact; optional Bidscube SDK pre-init only. */
class BidscubeLevelPlayFlutterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: android.content.Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "bidscube_levelplay_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                try {
                    initializeBidscubeIfNeeded(call)
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(TAG, "Bidscube pre-init failed", e)
                    result.error("init_failed", e.message, null)
                }
            }
            "setUserId" -> {
                try {
                    if (!BidscubeSDK.isInitialized()) {
                        result.error(
                            "not_initialized",
                            "Call BidscubeLevelPlayFlutter.initialize before setUserId",
                            null,
                        )
                        return
                    }
                    BidscubeSDK.setUserId(call.argument<String>("userId"))
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(TAG, "setUserId failed", e)
                    result.error("set_user_id_failed", e.message, null)
                }
            }
            "getNativeSdkVersion" -> result.success(NATIVE_SDK_VERSION)
            "getAdapterVersion" -> result.success(ADAPTER_VERSION)
            else -> result.notImplemented()
        }
    }

    private fun initializeBidscubeIfNeeded(call: MethodCall) {
        if (BidscubeSDK.isInitialized()) {
            return
        }

        val requestAuthority = call.argument<String>("requestAuthority")
        val sspHost = call.argument<String>("sspHost")
        val enableLogging = call.argument<Boolean>("enableLogging") ?: false
        val enableDebugMode = call.argument<Boolean>("enableDebugMode") ?: false
        val userId = call.argument<String>("userId")

        if (!requestAuthority.isNullOrBlank() || !sspHost.isNullOrBlank()) {
            Log.d(
                TAG,
                "requestAuthority/sspHost received but not applied in this Android SDK version.",
            )
        }

        val builder = SDKConfig.Builder(applicationContext)
            .enableLogging(enableLogging)
            .enableDebugMode(enableDebugMode)
            .defaultAdTimeout(30000)
            .defaultAdPosition("UNKNOWN")

        if (!userId.isNullOrBlank()) {
            builder.userId(userId)
        }

        val config = builder.build()

        Log.i(TAG, "Initializing BidscubeSDK from Flutter LevelPlay wiring (pre-init).")
        BidscubeSDK.initialize(applicationContext, config)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private companion object {
        private const val TAG = "BidscubeLevelPlayFlutter"
        private const val NATIVE_SDK_VERSION = "1.0.2"
        private const val ADAPTER_VERSION = "1.0.2"
    }
}
