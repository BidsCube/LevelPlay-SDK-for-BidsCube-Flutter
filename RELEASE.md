# Реліз `bidscube_sdk_flutter` (наприклад **1.0.0**)

Публікація виконується GitHub Actions workflow **[`.github/workflows/release.yml`](.github/workflows/release.yml)** після push **git-тега** `v<версія>`.

## Вимоги

1. Версія в **`pubspec.yaml`** (`version:`) **має збігатися** з тегом без префікса `v`  
   (тег `v1.0.0` → у `pubspec.yaml` має бути `version: 1.0.0`).
2. На [pub.dev](https://pub.dev) для пакета увімкнено **Automated publishing** з цим GitHub-репозиторієм (OIDC).  
   Деталі: [Automated publishing](https://dart.dev/tools/pub/automated-publishing).
3. У workflow є `permissions: id-token: write` — потрібно для OIDC до pub.dev.

## Кроки для релізу 1.0.0

1. Переконайся, що в репозиторії:
   - `pubspec.yaml` → `version: 1.0.0`
   - за потреби оновлені `CHANGELOG.md`, `ios/*.podspec`, `android/build.gradle` (`version = ...`).
2. Закоміть зміни на гілку `main` (або ту, з якої релізиш).
3. Створи й запуш тег:

   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

4. У GitHub → **Actions** → workflow **Release (pub.dev + GitHub)** має:
   - перевірити збіг версії з тегом;
   - виконати `flutter test`, `analyze`, `pub publish --dry-run`;
   - опублікувати на **pub.dev** (`dart pub publish -f`);
   - створити **GitHub Release** для `v1.0.0`.

## Ручна перевірка без релізу

**Actions** → **Release (pub.dev + GitHub)** → **Run workflow**: виконаються тести та `pub publish --dry-run` без публікації та без GitHub Release (бо немає події push тега).

## Якщо версія вже на pub.dev

Якщо `dart pub publish` повертає помилку «already exists», workflow трактує це як успіх і все одно створює GitHub Release (для тега).
