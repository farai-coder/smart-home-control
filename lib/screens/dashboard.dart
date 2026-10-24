import 'package:flutter/material.dart';

import '../data/devices.dart';
import '../state/home_controller.dart';
import '../widgets/controls.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.controller,
    required this.onToast,
  });

  final HomeController controller;
  final void Function(String) onToast;

  static const List<String> favourites = <String>[
    'ac_entrance',
    'lounge_light',
    'smart_tv',
    'bedroom_speaker',
    'vacuum',
    'front_door',
    'gate',
    'bedroom_fan',
  ];

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final List<Device> list = c.filter == 'All'
        ? favourites.map(c.byId).whereType<Device>().toList()
        : c.devices.where((d) => deviceFamily(d) == c.filter).toList();

    list.sort((a, b) {
      final aWide = a.type == 'climate' ? 1 : 0;
      final bWide = b.type == 'climate' ? 1 : 0;
      return bWide - aWide;
    });

    final scenes = c.devices
        .where((d) => const <String>['scene', 'automation', 'script']
            .contains(d.type))
        .toList();

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(greeting,
                      style:
                          const TextStyle(fontSize: 12, color: kMuted)),
                  const SizedBox(height: 2),
                  const Text(
                    'My Home',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      color: kInk,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: kSoftShadow,
              ),
              child: const Icon(Icons.home_outlined, color: kInkSoft),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _WeatherCard(),
        const SectionHead(title: 'Your devices'),
        _FilterChips(controller: c),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: list.map((d) {
                final wide = d.type == 'climate';
                return SizedBox(
                  width: wide ? constraints.maxWidth : cardWidth,
                  child: _DeviceCard(controller: c, device: d),
                );
              }).toList(),
            );
          },
        ),
        SectionHead(title: 'Scenes', trailing: '${scenes.length} saved'),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: scenes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final scene = scenes[index];
              return _SceneCard(
                device: scene,
                onTap: () {
                  final result = c.run(scene.name.toLowerCase());
                  onToast(result.text);
                },
              );
            },
          ),
        ),
        SectionHead(
          title: 'Recent activity',
          trailing: '${c.activity.length}',
        ),
        ActivityList(
          entries: c.activity.take(4).toList(),
          emptyText: 'Nothing yet. Tap the mic or run a scene.',
        ),
      ],
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Colors.white, Color(0xFFF5F1EC)],
        ),
        boxShadow: kSoftShadow,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: kAccentSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wb_sunny_outlined,
                color: kAccent, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Sunny, 24\u00B0C',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: kInk,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Harare, Zimbabwe',
                  style: TextStyle(fontSize: 12, color: kMuted),
                ),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '59%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kInk,
                ),
              ),
              Text('Humidity',
                  style: TextStyle(fontSize: 10.5, color: kMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: kFamilies.map((family) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PillChip(
              label: family,
              active: controller.filter == family,
              onTap: () => controller.setFilter(family),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.controller, required this.device});

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
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 128),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(22),
            boxShadow: kSoftShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  DeviceGlyph(device: d),
                  if (toggleable)
                    HomeSwitch(
                      value: isDeviceOn(d),
                      onTap: () => c.toggle(d),
                    )
                  else
                    const Icon(Icons.chevron_right,
                        size: 18, color: Color(0xFFB9BDC4)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                d.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: kInk,
                ),
              ),
              Text(d.room,
                  style: const TextStyle(fontSize: 11.5, color: kMuted)),
              const SizedBox(height: 6),
              if (d.type == 'climate')
                Row(
                  children: <Widget>[
                    Text(
                      '${d.target}\u00B0',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                        color: kInk,
                      ),
                    ),
                    const Spacer(),
                    _stepButton(
                      Icons.remove,
                      () => c.mutate(() {
                        d.target = (d.target - 1).clamp(16, 30).toInt();
                        d.on = true;
                      }),
                    ),
                    const SizedBox(width: 6),
                    _stepButton(
                      Icons.add,
                      () => c.mutate(() {
                        d.target = (d.target + 1).clamp(16, 30).toInt();
                        d.on = true;
                      }),
                    ),
                  ],
                )
              else
                Text(
                  deviceStateLine(d),
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.3,
                    color: kInkSoft,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F4),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 16, color: kInk),
      ),
    );
  }
}

class _SceneCard extends StatelessWidget {
  const _SceneCard({required this.device, required this.onTap});

  final Device device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 156,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kNavy,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(deviceIcon(device),
                  size: 17, color: Colors.white),
            ),
            const Spacer(),
            Text(
              device.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              deviceStateLine(device),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0x99FFFFFF)),
            ),
          ],
        ),
      ),
    );
  }
}
