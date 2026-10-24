# Pi control terminal

The same Flutter app, built for [flutter-pi](https://github.com/ardera/flutter-pi)
and started fullscreen on the Pi's touchscreen. It talks to Mosquitto on the Pi,
so the Zigbee bulbs, plugs, fans, covers and locks respond to the screen.

flutter-pi renders through DRM/KMS with no desktop, which is what makes it a
good kiosk on a small panel. The bundle carries its own `flutter-pi` binary, so
the Pi does not compile anything.

## What is live

Actions are published to `zigbee2mqtt/<id>/set` and state is read back from
`zigbee2mqtt/<id>`:

| Device type | Payload keys |
| --- | --- |
| light | `state`, `brightness` (0-254, converted from percent), `color_temp` (mireds), `color.hex` |
| switch | `state` |
| fan | `state`, `speed`, `preset_mode` |
| climate | `state`, `system_mode`, `occupied_heating_setpoint`, `occupied_cooling_setpoint` |
| cover | `position`, `state` (`OPEN`, `CLOSE`, `STOP`) |
| lock | `state` (`LOCK`, `UNLOCK`) |
| sensor | read only: `temperature`, `humidity`, `battery` |

Anything else in the app (media, IR remote, scenes, vacuum, alarm, camera, gate
and the plate whitelist) still runs on screen only, because those devices are
not Zigbee2MQTT lights. Scenes do publish the lights, covers and plugs they
touch. The app shows a **Demo** badge in the rail when the live link is off and
**Live** when the broker connection is up.

The ids in [lib/data/devices.dart](../lib/data/devices.dart) must match the
friendly names in `zigbee2mqtt/configuration.yaml`. Rename in Zigbee2MQTT or
edit the demo devices before deploying.

## What you need

- Raspberry Pi 5 or 4, 64-bit Raspberry Pi OS (Bookworm or later).
- A touchscreen that works with libinput. Nothing else is needed for touch.
- Mosquitto and Zigbee2MQTT on the Pi, or a broker reachable at the address you
  build with. Default is `localhost:1883`.
- A build machine with Flutter stable and `flutterpi_tool`. The tool tracks the
  Flutter version closely; if `flutter pub global activate flutterpi_tool`
  fails, update Flutter or pin an older tool version.

## First install

On the Pi:

```bash
git clone https://github.com/farai-coder/smart-home-control
cd smart-home-control
sudo bash pi/install.sh
```

`install.sh` installs the graphics, input and font libraries, adds the user to
`video`, `render` and `input`, writes `/usr/local/bin/smart-home-terminal` and
the systemd unit, and switches the Pi to console boot so flutter-pi owns the
display. `KEEP_DESKTOP=1` keeps the desktop session instead.

On the build machine, deploy:

```bash
PI_HOST=raspberrypi.local bash pi/deploy.sh
```

That builds `build/pi-bundle` for a Pi 5 by default (`PI_CPU=pi4` for a Pi 4),
rsyncs it to `/opt/smart-home/app` and restarts the service. Rebuild after app
changes; the first deploy also starts the service.

## Display settings

Edit `/etc/default/smart-home-terminal`:

```bash
ORIENTATION=landscape_left   # portrait_up, landscape_left, portrait_down, landscape_right
VIDEOMODE=1024x600           # empty uses the panel's preferred mode
PIXEL_RATIO=1                # optional override if the UI looks too small
```

Then `sudo systemctl restart smart-home-terminal`.

## Operating

```bash
sudo systemctl status smart-home-terminal
sudo systemctl restart smart-home-terminal
journalctl -u smart-home-terminal -f
```

The terminal reconnects to the broker with backoff, up to 30 seconds between
attempts, and keeps working on screen while the link is down. Unplugging and
replugging the broker or the network does not need a service restart.

To test without a screen attached:

```bash
/opt/smart-home/app/flutter-pi --release --dummy-display /opt/smart-home/app
```

## Manual build options

```bash
PI_CPU=pi5 MQTT_HOST=192.168.1.10 MQTT_PORT=1883 MQTT_BASE=zigbee2mqtt \
  bash pi/build.sh
```

The broker address is compiled into the bundle. If the Pi's IP or hostname
changes, rebuild and deploy again. Using `localhost` is the simplest setup
because Mosquitto runs on the Pi.

CI builds the bundle on every push, so the ARM64 release compile is checked
even without a Pi.
