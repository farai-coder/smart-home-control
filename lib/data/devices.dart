import 'package:flutter/material.dart';

const Color kAccent = Color(0xFFF2723A);
const Color kAccentDeep = Color(0xFFD95F2B);
const Color kAccentSoft = Color(0xFFFDECE3);
const Color kInk = Color(0xFF15171C);
const Color kInkSoft = Color(0xFF4B515A);
const Color kMuted = Color(0xFF8B909A);
const Color kLine = Color(0xFFEBEDF0);
const Color kCard = Color(0xFFFFFFFF);
const Color kScreen = Color(0xFFF6F7F9);
const Color kCanvas = Color(0xFFE7E8EB);
const Color kNavy = Color(0xFF17233A);

class Device {
  Device({
    required this.id,
    required this.name,
    required this.room,
    required this.type,
    this.on = false,
    this.brightness = 80,
    this.kelvin = 3000,
    this.colour = 'warm',
    this.watts = 0,
    this.speed = 2,
    this.preset = 'normal',
    this.oscillate = false,
    this.mode = 'cool',
    this.target = 22,
    this.current = 23.0,
    this.humidity = 50,
    this.fan = 'auto',
    this.swing = false,
    this.position = 0,
    this.state = 'closed',
    this.locked = true,
    this.battery = 100,
    this.playing = false,
    this.volume = 20,
    this.muted = false,
    this.source = 'HDMI 1',
    this.track = 1,
    this.armed = false,
    this.siren = false,
    this.streaming = false,
    this.snapshots = 0,
    this.clips = 0,
    this.value = 0,
    this.unit = '',
    this.metric = '',
    List<double>? history,
    this.description = '',
    this.lastRun,
    this.lastCommand = 'power',
    this.area = 'Lounge',
  }) : history = history ?? const <double>[];

  final String id;
  final String name;
  final String room;
  final String type;

  bool on;
  int brightness;
  int kelvin;
  String colour;
  int watts;
  int speed;
  String preset;
  bool oscillate;
  String mode;
  int target;
  double current;
  int humidity;
  String fan;
  bool swing;
  int position;
  String state;
  bool locked;
  int battery;
  bool playing;
  int volume;
  bool muted;
  String source;
  int track;
  bool armed;
  bool siren;
  bool streaming;
  int snapshots;
  int clips;
  double value;
  String unit;
  String metric;
  List<double> history;
  String description;
  String? lastRun;
  String lastCommand;
  String area;
}

class TypeMeta {
  const TypeMeta(this.label, this.icon, this.family);

  final String label;
  final IconData icon;
  final String family;
}

const Map<String, TypeMeta> deviceTypeMeta = <String, TypeMeta>{
  'light': TypeMeta('Light', Icons.lightbulb_outline, 'Lights'),
  'switch': TypeMeta('Plug', Icons.power_outlined, 'More'),
  'fan': TypeMeta('Fan', Icons.air, 'More'),
  'climate': TypeMeta('Climate', Icons.ac_unit, 'Climate'),
  'cover': TypeMeta('Blinds', Icons.window_outlined, 'Covers'),
  'garage': TypeMeta('Garage', Icons.garage, 'Covers'),
  'lock': TypeMeta('Lock', Icons.lock_outline, 'Security'),
  'media': TypeMeta('Media', Icons.tv, 'Media'),
  'remote': TypeMeta('Remote', Icons.settings_remote, 'Media'),
  'scene': TypeMeta('Scene', Icons.auto_awesome, 'More'),
  'automation': TypeMeta('Automation', Icons.schedule, 'More'),
  'script': TypeMeta('Script', Icons.code, 'More'),
  'vacuum': TypeMeta('Vacuum', Icons.cleaning_services, 'More'),
  'alarm': TypeMeta('Alarm', Icons.shield_outlined, 'Security'),
  'camera': TypeMeta('Camera', Icons.videocam_outlined, 'Security'),
  'gate': TypeMeta('Gate', Icons.fence, 'Security'),
  'sensor': TypeMeta('Sensor', Icons.thermostat, 'More'),
};

const List<String> kFamilies = <String>[
  'All',
  'Lights',
  'Climate',
  'Media',
  'Security',
  'Covers',
  'More',
];

const Map<String, Color> kColours = <String, Color>{
  'white': Color(0xFFFBF6EA),
  'warm': Color(0xFFFFD29A),
  'amber': Color(0xFFFFB45C),
  'red': Color(0xFFDF5B4C),
  'green': Color(0xFF63A06C),
  'blue': Color(0xFF4F8ECF),
  'cool': Color(0xFFE4EEFB),
};

String deviceFamily(Device d) =>
    deviceTypeMeta[d.type]?.family ?? 'More';

