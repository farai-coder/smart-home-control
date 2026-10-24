import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../config.dart';
import '../data/devices.dart';
import '../logic/commands.dart';
import '../services/home_bus.dart';

class ActivityEntry {
  const ActivityEntry(this.text, this.time, {this.ok = true, this.deviceId});

  final String text;
  final String time;
  final bool ok;
  final String? deviceId;
}

class AppRoute {
  const AppRoute(this.name, {this.id, this.room});

  final String name;
  final String? id;
  final String? room;
}

/// Device types that Zigbee2MQTT can actually drive. Panels for the other
/// families stay local until a matching integration exists.
const Set<String> kMqttTypes = <String>{
  'light',
  'switch',
  'fan',
  'climate',
  'cover',
  'lock',
  'sensor',
};

const Set<String> _onOffTypes = <String>{'light', 'switch', 'fan', 'climate'};

class HomeController extends ChangeNotifier {
  HomeController({
    List<Device>? devices,
    List<String>? plates,
    this.config = const TerminalConfig(),
    HomeBus? bus,
  })  : devices = devices ?? demoDevices(),
        plates = plates ?? <String>['ABC 1234', 'ZIM 4567'],
        _injectedBus = bus;

  final TerminalConfig config;
  final HomeBus? _injectedBus;
  HomeBus? _bus;

  final List<Device> devices;
  final List<String> plates;
  final List<ActivityEntry> activity = <ActivityEntry>[];
  final List<CommandResult> results = <CommandResult>[];
  final List<String> added = <String>[];
  final List<AppRoute> history = <AppRoute>[];

  AppRoute route = const AppRoute('dashboard');
  String filter = 'All';
  String? plateMessage;
  bool plateMessageOk = true;
  BusState busState = BusState.demo;
  String busDetail = 'Demo mode - nothing is published';

  /// Opens the broker link when the build asked for live control.
  void start() {
    if (!config.live || _bus != null) return;
    _bus = _injectedBus ??
        createHomeBus(
          config,
          onStatus: _onBusStatus,
          onState: applyState,
        );
    _bus!.connect();
  }

  void _onBusStatus(BusState state, String detail) {
    busState = state;
    busDetail = detail;
    notifyListeners();
  }

  Device? byId(String? id) {
    if (id == null) return null;
    for (final d in devices) {
      if (d.id == id) return d;
    }
    return null;
  }

  List<String> get roomNames {
    final names = <String>[];
    for (final d in devices) {
      if (!names.contains(d.room)) names.add(d.room);
    }
    return names;
  }

  List<Device> devicesIn(String room) =>
      devices.where((d) => d.room == room).toList();

  List<ActivityEntry> activityFor(String deviceId) => activity
      .where((entry) => entry.deviceId == deviceId)
      .take(4)
      .toList();

  void go(String name, {String? id, String? room}) {
    history.add(route);
    route = AppRoute(name, id: id, room: room);
    notifyListeners();
  }

  void back() {
    if (history.isEmpty) {
      route = const AppRoute('dashboard');
    } else {
      route = history.removeLast();
    }
    notifyListeners();
  }

  void tab(String name) {
    history.clear();
    route = AppRoute(name);
    notifyListeners();
  }

  void setFilter(String value) {
    filter = value;
    notifyListeners();
  }

  void mutate(VoidCallback change, {String? logText, String? deviceId}) {
    final before = _snapshotAll();
    change();
    _publishDiff(before);
    if (logText != null) {
      log(logText, deviceId: deviceId);
    }
    notifyListeners();
  }

