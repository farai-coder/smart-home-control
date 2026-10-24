import 'package:flutter/material.dart';

import '../data/devices.dart';
import '../state/home_controller.dart';
import '../widgets/controls.dart';

class AddDeviceScreen extends StatelessWidget {
  const AddDeviceScreen({
    super.key,
    required this.controller,
    required this.onToast,
  });

  final HomeController controller;
  final void Function(String) onToast;

  static const List<MapEntry<String, IconData>> found =
      <MapEntry<String, IconData>>[
    MapEntry<String, IconData>('Smart TV OLED', Icons.tv),
    MapEntry<String, IconData>('WiFi Extender', Icons.wifi),
    MapEntry<String, IconData>('Bluetooth Speaker', Icons.speaker),
  ];

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: <Widget>[
        Row(
          children: <Widget>[
            RoundIconButton(
              icon: Icons.chevron_left,
              dark: true,
              onTap: () => c.tab('dashboard'),
            ),
            const Expanded(
              child: Text(
                'Add device',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            RoundIconButton(
              icon: Icons.more_horiz,
              dark: true,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          'Add new device',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Searching for Zigbee and WiFi devices...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: Color(0x99FFFFFF)),
        ),
        SizedBox(
          height: 360,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _ring(130),
              _ring(230),
              _ring(330),
              GestureDetector(
                onTap: () => onToast('Scanning for devices...'),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: kAccent,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: kAccent.withValues(alpha: 0.16),
                        blurRadius: 0,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.bluetooth, color: Colors.white),
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.72),
                child: _FoundChip(
                  label: found[0].key,
                  icon: found[0].value,
                  added: c.added.contains(found[0].key),
                  onTap: () {
                    c.addFound(found[0].key);
                    onToast('${found[0].key} added to your home');
                  },
                ),
              ),
              Align(
                alignment: const Alignment(0.82, 0.1),
                child: _FoundChip(
                  label: found[1].key,
                  icon: found[1].value,
                  added: c.added.contains(found[1].key),
                  onTap: () {
                    c.addFound(found[1].key);
                    onToast('${found[1].key} added to your home');
                  },
                ),
              ),
              Align(
                alignment: const Alignment(0, 0.82),
                child: _FoundChip(
                  label: found[2].key,
                  icon: found[2].value,
                  added: c.added.contains(found[2].key),
                  onTap: () {
                    c.addFound(found[2].key);
                    onToast('${found[2].key} added to your home');
                  },
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Tap a device to add it to your home',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0x6BFFFFFF)),
        ),
      ],
    );
  }

  Widget _ring(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
    );
  }
}

class _FoundChip extends StatelessWidget {
  const _FoundChip({
    required this.label,
    required this.icon,
    required this.added,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool added;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 118,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: added
                    ? kAccent
                    : Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: added
                      ? kAccent
                      : Colors.white.withValues(alpha: 0.16),
                ),
              ),
              child: Icon(icon, size: 19, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              added ? 'Added' : label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                color: Color(0xB8FFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
