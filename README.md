# BidsCube Flutter SDK (`bidscube_sdk_flutter`)

Flutter plugin for **BidsCube** ads: **LevelPlay (IronSource)** on Android/iOS via native adapters, plus **direct SDK** widgets (image / video / native / banner) where supported.

## Features

- Android & iOS; direct SDK: image, video, native, banner, VAST / IMA, positions & styling
- **LevelPlay:** initialize `BidscubeSDK` from Dart before IronSource; no `get*AdView` in `levelPlayMediation`
- Logging, timeouts, `onAdRenderOverride`, test placement IDs in README tables below

## Requirements

- Flutter **3.19.0+**, Dart **3.5.0+** (`pubspec.yaml`, `.github/flutter-version` for CI)
- Android **24+** with native SDK; **`mavenLocal()`** + local publish from `LevelPlay-SDK-Android` until Maven Central — see `android/libs/README.md`
- iOS **13+**; Web/Desktop: same as Flutter platform support for direct SDK

## LevelPlay (IronSource) mediation

Native adapters (`levelplay-bidscube-adapter`, `LevelPlayMediationBidscubeAdapter`) use the same **`BidscubeSDK`** you init from Dart **before** LevelPlay / IronSource. In **`levelPlayMediation`**, load/show ads only via **IronSource / LevelPlay** (e.g. pub package `ironsource_mediation` or native APIs) — not `getBannerAdView` / `getImageAdView` / …

| Mode | LevelPlay | `getBannerAdView` / … |
|------|-----------|------------------------|
| `directSdk` (default) | Only if you added IronSource yourself | Yes |
| `levelPlayMediation` | Yes | No — `UnsupportedError` |

**Rules:** `useFlutterOnly: false`. Do not use `FlutterOnlyBidscube` with `levelPlayMediation`.

**Deps:** `bidscube_sdk_flutter` (below) + optional `ironsource_mediation`.

**`main()` (init Bidscube before IronSource):**

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

  // Then: LevelPlay / IronSource init (App Key), consent, load/show via ironsource_mediation.

  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('App')))));
}
```

**Android `app`:** `minSdk` 24; `mavenLocal()` if needed; core desugaring like `example/android/app/build.gradle.kts` if Gradle asks.

```kotlin
dependencies {
    implementation("com.unity3d.ads-mediation:mediation-sdk:9.2.0")
    implementation("com.bidscube:levelplay-bidscube-adapter:1.0.0")
}
```

Adapter package: `com.ironsource.adapters.custom.bidscube` (e.g. `BidscubeCustomAdapter`). Match versions to your `LevelPlay-SDK-Android` tree.

**iOS `Podfile`:** after `flutter_install_all_ios_pods`, add `BidscubeSDK`, `IronSourceSDK`, and `LevelPlayMediationBidscubeAdapter` (git/tag per your iOS adapter release). Then `pod install`.

**Dashboard**

| Item | Where | Note |
|------|--------|------|
| App Key | App settings | IronSource / LevelPlay SDK init |
| Ad units | Dashboard | IDs for load/show in code |
| Bidscube network | Mediation | Custom adapter network |
| Android adapter class | Network | e.g. `…bidscube.BidscubeCustomAdapter` |
| iOS | Podfile + network | `LevelPlayMediationBidscubeAdapter` |
| Instance field | Bidscube instance | **Bidscube placement ID** |

## Releasing (maintainers)

`RELEASE.md` — tags, pub.dev OIDC, GitHub Release. Workflow: `.github/workflows/release.yml`.

## Installation

```yaml
dependencies:
  bidscube_sdk_flutter: ^1.0.0
```

LevelPlay: add native deps above and optionally `ironsource_mediation`.

```bash
flutter pub get
```

## Quick Start

**Direct SDK only** (`directSdk`). For LevelPlay use the **LevelPlay** section — no `get*AdView` there.

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

This project is licensed under the MIT License — see `LICENSE`.

## Changelog

See `CHANGELOG.md`.
