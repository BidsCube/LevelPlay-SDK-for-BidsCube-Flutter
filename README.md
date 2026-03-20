# BidsCube Flutter SDK (`bidscube_sdk_flutter`)

**`bidscube_sdk_flutter`** is the **BidsCube** Flutter plugin and a **LevelPlay (IronSource) mediation adapter** on Android and iOS: native custom-network adapters talk to the same `BidscubeSDK` instance you initialize from Dart. In **direct SDK** mode you also get image, video, native, and banner widgets for Android, iOS, Web, and desktop where supported.

## Features

- **Multi-platform Support**: Android, iOS
- **Image, Video, and Native ad support**
- **Multiple ad positions** (header, footer, sidebar, fullscreen, above/below the fold)
- **Dynamic position-based styling** with visual feedback
- **VAST video ad support** with IMA SDK integration
- **Banner ad management**
- **Responsive native ads** with flexible Flutter widgets
- **Position override functionality** for testing
- **Comprehensive error handling** and timeout management
- **Production-ready logging** with SDKLogger
- **Unified API** across all platforms

## Requirements

- Flutter **3.19.0+** (prefer matching **`.github/flutter-version`** for CI)
- Dart **3.5.0+** (see `pubspec.yaml` → `environment.sdk`)
- **Android (native channel)**: API 24+; until `com.bidscube:bidscube-sdk` is on Maven Central, builds need **`mavenLocal()`** after `./gradlew :sdk:publishReleasePublicationToMavenLocal` in the `LevelPlay-SDK-Android` repo (see `android/libs/README.md`).
- Platform-specific requirements:
  - **Android**: API level 21+ for Flutter-only mode; **24+** when using the native Android SDK
  - **iOS**: iOS 13.0+
  - **Web**: Modern browsers with JavaScript support
  - **Desktop**: Platform-specific development tools

## LevelPlay (IronSource) mediation

Bidscube joins **LevelPlay** through **native** Android/iOS adapters (`levelplay-bidscube-adapter`, iOS `LevelPlayMediationBidscubeAdapter`). This plugin supplies **`bidscube-sdk`** and lets you run **`BidscubeSDK.initialize`** from Dart **before** IronSource / LevelPlay starts so adapters share one SDK instance.

