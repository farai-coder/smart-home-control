import 'package:flutter/material.dart';

import '../data/devices.dart';
import '../state/home_controller.dart';
import '../widgets/controls.dart';
import '../widgets/device_panels.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({
    super.key,
    required this.controller,
    required this.device,
    required this.onToast,
  });

  final HomeController controller;
  final Device device;
  final void Function(String) onToast;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final d = device;
    final meta = deviceTypeMeta[d.type];
    final toggleable =
        const <String>['light', 'switch', 'fan', 'climate', 'media']
            .contains(d.type);
    final logs = c.activityFor(d.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
      children: <Widget>[
        PageHeader(title: d.name, onBack: c.back),
        Row(
          children: <Widget>[
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: isDeviceOn(d) ? kAccent : kCard,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDeviceOn(d)
                    ? const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x52F2723A),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ]
                    : kSoftShadow,
              ),
              child: Icon(
                deviceIcon(d),
                size: 26,
                color: isDeviceOn(d) ? Colors.white : kInkSoft,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    d.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: kInk,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${d.room} - ${meta?.label ?? 'Device'} - Zigbee',
                    style: const TextStyle(fontSize: 11.5, color: kMuted),
                  ),
                ],
              ),
            ),
            if (toggleable)
              HomeSwitch(value: isDeviceOn(d), onTap: () => c.toggle(d)),
          ],
        ),
        const SizedBox(height: 18),
        ...buildDevicePanels(c: c, d: d, toast: onToast),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Column(
            children: <Widget>[
              InfoRow(label: 'Room', value: d.room),
              const Divider(height: 1, color: kLine),
              InfoRow(label: 'Type', value: meta?.label ?? 'Device'),
              const Divider(height: 1, color: kLine),
              InfoRow(
                label: 'Topic',
                value: 'zigbee2mqtt/${d.id}/set',
              ),
              const Divider(height: 1, color: kLine),
              InfoRow(
                label: d.battery > 0 && d.battery < 100 ? 'Battery' : 'Link',
                value: d.battery > 0 && d.battery < 100
                    ? '${d.battery}%'
                    : 'Strong - 100%',
              ),
            ],
          ),
        ),
        SectionHead(title: 'Activity', trailing: '${logs.length}'),
        ActivityList(
          entries: logs,
          emptyText:
              'No actions yet. Use the controls above or say a command.',
        ),
      ],
    );
  }
}
