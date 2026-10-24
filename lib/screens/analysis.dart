import 'package:flutter/material.dart';

import '../data/devices.dart';
import '../widgets/controls.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  static const List<MapEntry<String, int>> months = <MapEntry<String, int>>[
    MapEntry<String, int>('Feb', 402),
    MapEntry<String, int>('Mar', 388),
    MapEntry<String, int>('Apr', 371),
    MapEntry<String, int>('May', 379),
    MapEntry<String, int>('Jun', 385),
  ];

  @override
  Widget build(BuildContext context) {
    const selected = 4;
    final month = months[selected];
    final top = months
        .map((entry) => entry.value)
        .reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
      children: <Widget>[
        const Text('Energy use',
            style: TextStyle(fontSize: 12, color: kMuted)),
        const SizedBox(height: 2),
        const Text(
          'Analysis',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            color: kInk,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List<Widget>.generate(months.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PillChip(
                  label: months[index].key,
                  active: index == selected,
                  onTap: () {},
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Consumed',
                      style: TextStyle(fontSize: 12.5, color: kInkSoft)),
                  Icon(Icons.chevron_right, size: 16, color: kMuted),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    '${month.value}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.4,
                      color: kInk,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('kWh',
                      style: TextStyle(fontSize: 13, color: kMuted)),
                ],
              ),
              Text(
                'Costs \$${(month.value * 0.058).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: kMuted),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 54,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List<Widget>.generate(months.length, (index) {
                    final value = months[index].value;
                    final height = (value / top) * 54;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: index == selected
                                  ? kAccent
                                  : const Color(0xFFECEEF1),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                                bottom: Radius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Compared to others',
                      style: TextStyle(fontSize: 12.5, color: kInkSoft)),
                  Icon(Icons.chevron_right, size: 16, color: kMuted),
                ],
              ),
              const SizedBox(height: 4),
              _CompareRow(
                label: 'Most efficient homes',
                value: 292,
                ratio: 292 / 428,
              ),
              const _CompareRow(
                label: 'Your home',
                value: 385,
                ratio: 385 / 428,
                highlight: true,
              ),
              const _CompareRow(label: 'Average homes', value: 428, ratio: 1),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Consumed the most',
                  style: TextStyle(fontSize: 12.5, color: kInkSoft)),
              const SizedBox(height: 6),
              _UsageRow(
                icon: Icons.lightbulb_outline,
                label: 'Always on',
                value: 192,
                ratio: 1,
              ),
              _UsageRow(
                icon: Icons.ac_unit,
                label: 'Heating and cooling',
                value: 54,
                ratio: 54 / 192,
              ),
              _UsageRow(
                icon: Icons.power_outlined,
                label: 'Kitchen plugs',
                value: 38,
                ratio: 38 / 192,
              ),
              _UsageRow(
                icon: Icons.tv,
                label: 'Media',
                value: 21,
                ratio: 21 / 192,
                last: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.value,
    required this.ratio,
    this.highlight = false,
  });

  final String label;
  final int value;
  final double ratio;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(fontSize: 11.5, color: kInkSoft),
              ),
              Text(
                '$value kWh',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: highlight ? kAccentDeep : kInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0).toDouble(),
              minHeight: 6,
              backgroundColor: const Color(0xFFECEEF1),
              color: highlight ? kAccent : const Color(0xFFCFD3D9),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.ratio,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final int value;
  final double ratio;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: kLine)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 17, color: kInkSoft),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kInk,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0).toDouble(),
                    minHeight: 6,
                    backgroundColor: const Color(0xFFECEEF1),
                    color: const Color(0xFFCFD3D9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$value kWh',
            style: const TextStyle(fontSize: 11.5, color: kInkSoft),
          ),
        ],
      ),
    );
  }
}
