#!/usr/bin/env bash
# Usage: ./scripts/update-version.sh 2.0.1
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <version>"
  exit 2
fi

VERSION="$1"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

perl -pi -e "s/^version: .*/version: $VERSION/" pubspec.yaml
perl -pi -e "s/^version = .*/version = \"$VERSION\"/" android/build.gradle
perl -pi -e "s/s\.version\s*=\s*'[^']*'/s.version          = '$VERSION'/" ios/bidscube_levelplay_flutter.podspec

echo "Updated pubspec.yaml, android/build.gradle, ios/bidscube_levelplay_flutter.podspec to $VERSION"
