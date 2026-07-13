#!/usr/bin/env bash
# Builds a release APK, copies it into docs/releases with a versioned,
# timestamped name, builds the web app into docs/appli, then regenerates
# docs/index.html so the download link and the "play in browser" link
# always point at the latest build.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
FLUTTER_DIR="$ROOT_DIR/flutter"
cd "$FLUTTER_DIR"

mkdir -p "$ROOT_DIR/docs/releases"

VERSION=$(grep '^version:' pubspec.yaml | head -n 1 | cut -d ' ' -f2 | tr -d '\r' | tr '+' '-')
TIMESTAMP=$(date +%Y%m%d-%H%M)
APK_NAME="da_point-${VERSION}-${TIMESTAMP}.apk"

echo "==> flutter build apk --release"
flutter build apk --release

cp "build/app/outputs/flutter-apk/app-release.apk" "$ROOT_DIR/docs/releases/${APK_NAME}"
echo "==> Copied to docs/releases/${APK_NAME}"

echo "==> flutter build web --release"
flutter build web --release --base-href "/"

rm -rf "$ROOT_DIR/docs/appli"
mkdir -p "$ROOT_DIR/docs/appli"
cp -r build/web/. "$ROOT_DIR/docs/appli/"

# Flutter's CLI rejects a relative --base-href, so patch it in after the
# build: relative "./" works whether the app is served at the repo root,
# under /appli/ locally, or on GitHub Pages under /<repo>/appli/.
sed -i '' 's#<base href="/">#<base href="./">#' "$ROOT_DIR/docs/appli/index.html"
echo "==> Copied web app to docs/appli/"

cd "$ROOT_DIR/docs"
python3 generate_site.py
