#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
APP_NAME="YClick"
BUNDLE_ID="com.yclick.YClick"
EXTENSION_BUNDLE_ID="$BUNDLE_ID.FinderExtension"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="$ROOT_DIR/YClick.xcodeproj"
DERIVED_DATA="$ROOT_DIR/build/DerivedData"
BUILT_APP_BUNDLE="$DERIVED_DATA/Build/Products/Debug/$APP_NAME.app"
APP_BUNDLE="$HOME/Applications/$APP_NAME.app"
APP_BINARY="$APP_BUNDLE/Contents/MacOS/$APP_NAME"

pkill -x "$APP_NAME" >/dev/null 2>&1 || true

xcodebuild \
  -project "$PROJECT" \
  -scheme "$APP_NAME" \
  -configuration Debug \
  -derivedDataPath "$DERIVED_DATA" \
  build

mkdir -p "$HOME/Applications"
ditto "$BUILT_APP_BUNDLE" "$APP_BUNDLE"
/System/Library/Frameworks/CoreServices.framework/Versions/Current/Frameworks/LaunchServices.framework/Versions/Current/Support/lsregister -f -R -trusted "$APP_BUNDLE"
pluginkit -a "$APP_BUNDLE" >/dev/null 2>&1 || true
pluginkit -e use -i "$EXTENSION_BUNDLE_ID" >/dev/null 2>&1 || true
killall Finder >/dev/null 2>&1 || true

open_app() {
  /usr/bin/open -n "$APP_BUNDLE"
}

case "$MODE" in
  run)
    open_app
    ;;
  --debug|debug)
    lldb -- "$APP_BINARY"
    ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry|telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"YClickFinderExtension\" OR subsystem == \"$BUNDLE_ID\" OR subsystem == \"$EXTENSION_BUNDLE_ID\""
    ;;
  --verify|verify)
    open_app
    sleep 1
    pgrep -x "$APP_NAME" >/dev/null
    ;;
  *)
    echo "usage: $0 [run|--debug|--logs|--telemetry|--verify]" >&2
    exit 2
    ;;
esac
