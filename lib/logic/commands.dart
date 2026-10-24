import 'dart:convert';

import '../data/devices.dart';

class CommandItem {
  const CommandItem(this.label, this.phrase);

  final String label;
  final String phrase;
}

class CommandGroup {
  const CommandGroup(this.title, this.items);

  final String title;
  final List<CommandItem> items;
}

class CommandResult {
  const CommandResult({
    required this.ok,
    required this.text,
    this.action = '',
    this.deviceId,
  });

  final bool ok;
  final String text;
  final String action;
  final String? deviceId;
}

class CommandStore {
  CommandStore(this.devices, this.plates);

  final List<Device> devices;
  final List<String> plates;
}

const Map<String, String> _colourHex = <String, String>{
  'white': '#fbf6ea',
  'warm': '#ffd29a',
  'amber': '#ffb45c',
  'red': '#df5b4c',
  'green': '#63a06c',
  'blue': '#4f8ecf',
  'cool': '#e4eefb',
};

const List<CommandGroup> commandGroups = <CommandGroup>[
  CommandGroup('Lights', <CommandItem>[
    CommandItem('Turn lights on', 'turn on the lounge lights'),
    CommandItem('Turn lights off', 'turn off the lounge lights'),
    CommandItem('Toggle lights', 'toggle the bedroom lights'),
    CommandItem('Set light brightness', 'set bedroom 1 brightness to 60 percent'),
    CommandItem('Set light colour', 'set the lamp colour to blue'),
    CommandItem('Set colour temperature',
        'set the kitchen light colour temperature to 5000 kelvin'),
  ]),
  CommandGroup('Switches and fans', <CommandItem>[
    CommandItem('Turn switch on', 'turn on the coffee plug'),
    CommandItem('Turn switch off', 'turn off the tv plug'),
    CommandItem('Toggle switch', 'toggle the tv plug'),
    CommandItem('Turn fan on', 'turn on the bedroom fan'),
    CommandItem('Turn fan off', 'turn off the bedroom fan'),
    CommandItem('Set fan speed', 'set the bedroom fan speed to 4'),
    CommandItem('Set fan preset', 'set the bedroom fan preset to sleep'),
  ]),
  CommandGroup('Climate', <CommandItem>[
    CommandItem('Set temperature',
        'set the thermostat temperature to 22 degrees'),
    CommandItem('Set heating or cooling', 'set the climate mode to heating'),
    CommandItem('Turn climate on', 'turn on climate control'),
    CommandItem('Turn climate off', 'turn off climate control'),
  ]),
  CommandGroup('Covers and doors', <CommandItem>[
    CommandItem('Open blinds', 'open the lounge blinds'),
    CommandItem('Close blinds', 'close the lounge blinds'),
    CommandItem('Stop blinds', 'stop the lounge blinds'),
    CommandItem('Set blinds position',
        'set the lounge blinds position to 40 percent'),
    CommandItem('Open garage', 'open the garage door'),
    CommandItem('Close garage', 'close the garage door'),
    CommandItem('Stop garage', 'stop the garage door'),
    CommandItem('Lock door', 'lock the front door'),
    CommandItem('Unlock door', 'unlock the front door'),
  ]),
  CommandGroup('Media', <CommandItem>[
    CommandItem('Play media', 'play media in the lounge'),
    CommandItem('Pause media', 'pause the music'),
    CommandItem('Stop media', 'stop the media'),
    CommandItem('Next track', 'next track'),
    CommandItem('Previous track', 'previous track'),
    CommandItem('Set volume', 'set media volume to 30'),
    CommandItem('Mute', 'mute the tv'),
    CommandItem('Unmute', 'unmute the tv'),
    CommandItem('Select source', 'select media source HDMI 2'),
  ]),
  CommandGroup('Scenes', <CommandItem>[
    CommandItem('Run scene', 'activate movie night'),
    CommandItem('Run automation', 'run the morning routine'),
    CommandItem('Run script', 'run the welcome home script'),
  ]),
  CommandGroup('Vacuum and alarm', <CommandItem>[
    CommandItem('Start vacuum', 'start the vacuum'),
    CommandItem('Pause vacuum', 'pause the vacuum'),
    CommandItem('Stop vacuum', 'stop the vacuum'),
    CommandItem('Send to dock', 'send the vacuum to the dock'),
    CommandItem('Locate vacuum', 'locate the vacuum'),
    CommandItem('Arm alarm', 'arm the alarm'),
    CommandItem('Disarm alarm', 'disarm the alarm'),
    CommandItem('Trigger siren', 'trigger the siren'),
    CommandItem('Stop siren', 'stop the siren'),
  ]),
  CommandGroup('Camera and sensors', <CommandItem>[
    CommandItem('View camera stream', 'view the camera stream'),
    CommandItem('Take snapshot', 'take a camera snapshot'),
    CommandItem('Record clip', 'record a camera clip'),
    CommandItem('Read sensor', 'read the entrance sensor'),
    CommandItem('Send remote command', 'send a remote command to the tv'),
  ]),
  CommandGroup('Gate and plates', <CommandItem>[
    CommandItem('Open gate', 'open the gate'),
    CommandItem('Close gate', 'close the gate'),
    CommandItem('Stop gate', 'stop the gate'),
    CommandItem('Gate status', 'check the gate status'),
    CommandItem('Check plate', 'check plate ABC 1234'),
    CommandItem('Add plate', 'add plate XYZ 9876 to the whitelist'),
    CommandItem('Remove plate', 'remove plate XYZ 9876 from the whitelist'),
  ]),
];

