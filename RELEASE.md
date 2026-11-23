# Releasing `bidscube_levelplay_flutter` (e.g. **1.0.4**)

Publishing runs via the GitHub Actions workflow **[`.github/workflows/release.yml`](.github/workflows/release.yml)** after you push a **git tag** `v<version>`.

Same release model as [AppLovin-SDK-for-BidsCube-Flutter](https://github.com/BidsCube/AppLovin-SDK-for-BidsCube-Flutter): **GitHub Release first**, pub.dev optional (no hang).

## Requirements

1. The version in **`pubspec.yaml`** (`version:`) **must match** the tag without the `v` prefix  
   (tag `v1.0.4` → `pubspec.yaml` must have `version: 1.0.4`).
2. On [pub.dev](https://pub.dev), **Automated publishing** is optional. Only needed if you enable pub.dev in CI.  
   See [Automated publishing](https://dart.dev/tools/pub/automated-publishing).
3. The workflow includes `permissions: id-token: write` — required for OIDC to pub.dev.
4. **Flutter for CI** is pinned in **`.github/flutter-version`** (one line, e.g. `3.27.4`).

## Steps to release 1.0.4

1. Ensure the repository has:
   - `pubspec.yaml` → `version: 1.0.4`
   - as needed, updated `CHANGELOG.md`, `ios/*.podspec`
2. Commit to `main` (or the branch you release from).
3. Create and push the tag:

   ```bash
   git tag v1.0.4
   git push origin v1.0.4
   ```

4. In GitHub → **Actions** → workflow **Release (pub.dev + GitHub)** should:
   - verify the version matches the tag;
   - run `flutter test`, `analyze`, `pub publish --dry-run`;
   - create a **GitHub Release** for the tag (with install snippets + zip asset);
   - **skip pub.dev publish by default** (fast release, no OIDC hang).

5. **Optional pub.dev publish** (only after OIDC is configured on pub.dev):
   - GitHub repo → **Settings** → **Secrets and variables** → **Actions** → **Variables** → add `PUB_DEV_PUBLISH_ENABLED` = `true`, **or**
   - **Actions** → **Release (pub.dev + GitHub)** → **Run workflow** → check **Attempt pub.dev publish**.

## Manual check without a release

**Actions** → **Release (pub.dev + GitHub)** → **Run workflow**: runs tests and `pub publish --dry-run` only (no GitHub Release, no pub.dev unless you check the publish box).

## If publish hangs on pub.dev

Older workflow versions blocked on `dart pub publish` when **Automated publishing (OIDC)** was not enabled.

Current workflow: **GitHub Release completes first**; pub.dev runs only when `PUB_DEV_PUBLISH_ENABLED=true` or manual workflow with publish checked. Otherwise publish locally:

```bash
dart pub publish -f
```

## If the version is already on pub.dev

If `dart pub publish` returns an “already exists” error, the workflow treats that as success (the GitHub Release was already created in the step above).