  void log(String text, {bool ok = true, String? deviceId}) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    activity.insert(0, ActivityEntry(text, time, ok: ok, deviceId: deviceId));
    if (activity.length > 30) {
      activity.removeRange(30, activity.length);
    }
  }

  void toggle(Device d) {
    if (!_onOffTypes.contains(d.type)) return;
    final next = !d.on;
    mutate(() => d.on = next,
        logText: '${d.name} -> ${next ? 'on' : 'off'}', deviceId: d.id);
  }

  CommandResult run(String text) {
    final before = _snapshotAll();
    final result = runCommand(text, CommandStore(devices, plates));
    _publishDiff(before);
    results.insert(0, result);
    if (results.length > 6) {
      results.removeRange(6, results.length);
    }
    log(result.text, ok: result.ok, deviceId: result.deviceId);
    notifyListeners();
    return result;
  }

  /// Applies a Zigbee2MQTT state message. This is inbound truth, so it never
  /// loops back out to the broker.
  void applyState(String id, Map<String, dynamic> fields) {
    final d = byId(id);
    if (d == null) return;

    if (fields.containsKey('__online')) {
      d.online = fields['__online'] == true;
      notifyListeners();
      return;
    }

    final state = fields['state'];
    if (state is String) {
      switch (state.toUpperCase()) {
        case 'ON':
        case 'OFF':
          d.on = state.toUpperCase() == 'ON';
          break;
        case 'OPEN':
        case 'CLOSE':
        case 'STOP':
          d.state = state.toUpperCase() == 'OPEN'
              ? 'open'
              : state.toUpperCase() == 'CLOSE'
                  ? 'closed'
                  : 'stopped';
          if (state.toUpperCase() == 'OPEN') d.position = 100;
          if (state.toUpperCase() == 'CLOSE') d.position = 0;
          break;
        case 'LOCK':
        case 'UNLOCK':
          d.locked = state.toUpperCase() == 'LOCK';
          break;
      }
    }

    final brightness = _asInt(fields['brightness']);
    if (brightness != null) {
      // Zigbee2MQTT reports 0-254; the UI works in percent.
      d.brightness = (brightness.clamp(0, 254) * 100 / 254).round();
    }

    final mireds = _asInt(fields['color_temp']);
    if (mireds != null && mireds > 0) {
      d.kelvin = (1000000 / mireds).round().clamp(2700, 6500).toInt();
    }

    final colour = fields['color'];
    if (colour is Map && colour['hex'] is String) {
      d.colour = nearestColourName(colour['hex'] as String);
    }

    final position = _asInt(fields['position']);
    if (position != null) {
      d.position = position.clamp(0, 100).toInt();
      if (d.type == 'cover') d.state = d.position == 0 ? 'closed' : 'open';
    }

    final mode = fields['system_mode'];
    if (mode is String) d.mode = mode;

    final heat = _asInt(fields['occupied_heating_setpoint']) ??
        _asInt(fields['current_heating_setpoint']);
    final cool = _asInt(fields['occupied_cooling_setpoint']);
    if (heat != null) d.target = heat;
    if (cool != null && d.mode != 'heat') d.target = cool;

    final temperature =
        _asDouble(fields['temperature']) ?? _asDouble(fields['current_temperature']);
    if (temperature != null) {
      if (d.type == 'sensor' && d.metric.toLowerCase().contains('temp')) {
        d.value = temperature;
      } else {
        d.current = temperature;
      }
    }

    final humidity = _asInt(fields['humidity']);
    if (humidity != null) d.humidity = humidity;

    final battery = _asInt(fields['battery']);
    if (battery != null) d.battery = battery;

    final speed = _asInt(fields['speed']) ?? _asInt(fields['fan_speed']);
    if (speed != null) d.speed = speed;

    final preset = fields['preset_mode'];
    if (preset is String) d.preset = preset;

    notifyListeners();
  }

  int? _asInt(Object? value) {
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  void addPlate(String plate) {
    final clean = plate.toUpperCase().trim();
    if (plates.contains(clean)) {
      plateMessage = '$clean is already on the whitelist';
      plateMessageOk = false;
    } else {
      plates.add(clean);
      plateMessage = 'Added $clean to the whitelist (${plates.length} plates)';
      plateMessageOk = true;
      log(plateMessage!, deviceId: 'gate');
    }
    notifyListeners();
  }

  void removePlate(String plate) {
    plates.remove(plate);
    plateMessage = 'Removed $plate';
    plateMessageOk = true;
    log(plateMessage!, deviceId: 'gate');
    notifyListeners();
  }

  void checkPlate(String plate) {
    final clean = plate.toUpperCase().trim();
    final known = plates.contains(clean);
    plateMessage = known
        ? '$clean is on the whitelist - gate access granted'
        : '$clean is not on the whitelist - gate stays closed';
    plateMessageOk = known;
    notifyListeners();
  }

  void setPlateMessage(String message, {bool ok = true}) {
    plateMessage = message;
    plateMessageOk = ok;
    notifyListeners();
  }

  void addFound(String name) {
    if (!added.contains(name)) {
      added.add(name);
      log('$name added to your home');
    }
    notifyListeners();
  }

  Map<String, _Snapshot> _snapshotAll() => <String, _Snapshot>{
        for (final d in devices) d.id: _Snapshot(d),
      };

  void _publishDiff(Map<String, _Snapshot> before) {
    final bus = _bus;
    if (bus == null) return;
    for (final entry in before.entries) {
      final d = byId(entry.key);
      if (d == null) continue;
      final patch = _patchFor(entry.value, d);
      if (patch == null) continue;
      bus.publish(<String>[d.id], jsonEncode(patch));
    }
  }

  Map<String, Object>? _patchFor(_Snapshot before, Device d) {
    if (!kMqttTypes.contains(d.type)) return null;
    final patch = <String, Object>{};

    if (_onOffTypes.contains(d.type) && before.on != d.on) {
      patch['state'] = d.on ? 'ON' : 'OFF';
    }
    switch (d.type) {
      case 'light':
        if (before.brightness != d.brightness) {
          patch['brightness'] = (d.brightness * 254 / 100).round();
        }
        if (before.kelvin != d.kelvin) {
          patch['color_temp'] = (1000000 / d.kelvin).round();
        }
        if (before.colour != d.colour) {
          patch['color'] = <String, String>{
            'hex': kColourHex[d.colour] ?? kColourHex['warm']!,
          };
        }
        break;
      case 'fan':
        if (before.speed != d.speed) patch['speed'] = d.speed;
        if (before.preset != d.preset) patch['preset_mode'] = d.preset;
        break;
      case 'climate':
        if (before.mode != d.mode) patch['system_mode'] = d.mode;
        if (before.target != d.target) {
          patch[d.mode == 'heat'
                  ? 'occupied_heating_setpoint'
                  : 'occupied_cooling_setpoint'] =
              d.target;
        }
        break;
      case 'cover':
        if (before.position != d.position) patch['position'] = d.position;
        if (before.state != d.state) {
          patch['state'] = d.state == 'open'
              ? 'OPEN'
              : d.state == 'closed'
                  ? 'CLOSE'
                  : 'STOP';
        }
        break;
      case 'lock':
        if (before.locked != d.locked) {
          patch['state'] = d.locked ? 'LOCK' : 'UNLOCK';
        }
        break;
    }
    return patch.isEmpty ? null : patch;
  }

  @override
  void dispose() {
    _bus?.dispose();
    super.dispose();
  }
}