const Map<String, int> _wordNumbers = <String, int>{
  'zero': 0,
  'one': 1,
  'two': 2,
  'three': 3,
  'four': 4,
  'five': 5,
  'six': 6,
  'seven': 7,
  'eight': 8,
  'nine': 9,
  'ten': 10,
  'fifteen': 15,
  'twenty': 20,
  'thirty': 30,
  'forty': 40,
  'fifty': 50,
  'sixty': 60,
  'seventy': 70,
  'eighty': 80,
  'ninety': 90,
  'hundred': 100,
  'half': 50,
  'full': 100,
  'max': 100,
  'minimum': 10,
  'dim': 20,
  'low': 20,
  'bright': 90,
};

const Set<String> _stop = <String>{
  'the', 'a', 'an', 'to', 'and', 'in', 'of', 'on', 'off', 'my', 'for', 'with',
  'please', 'turn', 'set', 'value', 'read', 'check', 'send', 'open', 'close',
  'stop', 'start', 'up', 'down', 'at', 'is', 'it', 'all', 'every', 'media',
  'control', 'mode', 'colour', 'color', 'temperature', 'speed', 'preset',
  'volume', 'source', 'track', 'fan', 'plug', 'switch', 'sensor', 'camera',
  'gate', 'alarm', 'vacuum', 'blinds', 'curtains', 'door', 'lock', 'unlock',
  'scene', 'automation', 'script', 'remote',
};

const Set<String> _lightNouns = <String>{'light', 'lights', 'lamp', 'lamps'};

