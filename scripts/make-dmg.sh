#!/bin/zsh
# Builds build/copyToast-<version>.dmg with a styled drag-to-Applications window.
# Finder lays out the window, so macOS may ask to allow controlling Finder.
set -euo pipefail

cd "${0:A:h}/.."
./scripts/build.sh --dist

version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Config/Info.plist)"
dmg="build/copyToast-$version.dmg"
volume="/Volumes/copyToast"
work="$(mktemp -d)"
cleanup() {
    [[ -d "$volume" ]] && hdiutil detach -quiet "$volume" || true
    rm -rf "$work"
}
trap cleanup EXIT

# Finder addresses the disk by name, so an earlier copy must not be mounted.
if [[ -d "$volume" ]]; then
    hdiutil detach -quiet "$volume"
fi

mkdir -p "$work/staging/.background"
swift scripts/make-dmg-background.swift "$work/background.png" 1
swift scripts/make-dmg-background.swift "$work/background@2x.png" 2
tiffutil -cathidpicheck "$work/background.png" "$work/background@2x.png" \
    -out "$work/staging/.background/background.tiff" 2>/dev/null
ditto build/copyToast.app "$work/staging/copyToast.app"
ln -s /Applications "$work/staging/Applications"

hdiutil create -quiet -volname copyToast -srcfolder "$work/staging" -format UDRW -fs HFS+ -size 20m "$work/rw.dmg"
hdiutil attach -quiet -readwrite -noverify -noautoopen "$work/rw.dmg"

osascript <<'APPLESCRIPT'
tell application "Finder"
    tell disk "copyToast"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {200, 120, 860, 568}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 128
        set text size of viewOptions to 13
        set background picture of viewOptions to file ".background:background.tiff"
        set extension hidden of item "copyToast.app" to true
        set position of item "copyToast.app" of container window to {175, 200}
        set position of item "Applications" of container window to {485, 200}
        update without registering applications
        delay 2
        close
    end tell
end tell
APPLESCRIPT

for _ in {1..20}; do
    [[ -f "$volume/.DS_Store" ]] && break
    osascript -e 'delay 0.5'
done
[[ -f "$volume/.DS_Store" ]] || { echo "error: Finder did not save the window layout." >&2; exit 1; }

sync
hdiutil detach -quiet "$volume"
rm -f "$dmg"
hdiutil convert -quiet "$work/rw.dmg" -format UDZO -imagekey zlib-level=9 -o "$dmg"
hdiutil verify -quiet "$dmg"

echo "Built $dmg"
