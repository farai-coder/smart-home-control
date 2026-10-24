# Smart Home Control

[![Flutter CI](https://github.com/farai-coder/smart-home-control/actions/workflows/ci.yml/badge.svg)](https://github.com/farai-coder/smart-home-control/actions/workflows/ci.yml)

A Flutter app for the house: lights, plugs, fans, climate, blinds, garage,
locks, media, scenes, vacuum, alarm, camera, sensors, the gate and the vehicle
plate whitelist. It carries a 59 command rule engine with tests, so the same
sentences used with the Python assistant work here.

Two builds come out of this code:

- **Web demo** (`flutter run -d chrome`): in-memory devices. Actions show the
  Zigbee2MQTT topic and payload they would send, and nothing leaves the page.
- **Pi terminal** (`pi/build.sh`): the release bundle for flutter-pi, wired to
  Mosquitto. Lights, plugs, fans, climate, covers, locks and sensors publish and
  read real state; the rail shows **Live** or **Offline**. See
  [pi/README.md](pi/README.md).

## Screens

- **Dashboard**: weather, family filter chips, device cards with live toggles,
  the air conditioner with a temperature stepper, scene cards and recent
  activity.
- **Rooms**: a tile per room with device counts, then a room hero, a horizontal
  device strip and a full list with toggles.
- **Device**: a panel for the device type. Lights get a brightness ring, colour
  temperature and swatches; climate a temperature dial with modes and fan;
  media transport, volume, mute and sources; the gate a plate checker with the
  whitelist. Blinds, garage, locks, vacuum, alarm, camera, sensors, scenes and
  the IR remote each have their own controls.
- **Analysis**: monthly consumption, comparison bars against efficient and
  average homes, and the biggest consumers.
- **Add device**: the dark scan screen with devices you can add.
- **Voice control**: one sheet with all 59 commands, a text field, and the last
  result with its MQTT payload. Spoken input stays with `assistant.py` and
  Whisper; this panel runs the same rules on typed commands.
- **Terminal layout**: at 700 px and wider the phone chrome gives way to a
  left rail with 64 px touch targets, up to four device columns and a
  **Speak** button. That is the layout the Pi boots into.

## Run it

```bash
flutter pub get
flutter run -d chrome
```

That is demo mode. For the Pi terminal:

```bash
sudo bash pi/install.sh                     # once, on the Pi
PI_HOST=raspberrypi.local bash pi/deploy.sh # from the build machine
```

The repository commits `lib/`, `test/` and `web/`. The native shells are not
committed, so add them once on a machine with Flutter:

```bash
flutter create . --platforms=android,ios
flutter run
```

Android and iOS then use the same `lib/` code with no changes.

## Commands

The full list lives in [lib/logic/commands.dart](lib/logic/commands.dart) and in
the voice sheet. It covers:

| Family | Examples |
| --- | --- |
| Lights | `turn on the lounge lights`, `set bedroom 1 brightness to 60 percent`, `set the lamp colour to blue`, `set the kitchen light colour temperature to 5000 kelvin` |
| Plugs and fans | `turn off the tv plug`, `set the bedroom fan speed to 4`, `set the bedroom fan preset to sleep` |
| Climate | `set the thermostat temperature to 22 degrees`, `set the climate mode to heating`, `turn off climate control` |
| Covers and doors | `open the lounge blinds`, `set the lounge blinds position to 40 percent`, `lock the front door` |
| Media | `play media in the lounge`, `next track`, `set media volume to 30`, `select media source HDMI 2` |
| Scenes | `activate movie night`, `run the morning routine`, `run the welcome home script` |
| Cleaning and alarm | `start the vacuum`, `send the vacuum to the dock`, `arm the alarm`, `stop the siren` |
| Camera and sensors | `view the camera stream`, `take a camera snapshot`, `read the entrance sensor` |
| Gate | `open the gate`, `check the gate status`, `check plate ABC 1234`, `add plate XYZ 9876 to the whitelist`, `remove plate XYZ 9876 from the whitelist` |

Rooms, spoken numbers, "all the lights", colour names, sources and plate checks
are resolved the same way as the Python rules. A room without lights, such as
the garage, is refused instead of falling back to another room.

## Layout

```
lib/
  config.dart                broker address and LIVE flag from dart-defines
  data/devices.dart          demo home and type metadata
  logic/commands.dart        the 59 command rule engine and payloads
  services/                  MQTT bus (dart:io) and the web no-op stub
  state/home_controller.dart navigation, actions, diffs and inbound state
  screens/                   dashboard, rooms, device, analysis, add, voice sheet
  widgets/                   shared cards, switches, sliders, device panels
test/
  commands_test.dart         every command plus focused behaviour tests
  live_test.dart             MQTT payloads, publishing and inbound state
  widget_test.dart           navigation and voice sheet widget tests
pi/
  build.sh                   ARM64 flutter-pi release bundle
  install.sh                 one-time Pi setup and systemd service
  deploy.sh                  build, rsync to the Pi, restart
  smart-home-terminal.service
  README.md                  live payloads, display settings, troubleshooting
```

## Tests

```bash
flutter analyze
flutter test
flutter build web
```

The CI workflow runs the same three steps on every push, uploads the web build,
and builds the ARM64 flutter-pi bundle so the Pi target stays compiling.

## Status

The app compiles and the tests run in CI. There is no local Flutter SDK in this
checkout, so the commands above are the source of truth for verification.