In **`levelPlayMediation`**, **`getBannerAdView` / `getImageAdView` / … are disabled** — use **IronSource / LevelPlay** to load and show ads ([`ironsource_mediation`](https://pub.dev/packages/ironsource_mediation) or native init).

| Mode | Ads via LevelPlay | `getBannerAdView` / … |
|------|-------------------|------------------------|
| `directSdk` (default) | Only if you added IronSource yourself | Yes |
| `levelPlayMediation` | Yes (native layer) | No — `UnsupportedError` |

**Rules:** **`useFlutterOnly: false`**. Do not combine **`FlutterOnlyBidscube`** with **`levelPlayMediation`**.

### 1. Dependencies

Add **`bidscube_sdk_flutter`** ([Installation](#installation)). Optionally add **[`ironsource_mediation`](https://pub.dev/packages/ironsource_mediation)** (pick a version compatible with your LevelPlay / IronSource Flutter guide).

### 2. Initialize Bidscube before IronSource / LevelPlay

Call **`BidscubeSDK.initialize`** right after **`WidgetsFlutterBinding.ensureInitialized()`** and **before** `LevelPlay.init` / IronSource init. Full flow:

### Example: `main()` entrypoint

```dart
import 'package:flutter/material.dart';
import 'package:bidscube_sdk_flutter/bidscube_sdk_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await BidscubeSDK.initialize(
    config: SDKConfig.builder()
        .baseURL('https://ssp-bcc-ads.com/sdk')
        .integrationMode(BidscubeIntegrationMode.levelPlayMediation)
        .build(),
    useFlutterOnly: false,
  );

  // Next: LevelPlay / IronSource init (App Key from dashboard), consent, then
  // load/show via ironsource_mediation. No Bidscube get*AdView calls in this mode.

  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('App')))));
}
```

### 3. Android — Gradle (`android/app`)

**Repositories:** until `com.bidscube:bidscube-sdk` and `com.bidscube:levelplay-bidscube-adapter` are on a remote repository you use, publish them locally from **`LevelPlay-SDK-Android`** (see [Requirements](#requirements) and `android/libs/README.md`) and put **`mavenLocal()`** in **`android/settings.gradle.kts`** / root `build.gradle` so it is checked (often **first**).

**`android/app/build.gradle` or `build.gradle.kts`:**

- **`minSdk`**: at least **24** (Bidscube native SDK).
- If Gradle reports desugaring issues from transitive SDK deps, enable **core library desugaring** in the **application** module (see the plugin’s `example/android/app/build.gradle.kts`).

**Dependencies** (versions must match what you ship — align with [`LevelPlay-SDK-Android`](https://github.com/BidsCube/LevelPlay-SDK-Android) / `gradle/libs.versions.toml`):

```kotlin
dependencies {
    // LevelPlay / IronSource mediation (example version — confirm against IronSource docs)
    implementation("com.unity3d.ads-mediation:mediation-sdk:9.2.0")

    // Bidscube LevelPlay custom adapter (publishes as com.bidscube:levelplay-bidscube-adapter)
    implementation("com.bidscube:levelplay-bidscube-adapter:1.0.0")

    // Often required alongside mediation-sdk; add if your build fails to resolve:
    // implementation("com.bidscube:bidscube-sdk:1.0.0")
}
```

The Flutter plugin already depends on **`bidscube-sdk`** for its own code paths; adding the **adapter + mediation SDK in the app** wires LevelPlay to Bidscube. Custom adapter entry class for **non-Unity** Android apps is in package **`com.ironsource.adapters.custom.bidscube`** (e.g. **`BidscubeCustomAdapter`** — exact class names are in the Android adapter README).

### 4. iOS — CocoaPods (`ios/Podfile`)

Inside `target 'Runner' do` (after `flutter_install_all_ios_pods`), add pods for **Bidscube**, **IronSource / LevelPlay**, and the **Bidscube LevelPlay adapter** (versions / tags must match your release):

```ruby
platform :ios, '13.0'

target 'Runner' do
  use_frameworks!
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  pod 'BidscubeSDK', '1.0.0'
  pod 'IronSourceSDK', '9.3.0.0' # confirm version with IronSource / LevelPlay iOS docs
  pod 'LevelPlayMediationBidscubeAdapter',
      :git => 'https://github.com/BidsCube/LevelPlay-SDK-iOS.git',
      :tag => 'v1.0.0'
end
```

Then:

```bash
cd ios && pod install && cd ..
```

### 5. What you set in LevelPlay / IronSource

| Item | Where | Purpose |
|------|--------|---------|
| **App Key** | Dashboard → your app (Android / iOS) | Passed into LevelPlay / IronSource SDK initialization in code |
| **Ad units / placements** | Dashboard | IDs you pass when loading banner / interstitial / rewarded in `ironsource_mediation` (or native API) |
| **Bidscube as custom network** | Mediation → networks | Add Bidscube so LevelPlay can call the native adapter |
| **Adapter class (Android)** | Custom network settings | e.g. **`com.ironsource.adapters.custom.bidscube.BidscubeCustomAdapter`** — confirm in [LevelPlay-SDK-Android](https://github.com/BidsCube/LevelPlay-SDK-Android) README |
| **iOS adapter** | `Podfile` + dashboard | **`LevelPlayMediationBidscubeAdapter`** pod; class names per [LevelPlay-SDK-iOS](https://github.com/BidsCube/LevelPlay-SDK-iOS) |
| **Instance / custom parameter** | Bidscube network instance | Your **Bidscube placement ID** (same inventory id you would use in direct SDK mode) |

UI labels can differ by IronSource version; the important part is **adapter class** + **Bidscube placement id** on the Bidscube network instance.

## Releasing (maintainers)

Tags, pub.dev OIDC, and GitHub Release: **[RELEASE.md](RELEASE.md)**. Workflow: `.github/workflows/release.yml`.

## Installation

```yaml
dependencies:
  bidscube_sdk_flutter: ^1.0.0
```

For **LevelPlay**, also add Android/iOS native dependencies and optionally **`ironsource_mediation`** as described in [LevelPlay (IronSource) mediation](#levelplay-ironsource-mediation).

```bash
flutter pub get
```

## Quick Start

**Use this section for direct SDK mode (`directSdk`, default).** For **LevelPlay mediation**, follow [LevelPlay (IronSource) mediation](#levelplay-ironsource-mediation) only — do not use `getBannerAdView` / `getImageAdView` / etc. there.

### 1. Initialize the SDK

```dart
import 'package:bidscube_sdk_flutter/bidscube_sdk_flutter.dart';

// Configure the SDK
final config = SDKConfig.builder()
    .baseURL('https://ssp-bcc-ads.com/sdk')
    .enableLogging(true)
    .enableDebugMode(true)
    .defaultAdTimeout(30000)
    .defaultAdPosition(AdPosition.header)
    .enableTestMode(true)
    .build();

// Initialize the SDK
await BidscubeSDK.initialize(config: config);
```

### 2. Create Ad Views

```dart
// Image Ad
final imageAdView = await BidscubeSDK.getImageAdView(
  'your_image_placement_id',
  callback: MyAdCallback(),
);

// Video Ad
final videoAdView = await BidscubeSDK.getVideoAdView(
  'your_video_placement_id',
  callback: MyAdCallback(),
);

// Native Ad
final nativeAdView = await BidscubeSDK.getNativeAdView(
  'your_native_placement_id',
  callback: MyAdCallback(),
);

// Banner Ad
final bannerAdView = await BidscubeSDK.getBannerAdView(
  'your_banner_placement_id',
  callback: MyAdCallback(),
);
```

### 3. Implement Ad Callbacks

```dart
class MyAdCallback implements AdCallback {
  @override
  void onAdLoading(String placementId) {
    print('Ad loading: $placementId');
  }

  @override
  void onAdLoaded(String placementId) {
    print('Ad loaded: $placementId');
  }

  @override
  void onAdDisplayed(String placementId) {
    print('Ad displayed: $placementId');
  }

  @override
  void onAdFailed(String placementId, String errorCode, String errorMessage) {
    print('Ad failed: $placementId - $errorMessage (Code: $errorCode)');
  }

  @override
  void onAdClicked(String placementId) {
    print('Ad clicked: $placementId');
  }

  @override
  void onAdClosed(String placementId) {
    print('Ad closed: $placementId');
  }

  @override
  void onVideoAdStarted(String placementId) {
    print('Video ad started: $placementId');
  }

  @override
  void onVideoAdCompleted(String placementId) {
    print('Video ad completed: $placementId');
  }

  @override
  void onVideoAdSkipped(String placementId) {
    print('Video ad skipped: $placementId');
  }
}
```

## Custom rendering with onAdRenderOverride

If you want full control over how an ad is rendered in your app (for example to use your own native components, custom WebView handling, or a different layout), use the `onAdRenderOverride` callback on your `AdCallback` implementation.

How it works

- When you pass an `AdCallback` to `getBannerAdView`, `getVideoAdView`, or `getNativeAdView`, the SDK will check whether the callback's `onAdRenderOverride` is non-null.
- If `onAdRenderOverride` is provided, the SDK will perform the ad request and call your `onAdRenderOverride(placementId, adm, position)` handler with the server response.
  - `adm` is the ad markup or data: it may be an HTML snippet, a VAST XML (for video), or a JSON-encoded object for native ads. If the server doesn't provide a specific `adm` field the SDK will pass a JSON-encoded fallback with the full response.
- When `onAdRenderOverride` is used, the SDK returns a placeholder widget (a SizedBox) instead of mounting the SDK-built view — you are expected to render the ad yourself inside your app UI.

Recommended usage pattern

1. Implement an `AdCallback` and set the `onAdRenderOverride` handler. In the handler parse the `adm` and create a Widget to display the ad.
2. Insert that widget into your widget tree (for example by storing it in state and calling `setState`) at the desired location.
3. The SDK still calls lifecycle methods (`onAdLoading`, `onAdLoaded`, `onAdDisplayed`, `onAdFailed`) so you can track ad state as before.

Example: render HTML/creative in a WebView

```dart
class ClientAdWidget extends StatefulWidget {
  final String placementId;
  ClientAdWidget(this.placementId);
  @override
  State createState() => _ClientAdWidgetState();
}

class _ClientAdWidgetState extends State<ClientAdWidget> {
  String? _html;

  @override
  Widget build(BuildContext context) {
    if (_html == null) return SizedBox(width: 320, height: 240);
    return SizedBox(
      width: 320,
      height: 240,
      child: WebViewWidget(controller: WebViewController()..loadHtmlString(_html!)),
    );
  }

  void updateHtml(String html) => setState(() => _html = html);
}

// When you register the callback (example in a State object):
final clientAdWidgetKey = GlobalKey<_ClientAdWidgetState>();
final clientWidget = ClientAdWidget('20212');

final callback = MyAdCallback();
callback.onAdRenderOverride = (placementId, adm, position) {
  // adm may already be full HTML; if it's JSON-encoded, extract the HTML from adm
  final html = adm; // or parse adm to extract HTML fragment
  clientAdWidgetKey.currentState?.updateHtml(html);
};

// Add the clientWidget (with key) into your UI; then call:
await BidscubeSDK.getBannerAdView('20212', callback: callback);
```

Example: parse native JSON and build a Flutter widget

```dart
callback.onAdRenderOverride = (placementId, adm, position) {
  // adm may be JSON; try to decode
  try {
    final data = json.decode(adm) as Map<String, dynamic>;
    // Extract fields (title, image, cta, etc.) and create widget
    final title = data['title'] ?? '';
    final imageUrl = data['imageUrl'] ?? '';
    setState(() {
      _clientAdWidget = GestureDetector(
        onTap: () => _onAdClicked(placementId),
        child: Column(children: [Text(title), Image.network(imageUrl), /* cta */]),
      );
    });
  } catch (e) {
    // Fallback: treat adm as plain string and log
    print('Failed to parse adm: $e');
  }
};
```

Notes and tips

- The SDK will call your lifecycle methods (onAdLoading/onAdLoaded/onAdDisplayed/onAdFailed) so you can show placeholders or retry UI while the network request is in progress.
- For VAST video ADM you typically receive XML — you can either feed it to a VAST/IMA player or implement your own video player. The SDK's IMA integration is used only when the SDK renders the view itself; when you override rendering you are responsible for playing/pausing and tracking video events.
- If your `onAdRenderOverride` throws an error, the SDK will log the exception and continue; consider adding try/catch around parsing and rendering logic to avoid losing lifecycle notifications.
- When using custom rendering, make sure to call `BidscubeSDK.setAdCallback(placementId, callback)` if you need SDK-level registration for later events (optional — passing callback directly to `get*AdView` is usually sufficient).

## Usage Examples

### Image Ads

```dart
final imageAdView = await BidscubeSDK.getImageAdView(
  'your_image_placement_id',
  callback: MyAdCallback(),
);

// Add to your widget tree
Container(
  width: 320,
  height: 240,
  child: imageAdView,
)
```

### Video Ads

```dart
final videoAdView = await BidscubeSDK.getVideoAdView(
  'your_video_placement_id',
  callback: MyAdCallback(),
);

// Add to your widget tree
Container(
  width: 320,
  height: 240,
  child: videoAdView,
)
```

### Native Ads

```dart
final nativeAdView = await BidscubeSDK.getNativeAdView(
  'your_native_placement_id',
  callback: MyAdCallback(),
);

// Add to your widget tree
Container(
  width: 320,
  height: 300,
  child: nativeAdView,
)
```

## Advanced Features

### Dynamic Position-Based Styling

The SDK automatically applies different visual styles based on the ad position received from the server:

- **Above The Fold**: Blue styling with rounded corners
- **Below The Fold**: Green styling with medium corners
- **Header**: Orange styling with small corners
- **Footer**: Purple styling with small corners
- **Sidebar**: Teal styling with medium corners
- **Full Screen**: Red styling with large corners and strong shadow
- **Depend On Screen Size**: Amber styling with medium corners

### Position Override for Testing

You can override the server-determined position for testing purposes:

```dart
// Enable position override
final config = SDKConfig.builder()
    .enableTestMode(true)
    .build();

// The ad view will use the specified position instead of server response
final adView = await BidscubeSDK.getImageAdView(
  'your_placement_id',
  position: AdPosition.fullScreen, // Override position
  callback: MyAdCallback(),
);
```

### Responsive Native Ads

Native ads automatically adapt to different screen sizes using flexible Flutter widgets:

- **Small screens** (< 300px): Compact layout
- **Medium screens** (300-500px): Balanced layout
- **Large screens** (> 500px): Full layout with all elements

### Comprehensive Logging

The SDK provides detailed logging through `SDKLogger`:

```dart
// Enable detailed logging
final config = SDKConfig.builder()
    .enableLogging(true)
    .enableDebugMode(true)
    .build();

// Logs include:
// - Request URLs and parameters
// - Response status codes and content
// - Position changes from server
// - Error details and stack traces
```

## Test Placement IDs

| Placement ID | Ad Type | Description                      |
| ------------ | ------- | -------------------------------- |
| `20212`      | Banner  | Test banner ad                   |
| `20213`      | Video   | Test video ad with VAST response |
| `20214`      | Native  | Test native ad                   |

## Running the Test App

1. **Navigate to testapp directory**:

   ```bash
   cd testapp
   ```

2. **Get dependencies**:

   ```bash
   flutter pub get
   ```

3. **Run on your preferred platform**:

   ```bash
   # Android
   flutter run -d android

   # iOS
   flutter run -d ios

   # Web
   flutter run -d web

   # macOS
   flutter run -d macos

   # Linux
   flutter run -d linux

   # Windows
   flutter run -d windows
   ```

## Configuration Options

### SDK Configuration

```dart
final config = SDKConfig.builder()
    .baseURL('https://ssp-bcc-ads.com/sdk')  // API endpoint
    .enableLogging(true)                     // Enable console logging
    .enableDebugMode(true)                   // Enable debug mode
    .defaultAdTimeout(30000)                 // Timeout in milliseconds
    .defaultAdPosition(AdPosition.header)    // Default ad position
    .enableTestMode(true)                    // Enable test mode
    .build();
```

## Troubleshooting

### Common Issues

1. **Ad not loading**:

   - Check network connectivity
   - Verify placement ID is correct
   - Check console logs for error messages

2. **Video ads not playing**:

   - Ensure platform-specific video support
   - Check VAST response format
   - Verify video URL is accessible

3. **Build errors**:
   - Ensure Flutter 3.19+ / Dart 3.5+ (see `pubspec.yaml` and `.github/flutter-version` for CI)
   - Check platform-specific requirements
   - Verify all dependencies are properly configured

### Debug Mode

Enable debug mode for detailed logging:

```dart
final config = SDKConfig.builder()
    .enableDebugMode(true)
    .build();
```

## Building the Package

To build the package for production:

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Build for all platforms
flutter build apk --release
flutter build ios --release
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See **[CHANGELOG.md](CHANGELOG.md)**.
