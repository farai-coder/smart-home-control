import 'package:flutter/material.dart';

import '../data/devices.dart';
import '../state/home_controller.dart';
import 'controls.dart';

List<Widget> buildDevicePanels({
  required HomeController c,
  required Device d,
  required void Function(String) toast,
}) {
  switch (d.type) {
    case 'light':
      return _lightPanels(c, d);
    case 'switch':
      return _switchPanels(c, d);
    case 'fan':
      return _fanPanels(c, d);
    case 'climate':
      return _climatePanels(c, d);
    case 'cover':
      return _coverPanels(c, d);
    case 'garage':
      return _garagePanels(c, d);
    case 'lock':
      return _lockPanels(c, d);
    case 'media':
      return _mediaPanels(c, d);
    case 'vacuum':
      return _vacuumPanels(c, d, toast);
    case 'alarm':
      return _alarmPanels(c, d);
    case 'camera':
      return _cameraPanels(c, d, toast);
    case 'sensor':
      return _sensorPanels(c, d);
    case 'gate':
      return <Widget>[
        _gateCard(c, d),
        _GatePlateCard(controller: c),
      ];
    case 'scene':
    case 'automation':
    case 'script':
      return _scenePanels(c, d);
    case 'remote':
      return _remotePanels(c, d, toast);
    default:
      return <Widget>[];
  }
}

String _colourLabel(String name) => capitalize(name);

List<Widget> _lightPanels(HomeController c, Device d) {
  return <Widget>[
    AppCard(
      child: Column(
        children: <Widget>[
          RingValue(
            value: d.brightness / 100,
            top: '${d.brightness}%',
            bottom: 'Brightness',
          ),
          const SizedBox(height: 6),
          LabeledSlider(
            value: d.brightness.toDouble(),
            min: 1,
            max: 100,
            onChanged: (value) =>
                c.mutate(() => d.brightness = value.round()),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <int>[25, 50, 75, 100].map((value) {
              return PillChip(
                label: '$value%',
                active: d.brightness == value,
                compact: true,
                onTap: () => c.mutate(() => d.brightness = value,
                    logText: '${d.name} brightness -> $value%',
                    deviceId: d.id),
              );
            }).toList(),
          ),
        ],
      ),
    ),
    const SizedBox(height: 12),
    AppCard(
      child: LabeledSlider(
        label: 'Colour temperature',
        valueLabel: '${d.kelvin} K',
        value: d.kelvin.toDouble(),
        min: 2700,
        max: 6500,
        divisions: 38,
        lowLabel: 'Warm',
        highLabel: 'Cool',
        onChanged: (value) => c.mutate(() => d.kelvin = value.round()),
      ),
    ),
    const SizedBox(height: 12),
    AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('Colour',
                  style: TextStyle(fontSize: 12.5, color: kInkSoft)),
              Text(
                _colourLabel(d.colour),
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: kInk),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kColours.entries.map((entry) {
              final selected = d.colour == entry.key;
              return GestureDetector(
                onTap: () => c.mutate(
                  () {
                    d.colour = entry.key;
                    d.on = true;
                  },
                  logText: '${d.name} -> ${entry.key}',
                  deviceId: d.id,
                ),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? kAccent : const Color(0xFFEEF0F2),
                      width: selected ? 2 : 2,
                    ),
                    boxShadow: selected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: kAccentSoft,
                              blurRadius: 0,
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _switchPanels(HomeController c, Device d) {
  return <Widget>[
    AppCard(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                '${d.on ? d.watts : 0}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.6,
                  color: kInk,
                ),
              ),
              const SizedBox(width: 4),
              const Text('W',
                  style: TextStyle(fontSize: 15, color: kMuted)),
            ],
          ),
          Text(
            d.on ? 'Drawing power now' : 'Not drawing power',
            style: const TextStyle(fontSize: 12, color: kMuted),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: <Widget>[
              _staticPill(Icons.schedule, 'Timer 30m'),
              _staticPill(
                Icons.insights,
                '${((d.watts / 1000) * 24).toStringAsFixed(1)} kWh/day',
              ),
            ],
          ),
        ],
      ),
    ),
  ];
}

Widget _staticPill(IconData icon, String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF2F3F5),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: kInkSoft),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(fontSize: 11.5, color: kInkSoft)),
      ],
    ),
  );
}

