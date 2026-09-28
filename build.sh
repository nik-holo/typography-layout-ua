#!/usr/bin/env bash
# Assembles "Typography Layout UA.bundle" from the .keylayout/.icns files in the repo root,
# then packs it as a zip (for Homebrew) and a .pkg installer (for double-click install).
#
#   ./build.sh            # uses version from VERSION file
#   ./build.sh 1.2.0      # explicit version
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${1:-$(cat VERSION)}"
NAME="Typography Layout UA"
BUNDLE_ID="com.github.nik-holo.typography-layout-ua"
DIST="dist"
BUNDLE="$DIST/$NAME.bundle"
RES="$BUNDLE/Contents/Resources"

rm -rf "$DIST"
mkdir -p "$RES/en.lproj"

# source file -> name inside the bundle (this name is what macOS uses as the input source ID)
copy_layout() {
  local src="$1" dst="$2"
  cp "$src.keylayout" "$RES/$dst.keylayout"
  cp "$src.icns"      "$RES/$dst.icns"
}
copy_layout Enghlis   "English"
copy_layout Russian   "Russian"
copy_layout Ukrainian "Ukrainian"

# KLInfo_<basename> entries: TISIconIsTemplate=true renders the icon as a monochrome
# template (used for the English layout so it differs from the red Cyrillic dot in the
# Sonoma cursor indicator), same as Ilya Birman's 3.9 bundle.
klinfo() {
  local base="$1" lang="$2" template="$3"
  local id; id="$(echo "$base" | tr '[:upper:]' '[:lower:]')"
  cat <<PLIST
	<key>KLInfo_$base</key>
	<dict>
		<key>TICapsLockLanguageSwitchCapable</key>
		<true/>
		<key>TISIconIsTemplate</key>
		<$template/>
		<key>TISInputSourceID</key>
		<string>$BUNDLE_ID.$id</string>
		<key>TISIntendedLanguage</key>
		<string>$lang</string>
	</dict>
PLIST
}

cat > "$BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleIdentifier</key>
	<string>$BUNDLE_ID</string>
	<key>CFBundleName</key>
	<string>$NAME</string>
	<key>CFBundleVersion</key>
	<string>$VERSION</string>
$(klinfo English   en-US true)
$(klinfo Russian   ru-RU false)
$(klinfo Ukrainian uk-UA false)
</dict>
</plist>
PLIST

cat > "$BUNDLE/Contents/version.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BuildVersion</key>
	<string>$VERSION</string>
	<key>ProjectName</key>
	<string>$NAME</string>
</dict>
</plist>
PLIST

# Display names in System Settings (keys must match the .keylayout basenames)
cat > "$RES/en.lproj/InfoPlist.strings" <<'STRINGS'
"English" = "English – Typography UA";
"Russian" = "Русский/Українська – Typography UA";
"Ukrainian" = "Українська/Русский – Typography UA";
STRINGS

plutil -lint "$BUNDLE/Contents/Info.plist" "$BUNDLE/Contents/version.plist" >/dev/null

# strip Finder metadata (quarantine etc.) from the copied files
xattr -cr "$BUNDLE"

ZIP="$DIST/typography-layout-ua-$VERSION.zip"
PKG="$DIST/typography-layout-ua-$VERSION.pkg"

# zip for Homebrew cask (-X: no extended attributes, so no ._* AppleDouble entries)
( cd "$DIST" && zip -q -X -r "$(basename "$ZIP")" "$NAME.bundle" )

# .pkg installer: installs the bundle into /Library/Keyboard Layouts for all users
PKGROOT="$DIST/pkgroot/Library/Keyboard Layouts"
mkdir -p "$PKGROOT"
cp -R "$BUNDLE" "$PKGROOT/"
pkgbuild --root "$DIST/pkgroot" \
         --identifier "$BUNDLE_ID.pkg" \
         --version "$VERSION" \
         --install-location / \
         "$PKG" >/dev/null
rm -rf "$DIST/pkgroot"

echo "Built:"
echo "  $BUNDLE"
echo "  $ZIP  sha256=$(shasum -a 256 "$ZIP" | cut -d' ' -f1)"
echo "  $PKG"
