#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_NAME="Mo.app"
APP_PATH="$PROJECT_DIR/$APP_NAME"

# Extract version from version/version.go
VERSION=$(grep 'Version = ' "$PROJECT_DIR/version/version.go" | sed 's/.*"\(.*\)".*/\1/')

echo "Building $APP_NAME v${VERSION}..."

# Clean previous build
rm -rf "$APP_PATH"

# Build in /tmp to avoid iCloud Drive resource fork issues with osacompile
TMPDIR_BUILD="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_BUILD"' EXIT

# Compile AppleScript into .app bundle
osacompile -o "$TMPDIR_BUILD/$APP_NAME" "$SCRIPT_DIR/mo-wrapper.applescript"

# Generate Info.plist from template
sed "s/__VERSION__/${VERSION}/g" "$SCRIPT_DIR/Info.plist.tmpl" > "$TMPDIR_BUILD/$APP_NAME/Contents/Info.plist"

# Re-sign with ad-hoc signature (osacompile's signature is invalidated by Info.plist replacement)
codesign --force --deep --sign - "$TMPDIR_BUILD/$APP_NAME"

# Move to project directory
mv "$TMPDIR_BUILD/$APP_NAME" "$APP_PATH"

echo "Built $APP_PATH"

# Register with Launch Services so Finder picks it up immediately
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"
if [ -x "$LSREGISTER" ]; then
    "$LSREGISTER" -f "$APP_PATH"
    echo "Registered with Launch Services"
else
    echo "Warning: lsregister not found. You may need to log out and back in for Finder to recognize Mo.app."
fi