List<Widget> _fanPanels(HomeController c, Device d) {
  return <Widget>[
    AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('Speed',
                  style: TextStyle(fontSize: 12.5, color: kInkSoft)),
              Text('${d.speed} / 5',
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: kInk)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List<Widget>.generate(5, (index) {
              final speed = index + 1;
              final active = d.speed == speed;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 4 ? 0 : 6),
                  child: GestureDetector(
                    onTap: () => c.mutate(
                      () {
                        d.speed = speed;
                        d.on = true;
                      },
                      logText: '${d.name} speed -> $speed',
                      deviceId: d.id,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: active ? kAccent : const Color(0xFFF2F3F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$speed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : kInkSoft,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 18),
            child: Text('Preset',
                style: TextStyle(fontSize: 12.5, color: kInkSoft)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <String>['normal', 'sleep', 'auto', 'boost', 'eco']
                .map((preset) {
              return PillChip(
                label: capitalize(preset),
                active: d.preset == preset,
                compact: true,
                onTap: () => c.mutate(
                  () {
                    d.preset = preset;
                    d.on = true;
                  },
                  logText: '${d.name} preset -> $preset',
                  deviceId: d.id,
                ),
              );
            }).toList(),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Divider(height: 1, color: kLine),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: <Widget>[
                Icon(Icons.air, size: 17, color: kInkSoft),
                const SizedBox(width: 8),
                const Text('Oscillate',
                    style: TextStyle(fontSize: 12.5, color: kInkSoft)),
                const Spacer(),
                HomeSwitch(
                  value: d.oscillate,
                  onTap: () => c.mutate(() => d.oscillate = !d.oscillate),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _climatePanels(HomeController c, Device d) {
  return <Widget>[
    AppCard(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _round(
                Icons.remove,
                () => c.mutate(() {
                  d.target = (d.target - 1).clamp(16, 30).toInt();
                  d.on = true;
                }),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${d.target}',
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2.5,
                            height: 1,
                            color: kInk,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            '\u00B0',
                            style: TextStyle(
                              fontSize: 22,
                              color: kMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${capitalize(d.mode)} ${d.on ? 'on' : 'off'}',
                      style: const TextStyle(fontSize: 10.5, color: kMuted),
                    ),
                  ],
                ),
              ),
              _round(
                Icons.add,
                () => c.mutate(() {
                  d.target = (d.target + 1).clamp(16, 30).toInt();
                  d.on = true;
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: <Widget>[
              ...<String>['cool', 'heat', 'auto'].map((mode) {
                return PillChip(
                  label: capitalize(mode),
                  active: d.mode == mode,
                  onTap: () => c.mutate(
                    () {
                      d.mode = mode;
                      d.on = true;
                    },
                    logText: '${d.name} mode -> $mode',
                    deviceId: d.id,
                  ),
                );
              }),
              PillChip(
                label: 'Off',
                active: !d.on,
                onTap: () => c.mutate(() => d.on = false,
                    logText: '${d.name} -> off', deviceId: d.id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: <Widget>[
              ...<String>['auto', 'low', 'high'].map((fan) {
                return PillChip(
                  label: 'Fan $fan',
                  active: d.fan == fan,
                  compact: true,
                  onTap: () => c.mutate(() => d.fan = fan),
                );
              }),
              PillChip(
                label: 'Swing',
                active: d.swing,
                compact: true,
                onTap: () => c.mutate(() => d.swing = !d.swing),
              ),
            ],
          ),
          StatRow(
            items: <StatItem>[
              StatItem('Room', '${d.current}\u00B0'),
              StatItem('Humidity', '${d.humidity}%'),
              StatItem('Power', d.on ? '${d.watts} W' : '0 W'),
            ],
          ),
        ],
      ),
    ),
  ];
}

Widget _round(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F3F5),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: kInk),
    ),
  );
}

List<Widget> _coverPanels(HomeController c, Device d) {
  return <Widget>[
    AppCard(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                '${d.position}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.6,
                  color: kInk,
                ),
              ),
              const SizedBox(width: 3),
              const Text('%',
                  style: TextStyle(fontSize: 15, color: kMuted)),
            ],
          ),
          Text(
            capitalize(d.state),
            style: const TextStyle(fontSize: 12, color: kMuted),
          ),
          const SizedBox(height: 4),
          LabeledSlider(
            value: d.position.toDouble(),
            min: 0,
            max: 100,
            onChanged: (value) => c.mutate(() {
              d.position = value.round();
              d.state = d.position == 0 ? 'closed' : 'open';
            }),
          ),
          ActionRow(
            children: <Widget>[
              SoftButton(
                label: 'Open',
                icon: Icons.keyboard_arrow_up,
                expand: true,
                onTap: () => c.mutate(
                  () {
                    d.position = 100;
                    d.state = 'open';
                  },
                  logText: '${d.name} -> open',
                  deviceId: d.id,
                ),
              ),
              SoftButton(
                label: 'Stop',
                icon: Icons.stop,
                expand: true,
                onTap: () => c.mutate(
                  () => d.state = 'stopped',
                  logText: '${d.name} -> stopped',
                  deviceId: d.id,
                ),
              ),
              SoftButton(
                label: 'Close',
                icon: Icons.keyboard_arrow_down,
                expand: true,
                onTap: () => c.mutate(
                  () {
                    d.position = 0;
                    d.state = 'closed';
                  },
                  logText: '${d.name} -> closed',
                  deviceId: d.id,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _garagePanels(HomeController c, Device d) {
  return <Widget>[
    AppCard(
      child: Column(
        children: <Widget>[
          BigGlyph(icon: Icons.garage, active: d.state == 'open'),
          StatusPill(text: capitalize(d.state)),
          ActionRow(
            children: <Widget>[
              SoftButton(
                label: 'Open',
                icon: Icons.keyboard_arrow_up,
                expand: true,
                onTap: () => c.mutate(() => d.state = 'open',
                    logText: 'Garage Door -> open', deviceId: d.id),
              ),
              SoftButton(
                label: 'Stop',
                icon: Icons.stop,
                expand: true,
                onTap: () => c.mutate(() => d.state = 'stopped',
                    logText: 'Garage Door -> stopped', deviceId: d.id),
              ),
              SoftButton(
                label: 'Close',
                icon: Icons.keyboard_arrow_down,
                expand: true,
                onTap: () => c.mutate(() => d.state = 'closed',
                    logText: 'Garage Door -> closed', deviceId: d.id),
              ),
            ],
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _lockPanels(HomeController c, Device d) {
  return <Widget>[
    AppCard(
      child: Column(
        children: <Widget>[
          BigGlyph(
            icon: d.locked ? Icons.lock_outline : Icons.lock_open,
            active: !d.locked,
          ),
          StatusPill(text: d.locked ? 'Locked' : 'Unlocked'),
          ActionRow(
            children: <Widget>[
              SoftButton(
                label: 'Lock',
                icon: Icons.lock_outline,
                expand: true,
                onTap: () => c.mutate(() => d.locked = true,
                    logText: '${d.name} -> locked', deviceId: d.id),
              ),
              SoftButton(
                label: 'Unlock',
                icon: Icons.lock_open,
                expand: true,
                onTap: () => c.mutate(() => d.locked = false,
                    logText: '${d.name} -> unlocked', deviceId: d.id),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Battery ${d.battery}%',
              style: const TextStyle(fontSize: 12, color: kMuted),
            ),
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _mediaPanels(HomeController c, Device d) {
  return <Widget>[
    AppCard(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFF2A364D), Color(0xFF151D2C)],
                  ),
                ),
                child: const Icon(Icons.tv, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      d.playing ? 'Now playing' : 'Paused',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${d.source} - Track ${d.track}',
                      style: const TextStyle(fontSize: 11.5, color: kMuted),
                    ),
                  ],
                ),
              ),
              _Equalizer(live: d.playing && !d.muted),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _transport(
                Icons.skip_previous,
                () => c.mutate(
                  () {
                    d.track = d.track > 1 ? d.track - 1 : 1;
                    d.playing = true;
                  },
                  logText: '${d.name} -> previous track',
                  deviceId: d.id,
                ),
              ),
              const SizedBox(width: 22),
              GestureDetector(
                onTap: () => c.mutate(
                  () => d.playing = !d.playing,
                  logText: d.playing ? '${d.name} -> playing' : '${d.name} -> paused',
                  deviceId: d.id,
                ),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: kAccent,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0x52F2723A),
                        blurRadius: 22,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    d.playing ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 22),
              _transport(
                Icons.skip_next,
                () => c.mutate(
                  () {
                    d.track += 1;
                    d.playing = true;
                  },
                  logText: '${d.name} -> next track',
                  deviceId: d.id,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LabeledSlider(
            label: 'Volume',
            valueLabel: d.muted ? 'Muted' : '${d.volume}%',
            value: d.volume.toDouble(),
            min: 0,
            max: 100,
            onChanged: (value) => c.mutate(() {
              d.volume = value.round();
              d.muted = false;
            }),
          ),
          ActionRow(
            children: <Widget>[
              SoftButton(
                label: d.muted ? 'Unmute' : 'Mute',
                icon: d.muted ? Icons.volume_up : Icons.volume_off,
                expand: true,
                onTap: () => c.mutate(
                  () => d.muted = !d.muted,
                  logText: d.muted ? '${d.name} -> unmuted' : '${d.name} -> muted',
                  deviceId: d.id,
                ),
              ),
              SoftButton(
                label: 'Stop',
                icon: Icons.stop,
                expand: true,
                onTap: () => c.mutate(
                  () => d.playing = false,
                  logText: '${d.name} -> stopped',
                  deviceId: d.id,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                <String>['HDMI 1', 'HDMI 2', 'Spotify', 'Bluetooth', 'Radio']
                    .map((source) {
              return PillChip(
                label: source,
                active: d.source == source,
                compact: true,
                onTap: () => c.mutate(
                  () => d.source = source,
                  logText: '${d.name} source -> $source',
                  deviceId: d.id,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  ];
}

Widget _transport(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F3F5),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 22, color: kInk),
    ),
  );
}

class _Equalizer extends StatelessWidget {
  const _Equalizer({required this.live});

  final bool live;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <int>[10, 16, 7].map((height) {
        return Container(
          margin: const EdgeInsets.only(left: 2),
          width: 3,
          height: height.toDouble(),
          decoration: BoxDecoration(
            color: live ? kAccent : const Color(0xFFD3D6DB),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }
}

List<Widget> _vacuumPanels(
  HomeController c,
  Device d,
  void Function(String) toast,
) {
  const labels = <String, String>{
    'docked': 'On the dock',
    'cleaning': 'Cleaning',
    'paused': 'Paused',
    'idle': 'Idle',
  };
  return <Widget>[
    AppCard(
      child: Column(
        children: <Widget>[
          RingValue(
            value: d.battery / 100,
            top: '${d.battery}%',
            bottom: 'Battery',
          ),
          StatusPill(
            text: d.state == 'cleaning'
                ? 'Cleaning ${d.area}'
                : labels[d.state] ?? capitalize(d.state),
          ),
          ActionRow(
            children: <Widget>[
              SoftButton(
                label: 'Start',
                icon: Icons.play_arrow,
                expand: true,
                onTap: () => c.mutate(() => d.state = 'cleaning',
                    logText: 'Robot Vacuum -> cleaning', deviceId: d.id),
              ),
              SoftButton(
                label: 'Pause',
                icon: Icons.pause,
                expand: true,
                onTap: () => c.mutate(() => d.state = 'paused',
                    logText: 'Robot Vacuum -> paused', deviceId: d.id),
              ),
              SoftButton(
                label: 'Dock',
                icon: Icons.home_outlined,
                expand: true,
                onTap: () => c.mutate(() => d.state = 'docked',
                    logText: 'Robot Vacuum -> docked', deviceId: d.id),
              ),
            ],
          ),
          ActionRow(
            children: <Widget>[
              SoftButton(
                label: 'Stop',
                icon: Icons.stop,
                expand: true,
                onTap: () => c.mutate(() => d.state = 'idle',
                    logText: 'Robot Vacuum -> stopped', deviceId: d.id),
              ),
              SoftButton(
                label: 'Locate',
                icon: Icons.location_searching,
                expand: true,
                onTap: () {
                  toast('Vacuum is in the ${d.area} and is beeping');
                  c.log('Located Robot Vacuum in the ${d.area}',
                      deviceId: d.id);
                },
              ),
            ],
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _alarmPanels(HomeController c, Device d) {
  return <Widget>[
    AppCard(
      child: Column(
        children: <Widget>[
          BigGlyph(
            icon: Icons.shield_outlined,
            active: d.armed || d.siren,
          ),
          StatusPill(
            text: d.siren
                ? 'Siren sounding'
                : d.armed
                    ? 'Armed - ${d.mode}'
                    : 'Disarmed',
          ),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: <String>['home', 'away', 'night'].map((mode) {
              return PillChip(
                label: capitalize(mode),
                active: d.mode == mode,
                compact: true,
                onTap: () => c.mutate(() => d.mode = mode),
              );
            }).toList(),
          ),
          ActionRow(
            children: <Widget>[
              SoftButton(
                label: 'Arm',
                icon: Icons.shield_outlined,
                expand: true,
                onTap: () => c.mutate(() => d.armed = true,
                    logText: 'Alarm -> armed (${d.mode})', deviceId: d.id),
              ),
              SoftButton(
                label: 'Disarm',
                icon: Icons.lock_open,
                expand: true,
                onTap: () => c.mutate(() => d.armed = false,
                    logText: 'Alarm -> disarmed', deviceId: d.id),
              ),
            ],
          ),
          ActionRow(
            children: <Widget>[
              SoftButton(
                label: d.siren ? 'Stop siren' : 'Trigger siren',
                icon: Icons.notifications_active_outlined,
                dark: true,
                expand: true,
                onTap: () => c.mutate(
                  () => d.siren = !d.siren,
                  logText: d.siren ? 'Siren -> stopped' : 'Siren -> sounding',
                  deviceId: d.id,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _cameraPanels(
  HomeController c,
  Device d,
  void Function(String) toast,
) {
  return <Widget>[
    AppCard(
      child: Column(
        children: <Widget>[
          Container(
            height: 158,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF3B4657), Color(0xFF1B2230)],
              ),
            ),
            child: Stack(
              children: <Widget>[
                const Center(
                  child: Icon(Icons.videocam_outlined,
                      size: 42, color: Color(0x88FFFFFF)),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: d.streaming ? kAccent : const Color(0x24FFFFFF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      d.streaming ? 'LIVE' : 'OFFLINE',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Text(
                    d.room,
                    style: const TextStyle(
                        fontSize: 10.5, color: Color(0xA0FFFFFF)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ActionRow(
            children: <Widget>[
              SoftButton(
                label: 'Stream',
                icon: Icons.play_arrow,
                expand: true,
                onTap: () => c.mutate(() => d.streaming = true,
                    logText: '${d.name} -> live stream', deviceId: d.id),
              ),
              SoftButton(
                label: 'Snapshot',
                icon: Icons.camera_alt_outlined,
                expand: true,
                onTap: () {
                  c.mutate(() => d.snapshots += 1,
                      logText: '${d.name} snapshot saved (${d.snapshots})',
                      deviceId: d.id);
                  toast('Snapshot saved');
                },
              ),
            ],
          ),
          ActionRow(
            children: <Widget>[
              SoftButton(
                label: 'Record clip',
                icon: Icons.videocam_outlined,
                expand: true,
                onTap: () {
                  c.mutate(() => d.clips += 1,
                      logText: '${d.name} clip recorded (${d.clips})',
                      deviceId: d.id);
                  toast('Clip recorded');
                },
              ),
            ],
          ),
          StatRow(
            items: <StatItem>[
              StatItem('Snapshots', '${d.snapshots}'),
              StatItem('Clips', '${d.clips}'),
            ],
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _sensorPanels(HomeController c, Device d) {
  final value = d.value % 1 == 0
      ? d.value.toInt().toString()
      : d.value.toStringAsFixed(1);
  return <Widget>[
    AppCard(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                value,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.6,
                  color: kInk,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                d.unit,
                style: const TextStyle(fontSize: 15, color: kMuted),
              ),
            ],
          ),
          Text(
            '${d.metric} now',
            style: const TextStyle(fontSize: 12, color: kMuted),
          ),
          const SizedBox(height: 12),
          Sparkline(values: d.history),
          StatRow(
            items: <StatItem>[
              StatItem('Low', '${d.history.reduce((a, b) => a < b ? a : b)}${d.unit}'),
              StatItem(
                  'High', '${d.history.reduce((a, b) => a > b ? a : b)}${d.unit}'),
            ],
          ),
          const SizedBox(height: 12),
          SoftButton(
            label: 'Read value',
            icon: Icons.sensors,
            expand: true,
            onTap: () => c.mutate(
              () {},
              logText: '${d.name}: ${d.metric} $value${d.unit}',
              deviceId: d.id,
            ),
          ),
        ],
      ),
    ),
  ];
}

Widget _gateCard(HomeController c, Device d) {
  return AppCard(
    child: Column(
      children: <Widget>[
        BigGlyph(icon: Icons.fence, active: d.state == 'open'),
        StatusPill(text: 'Gate ${capitalize(d.state)}'),
        ActionRow(
          children: <Widget>[
            SoftButton(
              label: 'Open',
              icon: Icons.keyboard_arrow_up,
              expand: true,
              onTap: () => c.mutate(() => d.state = 'open',
                  logText: 'Main Gate -> open', deviceId: d.id),
            ),
            SoftButton(
              label: 'Stop',
              icon: Icons.stop,
              expand: true,
              onTap: () => c.mutate(() => d.state = 'stopped',
                  logText: 'Main Gate -> stopped', deviceId: d.id),
            ),
            SoftButton(
              label: 'Close',
              icon: Icons.keyboard_arrow_down,
              expand: true,
              onTap: () => c.mutate(() => d.state = 'closed',
                  logText: 'Main Gate -> closed', deviceId: d.id),
            ),
          ],
        ),
      ],
    ),
  );
}

class _GatePlateCard extends StatefulWidget {
  const _GatePlateCard({required this.controller});

  final HomeController controller;

  @override
  State<_GatePlateCard> createState() => _GatePlateCardState();
}

class _GatePlateCardState extends State<_GatePlateCard> {
  final TextEditingController _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  String? _plate() {
    final match = RegExp(r'([A-Za-z]{2,4})[ -]?(\d{2,4})')
        .firstMatch(_field.text.toUpperCase());
    if (match == null) return null;
    return '${match.group(1)} ${match.group(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('Vehicle plate',
                  style: TextStyle(fontSize: 12.5, color: kInkSoft)),
              Text(
                '${c.plates.length} whitelisted',
                style: const TextStyle(fontSize: 12.5, color: kMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _field,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'ABC 1234',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    filled: true,
                    fillColor: const Color(0xFFFAFBFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kLine),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kLine),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kAccent),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 12.5,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final plate = _plate();
                  if (plate == null) {
                    c.setPlateMessage('Type a plate first, like ABC 1234',
                        ok: false);
                    return;
                  }
                  c.checkPlate(plate);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: kInk,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Check',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final plate = _plate();
                  if (plate == null) {
                    c.setPlateMessage('Type a plate first, like ABC 1234',
                        ok: false);
                    return;
                  }
                  c.addPlate(plate);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kInk,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (c.plateMessage != null) ...<Widget>[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: c.plateMessageOk ? kAccentSoft : const Color(0xFFF2F3F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    c.plateMessageOk ? Icons.check : Icons.close,
                    size: 15,
                    color: c.plateMessageOk ? kAccentDeep : kMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.plateMessage!,
                      style: const TextStyle(fontSize: 11.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...c.plates.map((plate) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFBFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    plate,
                    style: const TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.5,
                      color: kInk,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => c.removePlate(plate),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: kMuted,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

List<Widget> _scenePanels(HomeController c, Device d) {
  return <Widget>[
    AppCard(
      child: Column(
        children: <Widget>[
          BigGlyph(icon: deviceIcon(d), active: true),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              d.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: kInkSoft,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SoftButton(
            label: 'Run ${d.name}',
            icon: Icons.auto_awesome,
            dark: true,
            expand: true,
            onTap: () => c.run(d.name.toLowerCase()),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              d.lastRun == null ? 'Not run yet' : 'Last run ${d.lastRun}',
              style: const TextStyle(fontSize: 12, color: kMuted),
            ),
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _remotePanels(
  HomeController c,
  Device d,
  void Function(String) toast,
) {
  return <Widget>[
    AppCard(
      child: Column(
        children: <Widget>[
          Text(
            'Last command: ${d.lastCommand}',
            style: const TextStyle(fontSize: 12, color: kMuted),
          ),
          const SizedBox(height: 8),
          ActionRow(
            children: <Widget>[
              SoftButton(
                label: 'Power',
                expand: true,
                onTap: () => _sendRemote(c, d, 'power', toast),
              ),
              SoftButton(
                label: 'Volume +',
                expand: true,
                onTap: () => _sendRemote(c, d, 'volume_up', toast),
              ),
              SoftButton(
                label: 'Channel +',
                expand: true,
                onTap: () => _sendRemote(c, d, 'channel_up', toast),
              ),
            ],
          ),
        ],
      ),
    ),
  ];
}

void _sendRemote(
  HomeController c,
  Device d,
  String command,
  void Function(String) toast,
) {
  c.mutate(
    () => d.lastCommand = command,
    logText: 'Sent $command over IR',
    deviceId: d.id,
  );
  toast('Sent $command over IR');
}