String normalizeText(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[-_/]'), ' ')
      .replaceAll(RegExp(r'[^a-z0-9% ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

CommandResult _fail(String message) =>
    CommandResult(ok: false, text: message);

CommandResult _success(
  List<Device> targets,
  String text,
  String action,
) {
  return CommandResult(
    ok: true,
    text: text,
    action: action,
    deviceId: targets.isEmpty ? null : targets.first.id,
  );
}

String _mqtt(Device device, Map<String, Object> patch) {
  return 'zigbee2mqtt/${device.id}/set ${jsonEncode(patch)}';
}

String _mqttMany(List<Device> targets, Map<String, Object> patch) {
  if (targets.isEmpty) return '';
  final line = _mqtt(targets.first, patch);
  if (targets.length == 1) return line;
  return '$line  (+${targets.length - 1} more)';
}

String _listNames(List<Device> targets) {
  final names = targets.map((d) => d.name).toList();
  if (names.length <= 1) return names.join();
  return '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
}

int _clampInt(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

int? _digitAfter(String text, List<String> words) {
  for (final word in words) {
    final match =
        RegExp('$word\\s*(?:to|at|is)?\\s*(\\d{1,4})').firstMatch(text);
    if (match != null) return int.tryParse(match.group(1) ?? '');
  }
  final percent = RegExp(r'(\d{1,4})\s*(?:%|percent)').firstMatch(text);
  if (percent != null) return int.tryParse(percent.group(1) ?? '');
  final to = RegExp(r'\bto\s+(\d{1,4})').firstMatch(text);
  if (to != null) return int.tryParse(to.group(1) ?? '');
  return null;
}

int? _wordNumber(String text) {
  for (final part in text.split(' ')) {
    final value = _wordNumbers[part];
    if (value != null) return value;
  }
  return null;
}

int? _numberAfter(String text, List<String> words) {
  final digit = _digitAfter(text, words);
  if (digit != null) return digit;
  return _wordNumber(text);
}

List<Device> _pick(CommandStore store, List<String> types, String text) {
  final list = store.devices.where((d) => types.contains(d.type)).toList();
  if (list.isEmpty) return <Device>[];
  if (RegExp(r'\b(all|every|everything|whole)\b').hasMatch(text)) return list;

  final tokens = text
      .split(' ')
      .where((t) => t.length > 2 && !_stop.contains(t))
      .toList();

  var best = 0;
  final scores = <String, int>{};
  for (final device in list) {
    final hay = '${device.name} ${device.room} ${device.metric}'.toLowerCase();
    var score = 0;
    for (final token in tokens) {
      if (hay.contains(token)) score += token.length > 9 ? 9 : token.length;
    }
    scores[device.id] = score;
    if (score > best) best = score;
  }

  if (best == 0) return <Device>[list.first];
  return list.where((d) => scores[d.id] == best).toList();
}

String? _colourIn(String text) {
  for (final name in kColours.keys) {
    if (RegExp('\\b$name\\b').hasMatch(text)) return name;
  }
  return null;
}

CommandResult runCommand(String raw, CommandStore store) {
  final text = normalizeText(raw);
  if (text.isEmpty) {
    return _fail("Say something like 'turn on the kitchen lights'.");
  }

  if (RegExp(r'\bplate\b').hasMatch(text)) {
    return _handlePlate(raw, store);
  }

  final named = _findNamedScene(text, store);
  if (named != null) return _runScene(named, store);

  if (RegExp(r'\bgate\b').hasMatch(text)) return _handleGate(text, store);
  if (RegExp(r'\bsiren\b').hasMatch(text)) return _handleSiren(text, store);
  if (RegExp(r'\balarm\b').hasMatch(text)) return _handleAlarm(text, store);
  if (RegExp(r'\bcamera\b').hasMatch(text)) return _handleCamera(text, store);
  if (RegExp(r'\bvacuum\b').hasMatch(text)) return _handleVacuum(text, store);
  if (RegExp(r'\b(blinds?|curtains?|shades?|covers?)\b').hasMatch(text)) {
    return _handleCover(text, store);
  }
  if (RegExp(r'\bgarage\b').hasMatch(text)) return _handleGarage(text, store);
  if (RegExp(r'\b(lock|unlock)\b').hasMatch(text) ||
      RegExp(r'\bdoor\b').hasMatch(text)) {
    return _handleLock(text, store);
  }
  if (RegExp(r'\bremote\b').hasMatch(text)) return _handleRemote(text, store);
  if (RegExp(r'\b(media|music|song|track|volume|mute|unmute)\b')
      .hasMatch(text)) {
    return _handleMedia(text, store);
  }
  if (RegExp(r'\bsensor\b|\bhumidity\b|\bread\b').hasMatch(text)) {
    return _handleSensor(text, store);
  }
  if (RegExp(
          r'\b(thermostat|climate|heating|cooling|temperature|degrees|conditioner|aircon|air con)\b')
      .hasMatch(text)) {
    return _handleClimate(text, store);
  }
  if (RegExp(r'\bfan\b').hasMatch(text)) return _handleFan(text, store);
  if (RegExp(r'\b(plug|switch|socket|outlet)\b').hasMatch(text)) {
    return _handleSwitch(text, store);
  }
  if (RegExp(r'\b(lights?|lamps?|brightness|dimmer)\b').hasMatch(text)) {
    return _handleLights(text, store);
  }
  if (RegExp(r'\b(scene|automation|script|routine)\b').hasMatch(text)) {
    return _handleScene(text, store);
  }
  if (RegExp(r'\b(tv|television|speaker)\b').hasMatch(text)) {
    return _handleMedia(text, store);
  }

  return _fail("No device matched that. Try 'turn on the kitchen lights'.");
}

bool _hasLightMatch(String text, CommandStore store) {
  final tokens = text
      .split(' ')
      .where((t) => t.length > 2 && !_lightNouns.contains(t))
      .toList();
  for (final d in store.devices) {
    if (d.type != 'light') continue;
    final hay = '${d.name} ${d.room}'.toLowerCase();
    for (final token in tokens) {
      if (hay.contains(token)) return true;
    }
  }
  return false;
}

String? _strayRoom(String text, CommandStore store) {
  final rooms = store.devices.map((d) => d.room).toSet();
  for (final room in rooms) {
    if (!text.contains(room.toLowerCase())) continue;
    final hasLight = store.devices
        .any((d) => d.type == 'light' && d.room == room);
    if (!hasLight) return room;
  }
  return null;
}

CommandResult _handleLights(String text, CommandStore store) {
  final targets = _pick(store, <String>['light'], text);
  if (targets.isEmpty) return _fail('There are no lights set up yet.');

  if (!_hasLightMatch(text, store) &&
      !RegExp(r'\b(all|every|everything|whole)\b').hasMatch(text)) {
    final stray = _strayRoom(text, store);
    if (stray != null) {
      return _fail("I don't have lights set up for '${stray.toLowerCase()}'.");
    }
  }

  if (RegExp(r'\b(colour|color)\s+temperature\b|\bkelvin\b').hasMatch(text)) {
    var value = _numberAfter(text, <String>['temperature', 'kelvin']);
    if (value == null) {
      if (RegExp(r'\bwarm\b').hasMatch(text)) {
        value = 2700;
      } else if (RegExp(r'\bneutral\b').hasMatch(text)) {
        value = 4000;
      } else if (RegExp(r'\bdaylight\b').hasMatch(text)) {
        value = 5500;
      } else if (RegExp(r'\bcool\b').hasMatch(text)) {
        value = 6200;
      }
    }
    if (value == null) {
      return _fail("Which warmth? Try 'set the kitchen light to 3000 kelvin'.");
    }
    final kelvin = _clampInt(value, 2700, 6500);
    for (final d in targets) {
      d.kelvin = kelvin;
      d.on = true;
    }
    return _success(targets, '${_listNames(targets)} -> $kelvin K',
        _mqttMany(targets, <String, Object>{'colour_temp': kelvin}));
  }

  if (RegExp(r'\b(colour|color)\b').hasMatch(text)) {
    final name = _colourIn(text);
    if (name == null) return _fail("Which colour? Try 'set the lamp to blue'.");
    for (final d in targets) {
      d.colour = name;
      d.on = true;
    }
    return _success(
      targets,
      '${_listNames(targets)} -> $name',
      _mqttMany(targets, <String, Object>{
        'colour': <String, String>{'hex': _colourHex[name] ?? ''},
      }),
    );
  }

  if (RegExp(r'\b(brightness|dim|dimmer|brighter)\b').hasMatch(text)) {
    final value = _numberAfter(text, <String>['brightness']);
    if (value == null) {
      return _fail(
          "How bright? Try 'set the kitchen brightness to 60 percent'.");
    }
    final brightness = _clampInt(value, 1, 100);
    for (final d in targets) {
      d.brightness = brightness;
      d.on = true;
    }
    return _success(
      targets,
      '${_listNames(targets)} -> $brightness%',
      _mqttMany(targets, <String, Object>{
        'brightness': brightness,
        'state': 'ON',
      }),
    );
  }

  if (RegExp(r'\bdim\b').hasMatch(text) &&
      _numberAfter(text, <String>['brightness']) == null) {
    for (final d in targets) {
      d.brightness = 30;
    }
    return _success(targets, '${_listNames(targets)} -> 30%',
        _mqttMany(targets, <String, Object>{'brightness': 30}));
  }

  return _setSimpleState(
    text,
    targets,
    (on) => <String, Object>{'state': on ? 'ON' : 'OFF'},
    "Tell me on, off or toggle, like 'turn on the kitchen lights'.",
  );
}

CommandResult _handleSwitch(String text, CommandStore store) {
  final targets = _pick(store, <String>['switch'], text);
  if (targets.isEmpty) return _fail('There are no plugs set up yet.');
  return _setSimpleState(
    text,
    targets,
    (on) => <String, Object>{'state': on ? 'ON' : 'OFF'},
    "Tell me on, off or toggle, like 'turn off the tv plug'.",
  );
}

CommandResult _handleFan(String text, CommandStore store) {
  final targets = _pick(store, <String>['fan'], text);
  if (targets.isEmpty) return _fail('There are no fans set up yet.');

  if (RegExp(r'\bpreset\b').hasMatch(text)) {
    const presets = <String>['normal', 'sleep', 'auto', 'boost', 'eco'];
    String? preset;
    for (final p in presets) {
      if (RegExp('\\b$p\\b').hasMatch(text)) {
        preset = p;
        break;
      }
    }
    if (preset == null) {
      return _fail('Which preset? Normal, sleep, auto, boost or eco.');
    }
    for (final d in targets) {
      d.preset = preset;
      d.on = true;
    }
    return _success(targets, '${_listNames(targets)} preset -> $preset',
        _mqttMany(targets, <String, Object>{'preset_mode': preset}));
  }

  if (RegExp(r'\bspeed\b').hasMatch(text)) {
    final value = _numberAfter(text, <String>['speed']);
    if (value == null) return _fail('Which speed? Say a number from 1 to 5.');
    final speed = _clampInt(value, 1, 5);
    for (final d in targets) {
      d.speed = speed;
      d.on = true;
    }
    return _success(targets, '${_listNames(targets)} speed -> $speed',
        _mqttMany(targets, <String, Object>{'speed': speed}));
  }

  return _setSimpleState(
    text,
    targets,
    (on) => <String, Object>{'state': on ? 'ON' : 'OFF'},
    "Tell me on, off or toggle, like 'turn on the bedroom fan'.",
  );
}

CommandResult _handleClimate(String text, CommandStore store) {
  final targets = _pick(store, <String>['climate'], text);
  if (targets.isEmpty) return _fail('There is no thermostat set up yet.');

  final wantsHeat = RegExp(r'\b(heat|heating|warm)\b').hasMatch(text);
  final wantsCool = RegExp(r'\b(cool|cooling)\b').hasMatch(text);
  final wantsAuto = RegExp(r'\bauto\b').hasMatch(text);

  if (wantsHeat || wantsCool || (wantsAuto && RegExp(r'\bmode\b').hasMatch(text))) {
    final mode = wantsHeat ? 'heat' : (wantsCool ? 'cool' : 'auto');
    for (final d in targets) {
      d.mode = mode;
      d.on = true;
    }
    return _success(targets, '${_listNames(targets)} mode -> $mode',
        _mqttMany(targets, <String, Object>{'system_mode': mode}));
  }

  if (RegExp(r'\b(temperature|thermostat|degrees)\b').hasMatch(text) ||
      RegExp(r'\bto\s+\d').hasMatch(text)) {
    final value = _numberAfter(text, <String>['temperature', 'thermostat']);
    if (value == null) {
      return _fail(
          "Which temperature? Try 'set the thermostat to 22 degrees'.");
    }
    final target = _clampInt(value, 16, 30);
    for (final d in targets) {
      d.target = target;
      d.on = true;
    }
    return _success(
      targets,
      '${_listNames(targets)} target -> ${target}\u00B0C',
      _mqttMany(targets, <String, Object>{
        'occupied_heating_setpoint': target,
      }),
    );
  }

  return _setSimpleState(
    text,
    targets,
    (on) => <String, Object>{'state': on ? 'ON' : 'OFF'},
    'Tell me on or off, or ask for a temperature.',
  );
}

CommandResult _handleCover(String text, CommandStore store) {
  final targets = _pick(store, <String>['cover'], text);
  if (targets.isEmpty) return _fail('There are no blinds or curtains set up yet.');

  if (RegExp(r'\bposition\b|\bpercent\b|\b\d+\s*%').hasMatch(text)) {
    final value = _digitAfter(text, <String>['position']);
    if (value == null) {
      return _fail(
          "Which position? Say a percentage, like 'set the blinds to 40 percent'.");
    }
    final position = _clampInt(value, 0, 100);
    for (final d in targets) {
      d.position = position;
      d.state = position == 0 ? 'closed' : 'open';
    }
    return _success(targets, '${_listNames(targets)} -> $position% open',
        _mqttMany(targets, <String, Object>{'position': position}));
  }

  if (RegExp(r'\b(stop|halt|pause)\b').hasMatch(text)) {
    for (final d in targets) {
      d.state = 'stopped';
    }
    return _success(targets, '${_listNames(targets)} -> stopped',
        _mqttMany(targets, <String, Object>{'state': 'STOP'}));
  }

  if (RegExp(r'\bopen\b').hasMatch(text)) {
    for (final d in targets) {
      d.position = 100;
      d.state = 'open';
    }
    return _success(targets, '${_listNames(targets)} -> open',
        _mqttMany(targets, <String, Object>{'state': 'OPEN'}));
  }

  if (RegExp(r'\b(close|shut)\b').hasMatch(text)) {
    for (final d in targets) {
      d.position = 0;
      d.state = 'closed';
    }
    return _success(targets, '${_listNames(targets)} -> closed',
        _mqttMany(targets, <String, Object>{'state': 'CLOSE'}));
  }

  return _fail('Tell me open, close, stop or a position.');
}

CommandResult _handleGarage(String text, CommandStore store) {
  final targets = _pick(store, <String>['garage'], text);
  if (targets.isEmpty) return _fail('There is no garage door set up yet.');

  if (RegExp(r'\bstatus\b').hasMatch(text)) {
    return _success(targets, 'Garage Door is ${targets.first.state}.', '');
  }
  if (RegExp(r'\b(stop|halt)\b').hasMatch(text)) {
    for (final d in targets) {
      d.state = 'stopped';
    }
    return _success(targets, 'Garage Door -> stopped',
        _mqttMany(targets, <String, Object>{'state': 'STOP'}));
  }
  if (RegExp(r'\bopen\b').hasMatch(text)) {
    for (final d in targets) {
      d.state = 'open';
    }
    return _success(targets, 'Garage Door -> opening',
        _mqttMany(targets, <String, Object>{'state': 'OPEN'}));
  }
  if (RegExp(r'\b(close|shut)\b').hasMatch(text)) {
    for (final d in targets) {
      d.state = 'closed';
    }
    return _success(targets, 'Garage Door -> closing',
        _mqttMany(targets, <String, Object>{'state': 'CLOSE'}));
  }
  return _fail('Tell me open, close or stop for the garage.');
}

CommandResult _handleLock(String text, CommandStore store) {
  final targets = _pick(store, <String>['lock'], text);
  if (targets.isEmpty) return _fail('There are no door locks set up yet.');

  if (RegExp(r'\bunlock\b').hasMatch(text)) {
    for (final d in targets) {
      d.locked = false;
    }
    return _success(targets, '${_listNames(targets)} -> unlocked',
        _mqttMany(targets, <String, Object>{'state': 'UNLOCK'}));
  }
  if (RegExp(r'\block\b').hasMatch(text)) {
    for (final d in targets) {
      d.locked = true;
    }
    return _success(targets, '${_listNames(targets)} -> locked',
        _mqttMany(targets, <String, Object>{'state': 'LOCK'}));
  }
  return _fail("Tell me lock or unlock, like 'lock the front door'.");
}

CommandResult _handleMedia(String text, CommandStore store) {
  final targets = _pick(store, <String>['media'], text);
  if (targets.isEmpty) return _fail('There are no players set up yet.');
  final player = targets.first;

  if (RegExp(r'\bsource\b').hasMatch(text)) {
    const known = <String>[
      'HDMI 1',
      'HDMI 2',
      'Spotify',
      'Bluetooth',
      'AirPlay',
      'Radio',
    ];
    String? source;
    for (final option in known) {
      if (text.contains(option.toLowerCase())) {
        source = option;
        break;
      }
    }
    if (source == null) {
      final hdmi = RegExp(r'hdmi\s*(\d)').firstMatch(text);
      if (hdmi != null) source = 'HDMI ${hdmi.group(1)}';
    }
    if (source == null) {
      return _fail('Which source? HDMI 1, HDMI 2, Spotify, Bluetooth or Radio.');
    }
    for (final d in targets) {
      d.source = source;
    }
    return _success(targets, '${_listNames(targets)} source -> $source',
        _mqttMany(targets, <String, Object>{'source': source}));
  }

  if (RegExp(r'\bvolume\b').hasMatch(text)) {
    if (RegExp(r'\bup\b').hasMatch(text)) {
      for (final d in targets) {
        d.volume = _clampInt(d.volume + 10, 0, 100);
        d.muted = false;
      }
      return _success(
        targets,
        '${_listNames(targets)} volume -> ${player.volume}%',
        _mqttMany(targets, <String, Object>{'volume': player.volume}),
      );
    }
    if (RegExp(r'\bdown\b').hasMatch(text)) {
      for (final d in targets) {
        d.volume = _clampInt(d.volume - 10, 0, 100);
        d.muted = false;
      }
      return _success(
        targets,
        '${_listNames(targets)} volume -> ${player.volume}%',
        _mqttMany(targets, <String, Object>{'volume': player.volume}),
      );
    }
    final value = _numberAfter(text, <String>['volume']);
    if (value == null) {
      return _fail("Which volume? Say a number, like 'volume to 30'.");
    }
    final level = _clampInt(value, 0, 100);
    for (final d in targets) {
      d.volume = level;
      d.muted = false;
      d.on = true;
    }
    return _success(targets, '${_listNames(targets)} volume -> $level%',
        _mqttMany(targets, <String, Object>{'volume': level}));
  }

  if (RegExp(r'\bunmute\b').hasMatch(text)) {
    for (final d in targets) {
      d.muted = false;
      d.on = true;
    }
    return _success(targets, '${_listNames(targets)} -> unmuted',
        _mqttMany(targets, <String, Object>{'mute': false}));
  }

  if (RegExp(r'\bmute\b').hasMatch(text)) {
    for (final d in targets) {
      d.muted = true;
    }
    return _success(targets, '${_listNames(targets)} -> muted',
        _mqttMany(targets, <String, Object>{'mute': true}));
  }

  if (RegExp(r'\b(next|skip)\b').hasMatch(text)) {
    for (final d in targets) {
      d.track += 1;
      d.playing = true;
      d.on = true;
    }
    return _success(
      targets,
      '${_listNames(targets)} -> next track (${player.track})',
      _mqttMany(targets, <String, Object>{'command': 'NEXT'}),
    );
  }

  if (RegExp(r'\b(previous|prev|back)\b').hasMatch(text)) {
    for (final d in targets) {
      d.track = d.track - 1 < 1 ? 1 : d.track - 1;
      d.playing = true;
      d.on = true;
    }
    return _success(
      targets,
      '${_listNames(targets)} -> previous track (${player.track})',
      _mqttMany(targets, <String, Object>{'command': 'PREVIOUS'}),
    );
  }

  if (RegExp(r'\bpause\b').hasMatch(text)) {
    for (final d in targets) {
      d.playing = false;
    }
    return _success(targets, '${_listNames(targets)} -> paused',
        _mqttMany(targets, <String, Object>{'command': 'PAUSE'}));
  }

  if (RegExp(r'\bstop\b').hasMatch(text)) {
    for (final d in targets) {
      d.playing = false;
    }
    return _success(targets, '${_listNames(targets)} -> stopped',
        _mqttMany(targets, <String, Object>{'command': 'STOP'}));
  }

  if (RegExp(r'\bplay\b|\bresume\b').hasMatch(text)) {
    for (final d in targets) {
      d.playing = true;
      d.on = true;
    }
    return _success(targets, '${_listNames(targets)} -> playing',
        _mqttMany(targets, <String, Object>{'command': 'PLAY'}));
  }

  return _fail('Tell me play, pause, stop, next, volume or a source.');
}

CommandResult _handleVacuum(String text, CommandStore store) {
  final targets = _pick(store, <String>['vacuum'], text);
  if (targets.isEmpty) return _fail('There is no vacuum set up yet.');
  final vacuum = targets.first;

  if (RegExp(r'\b(where|locate|find)\b').hasMatch(text)) {
    return _success(
        targets, 'Robot Vacuum is in the ${vacuum.area} and is beeping.', '');
  }
  if (RegExp(r'\b(dock|base|return|charge)\b').hasMatch(text)) {
    for (final d in targets) {
      d.state = 'docked';
    }
    return _success(targets, 'Robot Vacuum -> returning to dock',
        _mqttMany(targets, <String, Object>{'command': 'return_to_base'}));
  }
  if (RegExp(r'\b(pause|hold)\b').hasMatch(text)) {
    for (final d in targets) {
      d.state = 'paused';
    }
    return _success(targets, 'Robot Vacuum -> paused',
        _mqttMany(targets, <String, Object>{'command': 'pause'}));
  }
  if (RegExp(r'\bstop\b').hasMatch(text)) {
    for (final d in targets) {
      d.state = 'idle';
    }
    return _success(targets, 'Robot Vacuum -> stopped',
        _mqttMany(targets, <String, Object>{'command': 'stop'}));
  }
  if (RegExp(r'\b(start|clean|go)\b').hasMatch(text)) {
    for (final d in targets) {
      d.state = 'cleaning';
    }
    return _success(targets, 'Robot Vacuum -> cleaning the ${vacuum.area}',
        _mqttMany(targets, <String, Object>{'command': 'start'}));
  }
  return _fail('Tell me start, pause, stop, dock or locate.');
}

CommandResult _handleAlarm(String text, CommandStore store) {
  final targets = _pick(store, <String>['alarm'], text);
  if (targets.isEmpty) return _fail('There is no alarm set up yet.');
  final alarm = targets.first;

  if (RegExp(r'\bdisarm\b|\bdisarmed\b').hasMatch(text)) {
    alarm.armed = false;
    return _success(targets, 'Alarm -> disarmed',
        _mqtt(alarm, <String, Object>{'state': 'DISARMED'}));
  }
  if (RegExp(r'\barm\b|\barmed\b').hasMatch(text)) {
    alarm.armed = true;
    if (RegExp(r'\baway\b').hasMatch(text)) {
      alarm.mode = 'away';
    } else if (RegExp(r'\bnight\b').hasMatch(text)) {
      alarm.mode = 'night';
    } else if (RegExp(r'\bhome\b').hasMatch(text)) {
      alarm.mode = 'home';
    }
    return _success(
        targets,
        'Alarm -> armed (${alarm.mode})',
        _mqtt(alarm, <String, Object>{'state': 'ARMED', 'mode': alarm.mode}));
  }
  return _success(
      targets,
      'Alarm is ${alarm.armed ? 'armed in ${alarm.mode} mode' : 'disarmed'}.',
      '');
}

CommandResult _handleSiren(String text, CommandStore store) {
  final targets = _pick(store, <String>['alarm'], text);
  if (targets.isEmpty) return _fail('There is no siren set up yet.');
  final alarm = targets.first;

  if (RegExp(r'\b(stop|off|silence|quiet)\b').hasMatch(text)) {
    alarm.siren = false;
    return _success(targets, 'Siren -> stopped',
        _mqtt(alarm, <String, Object>{'siren': false}));
  }
  if (RegExp(r'\b(trigger|sound|start|on|ring)\b').hasMatch(text)) {
    alarm.siren = true;
    return _success(targets, 'Siren -> sounding',
        _mqtt(alarm, <String, Object>{'siren': true}));
  }
  return _fail('Tell me trigger or stop for the siren.');
}

CommandResult _handleCamera(String text, CommandStore store) {
  final targets = _pick(store, <String>['camera'], text);
  if (targets.isEmpty) return _fail('There is no camera set up yet.');
  final camera = targets.first;

  if (RegExp(r'\bsnapshot|photo|picture\b').hasMatch(text)) {
    camera.snapshots += 1;
    return _success(
      targets,
      '${camera.name} -> snapshot saved (${camera.snapshots} total)',
      _mqtt(camera, <String, Object>{'command': 'snapshot'}),
    );
  }
  if (RegExp(r'\bclip|record|video\b').hasMatch(text)) {
    camera.clips += 1;
    return _success(
      targets,
      '${camera.name} -> clip recorded (${camera.clips} total)',
      _mqtt(camera, <String, Object>{'command': 'record'}),
    );
  }
  if (RegExp(r'\bstream|view|watch|live\b').hasMatch(text)) {
    camera.streaming = true;
    return _success(targets, '${camera.name} -> live stream open', '');
  }
  return _fail('Tell me stream, snapshot or record a clip.');
}

CommandResult _handleSensor(String text, CommandStore store) {
  final targets = _pick(store, <String>['sensor'], text);
  if (targets.isEmpty) return _fail('There are no sensors set up yet.');
  final sensor = targets.first;
  return _success(
    targets,
    '${sensor.name}: ${sensor.metric} ${sensor.value}${sensor.unit}',
    '',
  );
}

Device? _findNamedScene(String text, CommandStore store) {
  for (final d in store.devices) {
    if (!const <String>['scene', 'automation', 'script'].contains(d.type)) {
      continue;
    }
    if (text.contains(d.name.toLowerCase())) return d;
  }
  return null;
}

CommandResult _handleScene(String text, CommandStore store) {
  final scenes = store.devices
      .where((d) =>
          const <String>['scene', 'automation', 'script'].contains(d.type))
      .toList();
  Device? scene;

  if (RegExp(r'\bscript\b').hasMatch(text)) {
    scene = _firstOfType(scenes, 'script');
  } else if (RegExp(r'\bautomation|routine\b').hasMatch(text)) {
    scene = _firstOfType(scenes, 'automation');
  } else if (RegExp(r'\bscene\b').hasMatch(text)) {
    scene = _firstOfType(scenes, 'scene');
  }

  scene ??= _findNamedScene(text, store);
  if (scene == null) {
    return _fail(
        'Which one? Movie Night, Away Mode, Morning Routine or Welcome Home.');
  }

  return _runScene(scene, store);
}

Device? _firstOfType(List<Device> scenes, String type) {
  for (final d in scenes) {
    if (d.type == type) return d;
  }
  return null;
}

CommandResult _runScene(Device scene, CommandStore store) {
  scene.lastRun = 'just now';
  if (scene.id == 'scene_movie') {
    for (final d in store.devices) {
      if (d.id == 'lounge_light') {
        d.on = true;
        d.brightness = 20;
      }
      if (d.id == 'lounge_blinds') {
        d.position = 0;
        d.state = 'closed';
      }
      if (d.id == 'smart_tv') {
        d.on = true;
        d.playing = true;
      }
    }
  }
  return CommandResult(
    ok: true,
    text: '${scene.name} started - ${scene.description}',
    action: 'scene/${scene.id}/activate',
    deviceId: scene.id,
  );
}

CommandResult _handleRemote(String text, CommandStore store) {
  final targets = _pick(store, <String>['remote'], text);
  if (targets.isEmpty) return _fail('There is no remote set up yet.');
  final remote = targets.first;
  final command = RegExp(r'\bvolume\b').hasMatch(text)
      ? 'volume_up'
      : RegExp(r'\bchannel\b').hasMatch(text)
          ? 'channel_up'
          : 'power';
  remote.lastCommand = command;
  return _success(
    targets,
    "Sent '$command' over IR from the ${remote.name}",
    _mqtt(remote, <String, Object>{'command': command}),
  );
}

CommandResult _handleGate(String text, CommandStore store) {
  final targets = _pick(store, <String>['gate'], text);
  if (targets.isEmpty) return _fail('There is no gate set up yet.');
  final gate = targets.first;

  if (RegExp(r'\bstatus\b|\bstate\b|\bcheck\b').hasMatch(text)) {
    return _success(targets, 'Main Gate is ${gate.state}.', '');
  }
  if (RegExp(r'\b(stop|halt)\b').hasMatch(text)) {
    gate.state = 'stopped';
    return _success(targets, 'Main Gate -> stopped',
        _mqtt(gate, <String, Object>{'state': 'STOP'}));
  }
  if (RegExp(r'\bopen\b').hasMatch(text)) {
    gate.state = 'open';
    return _success(targets, 'Main Gate -> open',
        _mqtt(gate, <String, Object>{'state': 'OPEN'}));
  }
  if (RegExp(r'\b(close|shut)\b').hasMatch(text)) {
    gate.state = 'closed';
    return _success(targets, 'Main Gate -> closed',
        _mqtt(gate, <String, Object>{'state': 'CLOSE'}));
  }
  return _fail('Tell me open, close, stop or status for the gate.');
}

String? _plateIn(String raw) {
  final match =
      RegExp(r'\b([A-Za-z]{2,4})[ -]?(\d{2,4})\b').firstMatch(raw);
  if (match == null) return null;
  return '${match.group(1)!.toUpperCase()} ${match.group(2)}';
}

CommandResult _handlePlate(String raw, CommandStore store) {
  final plate = _plateIn(raw);
  if (plate == null) {
    return _fail("Which plate? Try 'check plate ABC 1234'.");
  }
  final text = normalizeText(raw);

  if (RegExp(r'\b(remove|delete|drop)\b').hasMatch(text)) {
    if (!store.plates.contains(plate)) {
      return _fail('$plate is not on the whitelist.');
    }
    store.plates.remove(plate);
    return CommandResult(
      ok: true,
      text: 'Removed $plate - ${store.plates.length} plates left',
      action: 'gate/whitelist ${jsonEncode(<String, String>{'remove': plate})}',
      deviceId: 'gate',
    );
  }

  if (RegExp(r'\badd\b').hasMatch(text)) {
    if (store.plates.contains(plate)) {
      return _fail('$plate is already on the whitelist.');
    }
    store.plates.add(plate);
    return CommandResult(
      ok: true,
      text: 'Added $plate to the whitelist (${store.plates.length} plates)',
      action: 'gate/whitelist ${jsonEncode(<String, String>{'add': plate})}',
      deviceId: 'gate',
    );
  }

  if (store.plates.contains(plate)) {
    return CommandResult(
      ok: true,
      text: '$plate is on the whitelist - gate access granted',
      action: 'gate/check ${jsonEncode(<String, String>{'plate': plate})}',
      deviceId: 'gate',
    );
  }
  return CommandResult(
    ok: false,
    text: '$plate is not on the whitelist - gate stays closed',
    action: 'gate/check ${jsonEncode(<String, String>{'plate': plate})}',
    deviceId: 'gate',
  );
}

CommandResult _setSimpleState(
  String text,
  List<Device> targets,
  Map<String, Object> Function(bool on) payload,
  String hint,
) {
  if (RegExp(r'\btoggle\b').hasMatch(text)) {
    final next = !targets.first.on;
    for (final d in targets) {
      d.on = next;
    }
    final stateText = next ? 'on' : 'off';
    return _success(targets, '${_listNames(targets)} -> $stateText',
        _mqttMany(targets, payload(next)));
  }
  if (RegExp(r'\b(on|start|enable)\b').hasMatch(text)) {
    for (final d in targets) {
      d.on = true;
    }
    return _success(
        targets, '${_listNames(targets)} -> on', _mqttMany(targets, payload(true)));
  }
  if (RegExp(r'\b(off|disable)\b').hasMatch(text)) {
    for (final d in targets) {
      d.on = false;
    }
    return _success(targets, '${_listNames(targets)} -> off',
        _mqttMany(targets, payload(false)));
  }
  return _fail(hint);
}
