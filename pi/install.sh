#!/usr/bin/env bash
# One-time setup on the Raspberry Pi (64-bit Raspberry Pi OS).
#
#   sudo bash pi/install.sh
#
# Installs the libraries flutter-pi needs, creates the kiosk launcher, and
# registers the service. It does not contain the app: run pi/deploy.sh from the
# build machine afterwards.
#
# Set KEEP_DESKTOP=1 to stay on the desktop session. The default switches the
# Pi to console boot, which flutter-pi needs to own the display.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this with sudo: sudo bash pi/install.sh" >&2
  exit 1
fi

PI_USER="${PI_USER:-pi}"
APP_DIR="/opt/smart-home/app"
KEEP_DESKTOP="${KEEP_DESKTOP:-0}"

if [ "$(uname -m)" != "aarch64" ]; then
  echo "Warning: $(uname -m) is not aarch64. The bundle is built for 64-bit ARM." >&2
fi

echo "Installing flutter-pi runtime libraries"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  libgl1-mesa-dev \
  libgles2-mesa-dev \
  libegl1-mesa-dev \
  libdrm-dev \
  libgbm-dev \
  fontconfig \
  fonts-roboto \
  fonts-liberation \
  libsystemd-dev \
  libinput-dev \
  libudev-dev \
  libxkbcommon-dev \
  rsync

fc-cache -f >/dev/null

if ! id "$PI_USER" >/dev/null 2>&1; then
  echo "There is no '$PI_USER' user on this Pi. Pass PI_USER=<name>." >&2
  exit 1
fi

usermod -aG video,render,input "$PI_USER" || true

install -d -m 755 -o "$PI_USER" -g "$PI_USER" /opt/smart-home
install -d -m 755 -o "$PI_USER" -g "$PI_USER" "$APP_DIR"

cat >/usr/local/bin/smart-home-terminal <<'LAUNCHER'
#!/usr/bin/env bash
# Launches the smart home terminal fullscreen on the Pi display.
set -euo pipefail
: "${APP_DIR:=/opt/smart-home/app}"
: "${ORIENTATION:=landscape_left}"

if [ ! -x "$APP_DIR/flutter-pi" ]; then
  echo "No app bundle in $APP_DIR. Deploy it with pi/deploy.sh." >&2
  exit 1
fi

ARGS=(--release)
if [ -n "${ORIENTATION:-}" ]; then
  ARGS+=(-o "$ORIENTATION")
fi
if [ -n "${VIDEOMODE:-}" ]; then
  ARGS+=(--videomode "$VIDEOMODE")
fi
if [ -n "${PIXEL_RATIO:-}" ]; then
  ARGS+=(--pixel-ratio "$PIXEL_RATIO")
fi

exec "$APP_DIR/flutter-pi" "${ARGS[@]}" "$APP_DIR"
LAUNCHER
chmod 755 /usr/local/bin/smart-home-terminal

if [ ! -f /etc/default/smart-home-terminal ]; then
  cat >/etc/default/smart-home-terminal <<'DEFAULTS'
# Display settings for the smart home terminal.
# Orientation: portrait_up, landscape_left, portrait_down, landscape_right
ORIENTATION=landscape_left
# Leave empty to use the display's preferred mode, or pin it, e.g. 1024x600
VIDEOMODE=
# Optional, useful when the UI looks too small or too large
PIXEL_RATIO=
DEFAULTS
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/smart-home-terminal.service" ]; then
  install -m 644 "$SCRIPT_DIR/smart-home-terminal.service" \
    /etc/systemd/system/smart-home-terminal.service
else
  echo "smart-home-terminal.service not found next to install.sh" >&2
  exit 1
fi

systemctl daemon-reload
systemctl enable smart-home-terminal.service

sed -i "s/^User=.*/User=$PI_USER/; s/^Group=.*/Group=$PI_USER/" \
  /etc/systemd/system/smart-home-terminal.service

if [ "$KEEP_DESKTOP" = "1" ]; then
  echo "Keeping the desktop session. Stop it before starting the terminal:"
  echo "  sudo systemctl isolate multi-user.target"
else
  systemctl set-default multi-user.target
  systemctl disable lightdm.service 2>/dev/null || true
  echo "Boot target set to console. flutter-pi now owns the display."
fi

if [ -x "$APP_DIR/flutter-pi" ]; then
  systemctl restart smart-home-terminal.service
  echo "Service started. Logs: journalctl -u smart-home-terminal -f"
else
  echo "Service enabled. Deploy the bundle, then run:"
  echo "  sudo systemctl start smart-home-terminal"
fi