IconData deviceIcon(Device d) =>
    deviceTypeMeta[d.type]?.icon ?? Icons.home_outlined;

bool isDeviceOn(Device d) {
  if (d.type == 'cover') return d.position > 0;
  if (d.type == 'lock') return d.locked;
  if (d.type == 'vacuum') return d.state == 'cleaning';
  if (d.type == 'alarm') return d.armed || d.siren;
  if (d.type == 'camera') return d.streaming;
  if (d.type == 'gate' || d.type == 'garage') return d.state == 'open';
  if (const <String>['light', 'switch', 'fan', 'climate', 'media'].contains(d.type)) {
    return d.on;
  }
  return false;
}

String deviceStateLine(Device d) {
  switch (d.type) {
    case 'light':
      return d.on ? 'On - ${d.brightness}%' : 'Off';
    case 'switch':
      return d.on ? 'On - ${d.watts} W' : 'Off';
    case 'fan':
      return d.on ? 'On - speed ${d.speed} - ${d.preset}' : 'Off';
    case 'climate':
      return d.on ? '${capitalize(d.mode)} - target ${d.target}\u00B0' : 'Off';
    case 'cover':
      if (d.position == 0) return 'Closed';
      if (d.position == 100) return 'Open';
      return '${d.position}% open';
    case 'garage':
      return 'Garage - ${d.state}';
    case 'lock':
      return d.locked ? 'Locked' : 'Unlocked';
    case 'media': {
      final volume = d.muted ? 'Muted' : '${d.volume}%';
      return '$volume - ${d.source}';
    }
    case 'vacuum':
      return '${capitalize(d.state)} - ${d.battery}% battery';
    case 'alarm':
      return d.siren
          ? 'Siren sounding'
          : d.armed
              ? 'Armed - ${d.mode}'
              : 'Disarmed';
    case 'camera':
      return d.streaming ? 'Streaming live' : '${d.snapshots} snapshots';
    case 'sensor':
      return '${d.value.toStringAsFixed(1)}${d.unit} ${d.metric.toLowerCase()}';
    case 'gate':
      return 'Gate ${d.state}';
    case 'scene':
    case 'automation':
    case 'script':
      return d.lastRun == null ? 'Tap to run' : 'Ran ${d.lastRun}';
    case 'remote':
      return 'Last: ${d.lastCommand}';
    default:
      return '';
  }
}

String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

