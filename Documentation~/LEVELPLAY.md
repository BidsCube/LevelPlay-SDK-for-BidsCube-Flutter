# LevelPlay (IronSource) + Flutter

У Flutter немає окремого “Dart-адаптера” для LevelPlay: мережа **Bidscube** підключається **нативно** (Android / iOS), так само як у чистих native-додатках. Пакет `bidscube_sdk_flutter` дає:

1. **Ранню ініціалізацію** нативного `BidscubeSDK` через `BidscubeSDK.initialize`, щоб кастомні адаптери LevelPlay бачили той самий інстанс SDK.
2. **Режим `BidscubeIntegrationMode.levelPlayMediation`**, у якому методи віджетів Dart (`getBannerAdView`, …) **вимкнені** — завантаження й показ реклами робляться через **LevelPlay / IronSource** (наприклад, пакет `ironsource_mediation` або ваші виклики до нативного SDK).

## Кроки інтеграції

### 1. Залежності Flutter

Додайте в `pubspec.yaml`:

```yaml
dependencies:
  bidscube_sdk_flutter: ^1.0.0
  # опційно, якщо керуєте рекламою з Dart:
  # ironsource_mediation: <версія з документації IronSource>
```

### 2. Ініціалізація перед LevelPlay

У `main()` (після `WidgetsFlutterBinding.ensureInitialized()`):

```dart
import 'package:bidscube_sdk_flutter/bidscube_sdk_flutter.dart';

await BidscubeSDK.initialize(
  config: SDKConfig.builder()
      .integrationMode(BidscubeIntegrationMode.levelPlayMediation)
      .build(),
  useFlutterOnly: false,
);
```

**Важливо:** для LevelPlay потрібен **нативний** шлях (`useFlutterOnly: false`). Режим `FlutterOnlyBidscube` з `levelPlayMediation` заборонений.

### 3. Android — залежність `bidscube-sdk`

Плагін тягне **`com.bidscube:bidscube-sdk:1.0.0`**. Поки артефакту немає в Maven Central, опублікуйте SDK локально:

```bash
cd LevelPlay-SDK-Android
./gradlew :sdk:publishReleasePublicationToMavenLocal
```

У `android/build.gradle` / `android/build.gradle.kts` додатку бажано мати **`mavenLocal()`** у списку репозиторіїв (приклад у цьому репо ставить його першим у `example/android/build.gradle.kts`).

Якщо вмикаєте **core library desugaring** через транзитивні залежності SDK, у **application**-модулі також потрібні `isCoreLibraryDesugaringEnabled = true` та `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.3")` (див. приклад `example/android/app/build.gradle.kts`).

### 4. Android (host `android/app/build.gradle.kts` або `.gradle`) — LevelPlay + адаптер

Підключіть mediation SDK і адаптер Bidscube (версії з вашого `LevelPlay-SDK-Android` / Maven):

```kotlin
dependencies {
    implementation("com.unity3d.ads-mediation:mediation-sdk:9.2.0")
    implementation("com.bidscube:bidscube-sdk:1.0.0@aar")
    implementation("com.bidscube:levelplay-bidscube-adapter:1.0.0")
}
```

У **LevelPlay Dashboard** для кастомної мережі використовуйте класи з пакета `com.ironsource.adapters.custom.bidscube` (див. README Android-репозиторію). Параметр інстансу — **placementId** Bidscube.

Плагін `bidscube_sdk_flutter` уже тягне **`bidscube-sdk`** для PlatformView / прямого показу; адаптер LevelPlay додайте **в додаток**, щоб не нав’язувати IronSource всім споживачам пакета.

### 5. iOS (`Podfile`)

```ruby
pod 'BidscubeSDK', '1.0.0'
pod 'IronSourceSDK', '9.3.0.0'
pod 'LevelPlayMediationBidscubeAdapter', :git => 'https://github.com/BidsCube/LevelPlay-SDK-iOS.git', :tag => 'v1.0.0'
```

Класи адаптера: `ISBidscubeCustomAdapter`, `ISBidscubeCustomBanner`, тощо (див. README iOS-репозиторію).

### 6. Поведінка в Dart

| Режим | Реклама через LevelPlay | Віджети `getBannerAdView` / … |
|--------|-------------------------|-------------------------------|
| `directSdk` (за замовчуванням) | Ні (якщо самі не підключили IronSource) | Так, через нативний SDK + PlatformView |
| `levelPlayMediation` | Так (з нативного шару) | **Ні** — викличе `UnsupportedError` |

## Чому так

- Unity використовує **UnitySendMessage** у спеціальний GameObject — це інший міст.
- Flutter застосунок з LevelPlay використовує **нативні** адаптери IronSource; вони викликають **Java / Swift BidscubeSDK** напряму.
- Виклик `BidscubeSDK.initialize` з Dart лише **синхронізує** конфігурацію нативного SDK з тим, що очікують адаптери.

## Прямий SDK без LevelPlay

Залиште `integrationMode: BidscubeIntegrationMode.directSdk` (або не задавайте — це значення за замовчуванням) і використовуйте `getBannerAdView`, `FlutterOnlyBidscube` тощо як раніше.
