# Release — bidscube_levelplay_flutter

Lightweight LevelPlay wiring package. Tag `v*` must match `pubspec.yaml` `version`.

## Pre-release

```bash
chmod +x scripts/validate-package.sh
./scripts/validate-package.sh
```

Clean archive (no `.git`, `build/`, `.dart_tool/`):

```bash
git archive --format=zip --output ../LevelPlay-SDK-Flutter-release.zip HEAD
unzip -l ../LevelPlay-SDK-Flutter-release.zip | grep -E '(^|/)(\.git|build/|\.dart_tool/|\.gradle/|local\.properties|Pods/|\.symlinks/|__MACOSX|\.DS_Store|/\._)' && exit 1 || true
```

## Publish

1. Bump `pubspec.yaml` version
2. Update `CHANGELOG.md`
3. Tag `vX.Y.Z` and push — GitHub Actions publishes to pub.dev and creates a GitHub Release

## Release status

- **LevelPlay Flutter:** lightweight wrapper; delegates to native adapters and `unity_levelplay_mediation`
- **OpenRTB 2.6:** not implemented yet
- **Native LevelPlay:** not supported