List<Device> demoDevices() {
  return <Device>[
    Device(
      id: 'kitchen_light',
      name: 'Kitchen Light',
      room: 'Kitchen',
      type: 'light',
      on: true,
      brightness: 100,
      kelvin: 4000,
      colour: 'warm',
      watts: 9,
    ),
    Device(
      id: 'ceiling_light',
      name: 'Ceiling Light',
      room: 'Kitchen',
      type: 'light',
      brightness: 70,
      kelvin: 3000,
      watts: 12,
    ),
    Device(
      id: 'lounge_light',
      name: 'Lamp',
      room: 'Lounge',
      type: 'light',
      on: true,
      brightness: 45,
      kelvin: 2700,
      watts: 8,
    ),
    Device(
      id: 'bedroom_light_1',
      name: 'Bedroom Light 1',
      room: 'Bedroom 1',
      type: 'light',
      brightness: 80,
      watts: 7,
    ),
    Device(
      id: 'bedroom_light_2',
      name: 'Bedroom Light 2',
      room: 'Bedroom 1',
      type: 'light',
      brightness: 30,
      kelvin: 2700,
      watts: 7,
    ),
    Device(
      id: 'kids_light',
      name: 'Kids Light',
      room: 'Kids Room',
      type: 'light',
      brightness: 60,
      kelvin: 3500,
      watts: 6,
    ),
    Device(
      id: 'office_light',
      name: 'Desk Light',
      room: 'Office',
      type: 'light',
      on: true,
      brightness: 100,
      kelvin: 5000,
      colour: 'cool',
      watts: 10,
    ),
    Device(
      id: 'garden_light',
      name: 'Garden Light',
      room: 'Garden',
      type: 'light',
      brightness: 100,
      watts: 15,
    ),
    Device(
      id: 'tv_plug',
      name: 'TV Plug',
      room: 'Lounge',
      type: 'switch',
      on: true,
      watts: 120,
    ),
    Device(
      id: 'coffee_plug',
      name: 'Coffee Plug',
      room: 'Kitchen',
      type: 'switch',
      watts: 900,
    ),
    Device(
      id: 'heater_plug',
      name: 'Heater Plug',
      room: 'Office',
      type: 'switch',
      watts: 1500,
    ),
    Device(
      id: 'bedroom_fan',
      name: 'Bedroom Fan',
      room: 'Bedroom 1',
      type: 'fan',
      speed: 2,
      preset: 'normal',
      oscillate: true,
      watts: 45,
    ),
    Device(
      id: 'lounge_fan',
      name: 'Lounge Fan',
      room: 'Lounge',
      type: 'fan',
      on: true,
      speed: 3,
      preset: 'auto',
      watts: 50,
    ),
    Device(
      id: 'ac_entrance',
      name: 'Air Conditioner',
      room: 'Entrance',
      type: 'climate',
      on: true,
      mode: 'cool',
      target: 23,
      current: 24.3,
      humidity: 59,
      watts: 1100,
    ),
    Device(
      id: 'heater_lounge',
      name: 'Lounge Heater',
      room: 'Lounge',
      type: 'climate',
      mode: 'heat',
      target: 21,
      current: 19.8,
      humidity: 44,
      fan: 'low',
      watts: 1800,
    ),
    Device(
      id: 'lounge_blinds',
      name: 'Lounge Blinds',
      room: 'Lounge',
      type: 'cover',
      position: 100,
      state: 'open',
    ),
    Device(
      id: 'bedroom_curtains',
      name: 'Bedroom Curtains',
      room: 'Bedroom 1',
      type: 'cover',
      position: 0,
      state: 'closed',
    ),
    Device(
      id: 'office_blinds',
      name: 'Office Blinds',
      room: 'Office',
      type: 'cover',
      position: 60,
      state: 'open',
    ),
    Device(
      id: 'garage_door',
      name: 'Garage Door',
      room: 'Garage',
      type: 'garage',
      state: 'closed',
    ),
    Device(
      id: 'front_door',
      name: 'Front Door',
      room: 'Entrance',
      type: 'lock',
      battery: 88,
    ),
    Device(
      id: 'back_door',
      name: 'Back Door',
      room: 'Garden',
      type: 'lock',
      battery: 71,
    ),
    Device(
      id: 'smart_tv',
      name: 'Smart TV',
      room: 'Lounge',
      type: 'media',
      on: true,
      playing: true,
      volume: 20,
      source: 'HDMI 1',
      track: 3,
      watts: 110,
    ),
    Device(
      id: 'bedroom_speaker',
      name: 'Speaker',
      room: 'Bedroom 1',
      type: 'media',
      on: true,
      volume: 35,
      source: 'Bluetooth',
      watts: 12,
    ),
    Device(
      id: 'kitchen_speaker',
      name: 'Kitchen Speaker',
      room: 'Kitchen',
      type: 'media',
      on: true,
      volume: 25,
      muted: true,
      source: 'Spotify',
      track: 2,
      watts: 10,
    ),
    Device(
      id: 'tv_remote',
      name: 'TV Remote',
      room: 'Lounge',
      type: 'remote',
    ),
    Device(
      id: 'scene_movie',
      name: 'Movie Night',
      room: 'Lounge',
      type: 'scene',
      description: 'Lights to 20%, blinds closed, TV on',
    ),
    Device(
      id: 'scene_away',
      name: 'Away Mode',
      room: 'Entrance',
      type: 'scene',
      description: 'Every light off, doors locked, alarm armed',
    ),
    Device(
      id: 'automation_morning',
      name: 'Morning Routine',
      room: 'Kitchen',
      type: 'automation',
      description: 'Blinds open, kitchen lights warm, coffee on',
    ),
    Device(
      id: 'script_welcome',
      name: 'Welcome Home',
      room: 'Entrance',
      type: 'script',
      description: 'Hallway light on, gate closed, heater warm',
    ),
    Device(
      id: 'vacuum',
      name: 'Robot Vacuum',
      room: 'Lounge',
      type: 'vacuum',
      state: 'docked',
      battery: 64,
      area: 'Lounge',
    ),
    Device(
      id: 'alarm',
      name: 'Alarm',
      room: 'Entrance',
      type: 'alarm',
      mode: 'home',
    ),
    Device(
      id: 'camera_drive',
      name: 'Driveway Camera',
      room: 'Garden',
      type: 'camera',
      snapshots: 12,
      clips: 3,
      watts: 6,
    ),
    Device(
      id: 'gate',
      name: 'Main Gate',
      room: 'Garden',
      type: 'gate',
      state: 'closed',
    ),
    Device(
      id: 'sensor_entrance',
      name: 'Entrance Sensor',
      room: 'Entrance',
      type: 'sensor',
      metric: 'Temperature',
      value: 24.3,
      unit: '\u00B0C',
      history: <double>[22.1, 23.0, 23.4, 23.9, 24.1, 24.3],
    ),
    Device(
      id: 'sensor_power',
      name: 'Power Meter',
      room: 'Garage',
      type: 'sensor',
      metric: 'Power',
      value: 412,
      unit: 'W',
      history: <double>[380, 402, 396, 420, 408, 412],
    ),
  ];
}
