#!/usr/bin/env bash
# Cuts a release: bumps VERSION, rebuilds, updates the cask sha256, commits, tags,
# pushes and publishes a GitHub release with the zip and pkg attached.
#
#   ./release.sh 1.1.0
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${1:?usage: ./release.sh <version>}"
CASK="Casks/typography-layout-ua.rb"

[[ -z "$(git status --porcelain)" ]] || { echo "working tree is not clean"; exit 1; }

echo "$VERSION" > VERSION
./build.sh "$VERSION"

ZIP="dist/typography-layout-ua-$VERSION.zip"
PKG="dist/typography-layout-ua-$VERSION.pkg"
SHA="$(shasum -a 256 "$ZIP" | cut -d' ' -f1)"

sed -i '' -E "s/^  version \".*\"/  version \"$VERSION\"/; s/^  sha256 \".*\"/  sha256 \"$SHA\"/" "$CASK"

git add VERSION "$CASK"
git commit -m "Release v$VERSION"
git tag -a "v$VERSION" -m "v$VERSION"
git push origin HEAD --tags

gh release create "v$VERSION" "$ZIP" "$PKG" --title "v$VERSION" --generate-notes
echo "Released v$VERSION"
