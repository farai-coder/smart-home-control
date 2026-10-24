#!/usr/bin/env bash
# Builds the terminal for a Raspberry Pi.
#
# Run on a Linux or macOS machine with Flutter installed, not on the Pi:
#   PI_CPU=pi5 MQTT_HOST=127.0.0.1 bash pi/build.sh
#
# The bundle lands in build/pi-bundle and carries its own flutter-pi binary.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PI_CPU="${PI_CPU:-pi5}"
MQTT_HOST="${MQTT_HOST:-localhost}"
MQTT_PORT="${MQTT_PORT:-1883}"
MQTT_BASE="${MQTT_BASE:-zigbee2mqtt}"

case "$PI_CPU" in
  pi5) TARGET="pi5-64" ;;
  pi4) TARGET="pi4-64" ;;
  pi3) TARGET="pi3-64" ;;
  generic) TARGET="aarch64-generic" ;;
  *)
    echo "Unknown PI_CPU '$PI_CPU'. Use pi5, pi4, pi3 or generic." >&2
    exit 1
    ;;
esac

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not on PATH. Install the SDK, then rerun." >&2
  exit 1
fi

echo "Building $TARGET for $MQTT_HOST:$MQTT_PORT ($MQTT_BASE)"
flutter pub get
flutter pub global activate flutterpi_tool

# Global executables that depend on the Flutter SDK can't be started with
# "flutter pub global run", so call the pub cache wrapper directly.
TOOL="${PUB_CACHE:-$HOME/.pub-cache}/bin/flutterpi_tool"
if [ ! -x "$TOOL" ]; then
  TOOL="$(command -v flutterpi_tool || true)"
fi
if [ -z "$TOOL" ] || [ ! -x "$TOOL" ]; then
  echo "flutterpi_tool is not available after activation." >&2
  echo "Add ${PUB_CACHE:-$HOME/.pub-cache}/bin to PATH and rerun." >&2
  exit 1
fi

"$TOOL" build \
  --arch=arm64 \
  --cpu="$PI_CPU" \
  --release \
  --tree-shake-icons \
  --dart-define=LIVE=true \
  --dart-define=MQTT_HOST="$MQTT_HOST" \
  --dart-define=MQTT_PORT="$MQTT_PORT" \
  --dart-define=MQTT_BASE="$MQTT_BASE"

OUT="build/flutter-pi/$TARGET"
if [ ! -x "$OUT/flutter-pi" ]; then
  echo "Expected the bundle at $OUT, but it is missing." >&2
  echo "Check the flutterpi_tool output above." >&2
  exit 1
fi

rm -rf build/pi-bundle
cp -a "$OUT" build/pi-bundle

echo
echo "Bundle ready: $ROOT/build/pi-bundle"
du -sh build/pi-bundle
echo "Next: PI_HOST=<pi-address> bash pi/deploy.sh"
