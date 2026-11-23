#!/bin/zsh
# Builds, bundles, and signs build/copyToast.app.
# With --dist, builds for Apple Silicon and Intel and signs ad hoc, for sharing.
set -euo pipefail

cd "${0:A:h}/.."
app="build/copyToast.app"

if [[ "${1:-}" == "--dist" ]]; then
    build_args=(-c release --arch arm64 --arch x86_64)
    identity="-"
else
    if ! security find-identity -v -p codesigning | grep -q "Apple Development"; then
        echo "error: no valid Apple Development certificate found." >&2
        echo "Create a free one in Xcode: Settings > Apple Accounts > Manage Certificates." >&2
        exit 1
    fi
    build_args=(-c release)
    identity="Apple Development"
fi

swift build "${build_args[@]}"
bin_dir="$(swift build "${build_args[@]}" --show-bin-path)"

rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$bin_dir/copyToast" "$app/Contents/MacOS/copyToast"
cp Config/Info.plist "$app/Contents/Info.plist"
cp Config/AppIcon.icns "$app/Contents/Resources/AppIcon.icns"
cp LICENSE "$app/Contents/Resources/LICENSE"
cp THIRD_PARTY_NOTICES.md "$app/Contents/Resources/THIRD_PARTY_NOTICES.md"

codesign --force --options runtime --timestamp=none \
    --entitlements Config/copyToast.entitlements \
    --sign "$identity" "$app"
codesign --verify --strict "$app"

echo "Built $app"
