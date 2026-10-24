import 'package:flutter/material.dart';

import '../data/devices.dart';
import '../state/home_controller.dart';
import '../widgets/controls.dart';

const List<List<Color>> _tones = <List<Color>>[
  <Color>[Color(0xFF4A5566), Color(0xFF232A36)],
  <Color>[Color(0xFF5B5A4C), Color(0xFF2B2A22)],
  <Color>[Color(0xFF47565B), Color(0xFF1F2A2D)],
  <Color>[Color(0xFF5C4A42), Color(0xFF2B2320)],
];

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final rooms = c.roomNames;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
      children: <Widget>[
        Text('${rooms.length} rooms',
            style: const TextStyle(fontSize: 12, color: kMuted)),
        const SizedBox(height: 2),
        const Text(
          'Rooms',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            color: kInk,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List<Widget>.generate(rooms.length, (index) {
                final room = rooms[index];
                final devices = c.devicesIn(room);
                final on = devices.where(isDeviceOn).length;
                final lead = devices.firstWhere(
                  (d) => d.type == 'light',
                  orElse: () => devices.first,
                );
                return SizedBox(
                  width: width,
                  height: 168,
                  child: _RoomTile(
                    room: room,
                    count: devices.length,
                    onCount: on,
                    icon: deviceIcon(lead),
                    tone: _tones[index % _tones.length],
                    onTap: () => c.go('room', room: room),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.room,
    required this.count,
    required this.onCount,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  final String room;
  final int count;
  final int onCount;
  final IconData icon;
  final List<Color> tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: tone,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    room,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$count devices - $onCount on',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0x9EFFFFFF)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomScreen extends StatelessWidget {
  const RoomScreen({
    super.key,
    required this.controller,
    required this.room,
  });

  final HomeController controller;
  final String room;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final devices = c.devicesIn(room);
    final lead = devices.isEmpty
        ? null
        : devices.firstWhere((d) => d.type == 'light',
            orElse: () => devices.first);
    final on = devices.where(isDeviceOn).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
      children: <Widget>[
        PageHeader(title: room, onBack: c.back),
        Container(
          height: 150,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF495566), Color(0xFF1E2633)],
            ),
          ),
          child: Stack(
            children: <Widget>[
              if (lead != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    deviceIcon(lead),
                    size: 84,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
              Positioned(
                left: 0,
                bottom: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      room,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${devices.length} devices - $on on',
                      style: const TextStyle(
                          fontSize: 11.5, color: Color(0xA8FFFFFF)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(top: 14),
            itemCount: devices.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final d = devices[index];
              return _MiniDeviceCard(
                device: d,
                onTap: () => c.go('device', id: d.id),
              );
            },
          ),
        ),
        SectionHead(title: 'All devices', trailing: '${devices.length}'),
        ...devices.map((d) => _DeviceRow(controller: c, device: d)),
      ],
    );
  }
}

class _MiniDeviceCard extends StatelessWidget {
  const _MiniDeviceCard({required this.device, required this.onTap});

  final Device device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 124,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: kSoftShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DeviceGlyph(device: device, size: 30),
            const SizedBox(height: 8),
            Text(
              device.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: kInk,
              ),
            ),
            Text(
              deviceStateLine(device),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, color: kMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.controller, required this.device});

  final HomeController controller;
  final Device device;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final d = device;
    final toggleable =
        const <String>['light', 'switch', 'fan', 'climate', 'media']
            .contains(d.type);

    return GestureDetector(
      onTap: () => c.go('device', id: d.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: kSoftShadow,
        ),
        child: Row(
          children: <Widget>[
            DeviceGlyph(device: d, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    d.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kInk,
                    ),
                  ),
                  Text(
                    deviceStateLine(d),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: kMuted),
                  ),
                ],
              ),
            ),
            if (toggleable)
              HomeSwitch(value: isDeviceOn(d), onTap: () => c.toggle(d))
            else
              const Icon(Icons.chevron_right,
                  size: 18, color: Color(0xFFB9BDC4)),
          ],
        ),
      ),
    );
  }
}