class _Snapshot {
  _Snapshot(Device d)
      : on = d.on,
        brightness = d.brightness,
        kelvin = d.kelvin,
        colour = d.colour,
        speed = d.speed,
        preset = d.preset,
        mode = d.mode,
        target = d.target,
        position = d.position,
        state = d.state,
        locked = d.locked;

  final bool on;
  final int brightness;
  final int kelvin;
  final String colour;
  final int speed;
  final String preset;
  final String mode;
  final int target;
  final int position;
  final String state;
  final bool locked;
}

String nearestColourName(String hex) {
  final value = hex.replaceAll('#', '');
  if (value.length < 6) return 'warm';
  final r = int.tryParse(value.substring(0, 2), radix: 16) ?? 0;
  final g = int.tryParse(value.substring(2, 4), radix: 16) ?? 0;
  final b = int.tryParse(value.substring(4, 6), radix: 16) ?? 0;
  String best = 'warm';
  var bestDistance = double.infinity;
  kColourHex.forEach((name, colourHex) {
    final c = colourHex.replaceAll('#', '');
    if (c.length < 6) return;
    final cr = int.tryParse(c.substring(0, 2), radix: 16) ?? 0;
    final cg = int.tryParse(c.substring(2, 4), radix: 16) ?? 0;
    final cb = int.tryParse(c.substring(4, 6), radix: 16) ?? 0;
    final distance = ((r - cr) * (r - cr) +
            (g - cg) * (g - cg) +
            (b - cb) * (b - cb))
        .toDouble();
    if (distance < bestDistance) {
      bestDistance = distance;
      best = name;
    }
  });
  return best;
}
