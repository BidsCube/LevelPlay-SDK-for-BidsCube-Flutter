package com.bidscube.levelplay.flutter

import android.util.Log
import com.bidscube.sdk.BidscubeSDK
import com.bidscube.sdk.config.SDKConfig
import com.bidscube.sdk.openrtb.PodDurationValidationMode
import com.bidscube.sdk.video.PodSkipPolicy
import com.bidscube.sdk.video.VideoUiDefaults
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
            "getUserId" -> {
                try {
                    if (!BidscubeSDK.isInitialized()) {
                        result.success(null)
                        return
                    }
                    result.success(BidscubeSDK.getUserId())
                } catch (e: Exception) {
                    Log.e(TAG, "getUserId failed", e)
                    result.error("get_user_id_failed", e.message, null)
                }
            }
            "isInitialized" -> result.success(BidscubeSDK.isInitialized())
            "cleanup" -> {
                try {
                    if (BidscubeSDK.isInitialized()) {
                        BidscubeSDK.cleanup()
                    }
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(TAG, "cleanup failed", e)
                    result.error("cleanup_failed", e.message, null)
                }
            }
            "setVideoFullscreenPolicy" -> {
                try {
                    val policy = parseFullscreenPolicy(call.argument<String>("policy"))
                        ?: VideoUiDefaults.FullscreenPolicy.AUTO
                    BidscubeSDK.setVideoFullscreenPolicy(policy)
                    if (VideoUiDefaults.isTelevision(applicationContext)) {
                        Log.i(TAG, "Android TV detected; video fullscreen policy=$policy")
                    }
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(TAG, "setVideoFullscreenPolicy failed", e)
                    result.error("set_video_fullscreen_policy_failed", e.message, null)
                }
            }
            "getVideoFullscreenPolicy" -> {
                result.success(fullscreenPolicyToStable(BidscubeSDK.getVideoFullscreenPolicy()))
            }
            "getNativeSdkVersion" -> result.success(NATIVE_SDK_VERSION)
            "getAdapterVersion" -> result.success(ADAPTER_VERSION)
            else -> result.notImplemented()
        }
    }

    private fun initializeBidscubeIfNeeded(call: MethodCall) {
        val videoFullscreenPolicy = call.argument<String>("videoFullscreenPolicy")

        if (BidscubeSDK.isInitialized()) {
            // Adapter may have inited first; still allow Flutter to set TV policy (same as dashboard).
            applyFullscreenPolicy(videoFullscreenPolicy, defaultToAuto = false)
            return
        }

        val requestAuthority = call.argument<String>("requestAuthority")
        val sspHost = call.argument<String>("sspHost")
        val enableLogging = call.argument<Boolean>("enableLogging") ?: false
        val enableDebugMode = call.argument<Boolean>("enableDebugMode") ?: false
        val userId = call.argument<String>("userId")
        val defaultAdTimeout = call.argument<Number>("defaultAdTimeout")?.toInt() ?: 30000
        val enableTestMode = call.argument<Boolean>("enableTestMode") ?: false
        val gdpr = call.argument<Number>("gdpr")?.toInt()
        val gdprConsent = call.argument<String>("gdprConsent")
        val usPrivacy = call.argument<String>("usPrivacy")
        val coppa = call.argument<Boolean>("coppa")
        val openRtbPodMetadataEnabled =
            call.argument<Boolean>("openRtbPodMetadataEnabled") ?: true
        val videoPodDurationValidationMode =
            call.argument<String>("videoPodDurationValidationMode")
        val videoPodSkipPolicy = call.argument<String>("videoPodSkipPolicy")
        val videoPodContinueOnSlotError =
            call.argument<Boolean>("videoPodContinueOnSlotError") ?: true
        val videoPodShowCounter = call.argument<Boolean>("videoPodShowCounter") ?: true

        if (!requestAuthority.isNullOrBlank() || !sspHost.isNullOrBlank()) {
            Log.d(
                TAG,
                "requestAuthority/sspHost received but not applied in this Android SDK version.",
            )
        }
        if (enableTestMode) {
            Log.d(TAG, "enableTestMode received; no dedicated Android SDK flag — logged only.")
        }

        val builder = SDKConfig.Builder(applicationContext)
            .enableLogging(enableLogging)
            .enableDebugMode(enableDebugMode)
            .defaultAdTimeout(defaultAdTimeout)
            .defaultAdPosition("UNKNOWN")
            // LevelPlay mediation needs video creatives; default Builder is false.
            .videoAdsEnabled(true)
            .openRtbPodMetadataEnabled(openRtbPodMetadataEnabled)
            .videoPodContinueOnSlotError(videoPodContinueOnSlotError)
            .videoPodShowCounter(videoPodShowCounter)

        if (!userId.isNullOrBlank()) {
            builder.userId(userId)
        }
        if (gdpr != null) {
            builder.gdpr(gdpr)
        }
        if (!gdprConsent.isNullOrBlank()) {
            builder.gdprConsent(gdprConsent)
        }
        if (!usPrivacy.isNullOrBlank()) {
            builder.usPrivacy(usPrivacy)
        }
        if (coppa != null) {
            builder.coppa(coppa)
        }

        parseDurationMode(videoPodDurationValidationMode)?.let {
            builder.videoPodDurationValidationMode(it)
        }
        parseSkipPolicy(videoPodSkipPolicy)?.let {
            builder.videoPodSkipPolicy(it)
        }

        val config = builder.build()

        Log.i(TAG, "Initializing BidscubeSDK from Flutter LevelPlay wiring (pre-init).")
        BidscubeSDK.initialize(applicationContext, config)

        // Match LevelPlay adapter TV contract: AUTO unless publisher overrides.
        applyFullscreenPolicy(videoFullscreenPolicy, defaultToAuto = true)
    }

    private fun applyFullscreenPolicy(raw: String?, defaultToAuto: Boolean) {
        val parsed = parseFullscreenPolicy(raw)
        val policy = when {
            parsed != null -> parsed
            defaultToAuto -> VideoUiDefaults.FullscreenPolicy.AUTO
            else -> return
        }
        BidscubeSDK.setVideoFullscreenPolicy(policy)
        if (VideoUiDefaults.isTelevision(applicationContext)) {
            Log.i(TAG, "Android TV detected; video fullscreen policy=$policy")
        }
    }

    private fun parseFullscreenPolicy(raw: String?): VideoUiDefaults.FullscreenPolicy? {
        if (raw.isNullOrBlank()) return null
        return when (raw.trim().lowercase()) {
            "auto" -> VideoUiDefaults.FullscreenPolicy.AUTO
            "forcefullscreen", "fullscreen" -> VideoUiDefaults.FullscreenPolicy.FORCE_FULLSCREEN
            "forcewindowed", "windowed" -> VideoUiDefaults.FullscreenPolicy.FORCE_WINDOWED
            else -> {
                Log.w(TAG, "Unknown videoFullscreenPolicy: $raw")
                null
            }
        }
    }

    private fun fullscreenPolicyToStable(policy: VideoUiDefaults.FullscreenPolicy): String {
        return when (policy) {
            VideoUiDefaults.FullscreenPolicy.FORCE_FULLSCREEN -> "forceFullscreen"
            VideoUiDefaults.FullscreenPolicy.FORCE_WINDOWED -> "forceWindowed"
            else -> "auto"
        }
    }

    private fun parseDurationMode(raw: String?): PodDurationValidationMode? {
        if (raw.isNullOrBlank()) return null
        return when (raw.trim().lowercase()) {
            "strict" -> PodDurationValidationMode.STRICT
            "lenient" -> PodDurationValidationMode.LENIENT
            else -> {
                Log.w(TAG, "Unknown videoPodDurationValidationMode: $raw")
                null
            }
        }
    }

    private fun parseSkipPolicy(raw: String?): PodSkipPolicy? {
        if (raw.isNullOrBlank()) return null
        val value = raw.trim()
        return when {
            value.equals("failEntirePod", ignoreCase = true) ||
                value.equals("skip_entire_pod", ignoreCase = true) ||
                value.equals("SKIP_ENTIRE_POD", ignoreCase = true) ->
                PodSkipPolicy.SKIP_ENTIRE_POD
            value.equals("skipCurrentAndContinue", ignoreCase = true) ||
                value.equals("skip_current_and_continue", ignoreCase = true) ||
                value.equals("SKIP_CURRENT_AND_CONTINUE", ignoreCase = true) ->
                PodSkipPolicy.SKIP_CURRENT_AND_CONTINUE
            else -> {
                Log.w(TAG, "Unknown videoPodSkipPolicy: $raw")
                null
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private companion object {
        private const val TAG = "BidscubeLevelPlayFlutter"
        private const val NATIVE_SDK_VERSION = "1.2.12"
        private const val ADAPTER_VERSION = "1.1.0"
    }
}
