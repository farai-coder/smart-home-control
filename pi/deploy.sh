#!/usr/bin/env bash
# Builds the terminal and copies it to the Pi.
#
#   PI_HOST=raspberrypi.local bash pi/deploy.sh
#
# PI_USER defaults to pi. The first deploy needs pi/install.sh to have run on
# the Pi. Every later deploy is just this script.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PI_HOST="${PI_HOST:-raspberrypi.local}"
PI_USER="${PI_USER:-pi}"
APP_DIR="${APP_DIR:-/opt/smart-home/app}"

if [ -z "$PI_HOST" ]; then
  echo "Set PI_HOST, for example PI_HOST=192.168.1.20 bash pi/deploy.sh" >&2
  exit 1
fi

bash pi/build.sh

echo "Copying bundle to $PI_USER@$PI_HOST:$APP_DIR"
ssh "$PI_USER@$PI_HOST" "sudo install -d -o '$PI_USER' -g '$PI_USER' '$APP_DIR'"
rsync -az --delete --info=progress2 build/pi-bundle/ \
  "$PI_USER@$PI_HOST:$APP_DIR/"

echo "Restarting the terminal"
ssh "$PI_USER@$PI_HOST" "sudo systemctl restart smart-home-terminal.service"
echo "Done. Watch the screen, or run: ssh $PI_USER@$PI_HOST journalctl -u smart-home-terminal -f"
