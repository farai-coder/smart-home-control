import 'package:flutter/material.dart';

import '../data/devices.dart';
import '../state/home_controller.dart';

const List<BoxShadow> kSoftShadow = <BoxShadow>[
  BoxShadow(
    color: Color(0x12141C2D),
    blurRadius: 24,
    offset: Offset(0, 10),
  ),
];

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = kCard,
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: color == kCard ? kSoftShadow : null,
      ),
      child: child,
    );
  }
}

class SectionHead extends StatelessWidget {
  const SectionHead({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 22, 2, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: kInk,
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(fontSize: 11.5, color: kMuted),
            ),
        ],
      ),
    );
  }
}

class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    required this.onTap,
    this.active = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 11 : 14,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: active ? kInk : kCard,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? kInk : kLine),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 11.5 : 12.5,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : kInkSoft,
          ),
        ),
      ),
    );
  }
}

class HomeSwitch extends StatelessWidget {
  const HomeSwitch({
    super.key,
    required this.value,
    required this.onTap,
    this.label,
  });

  final bool value;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final pill = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? kAccent : const Color(0xFFE2E4E8),
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (label == null) return pill;

    return Semantics(
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[pill],
      ),
    );
  }
}

class DeviceGlyph extends StatelessWidget {
  const DeviceGlyph({
    super.key,
    required this.device,
    this.size = 34,
    this.active,
  });

  final Device device;
  final double size;
  final bool? active;

  @override
  Widget build(BuildContext context) {
    final isActive = active ?? isDeviceOn(device);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? kAccent : const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(size * 0.35),
      ),
      child: Icon(
        deviceIcon(device),
        size: size * 0.52,
        color: isActive ? Colors.white : kInkSoft,
      ),
    );
  }
}

class SoftButton extends StatelessWidget {
  const SoftButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.dark = false,
    this.expand = false,
    this.fontSize = 11.5,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool dark;
  final bool expand;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: dark ? kNavy : const Color(0xFFF2F3F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon,
                  size: 15, color: dark ? Colors.white : kInkSoft),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: dark ? Colors.white : kInk,
              ),
            ),
          ],
        ),
      ),
    );
    return expand ? Expanded(child: button) : button;
  }
}

class ActionRow extends StatelessWidget {
  const ActionRow({super.key, required this.children, this.gap = 8});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) spaced.add(SizedBox(width: gap));
      spaced.add(children[i]);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(children: spaced),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 12.5, color: kMuted)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12.5, color: kInkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class RingValue extends StatelessWidget {
  const RingValue({
    super.key,
    required this.value,
    required this.top,
    required this.bottom,
    this.size = 176,
    this.stroke = 9,
  });

  final double value;
  final String top;
  final String bottom;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0).toDouble(),
              strokeWidth: stroke,
              strokeCap: StrokeCap.round,
              backgroundColor: const Color(0xFFECEEF1),
              color: kAccent,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                top,
                style: const TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                bottom,
                style: const TextStyle(fontSize: 10.5, color: kMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatItem {
  const StatItem(this.label, this.value);

  final String label;
  final String value;
}

class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.items});

  final List<StatItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.only(top: 14),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kLine)),
        ),
        child: Row(
          children: items
              .map(
                (item) => Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: kMuted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: kInk,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class ActivityList extends StatelessWidget {
  const ActivityList({
    super.key,
    required this.entries,
    this.emptyText = 'Nothing yet.',
  });

  final List<ActivityEntry> entries;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Text(
          emptyText,
          style: const TextStyle(fontSize: 12.5, color: kMuted),
        ),
      );
    }
    return Column(
      children: entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: entry.ok ? kAccent : const Color(0xFFB9BDC4),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.text,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: kInk,
                      ),
                    ),
                    Text(
                      entry.time,
                      style: const TextStyle(fontSize: 11, color: kMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.eyebrow,
  });

  final String title;
  final VoidCallback? onBack;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      child: Row(
        children: <Widget>[
          if (onBack != null) ...<Widget>[
            RoundIconButton(icon: Icons.chevron_left, onTap: onBack!),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (eyebrow != null)
                  Text(
                    eyebrow!,
                    style: const TextStyle(fontSize: 12, color: kMuted),
                  ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: onBack == null ? 27 : 15,
                    fontWeight:
                        onBack == null ? FontWeight.w700 : FontWeight.w600,
                    letterSpacing: onBack == null ? -0.6 : 0,
                    color: kInk,
                  ),
                ),
              ],
            ),
          ),
          const RoundIconButton(icon: Icons.more_horiz),
        ],
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.dark = false,
    this.size = 38,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool dark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: dark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: dark ? null : kSoftShadow,
        ),
        child: Icon(
          icon,
          size: 19,
          color: dark ? Colors.white : kInk,
        ),
      ),
    );
  }
}

class LabeledSlider extends StatelessWidget {
  const LabeledSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.label,
    this.valueLabel,
    this.lowLabel,
    this.highLabel,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int? divisions;
  final String? label;
  final String? valueLabel;
  final String? lowLabel;
  final String? highLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(label!,
                  style: const TextStyle(fontSize: 12.5, color: kInkSoft)),
              Text(
                valueLabel ?? '',
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: kInk),
              ),
            ],
          ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: kAccent,
            inactiveTrackColor: const Color(0xFFECEEF1),
            thumbColor: Colors.white,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 11,
              elevation: 3,
            ),
          ),
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        if (lowLabel != null || highLabel != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(lowLabel ?? '',
                  style: const TextStyle(fontSize: 10.5, color: kMuted)),
              Text(highLabel ?? '',
                  style: const TextStyle(fontSize: 10.5, color: kMuted)),
            ],
          ),
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F3F5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kInkSoft,
          ),
        ),
      ),
    );
  }
}

class BigGlyph extends StatelessWidget {
  const BigGlyph({
    super.key,
    required this.icon,
    this.active = false,
  });

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      margin: const EdgeInsets.only(bottom: 12, top: 4),
      decoration: BoxDecoration(
        color: active ? kAccentSoft : const Color(0xFFF2F3F5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 44,
        color: active ? kAccent : kInkSoft,
      ),
    );
  }
}

class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    return SizedBox(
      height: 76,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparkPainter(
          values: values,
          min: minValue,
          max: maxValue,
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({
    required this.values,
    required this.min,
    required this.max,
  });

  final List<double> values;
  final double min;
  final double max;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final span = (max - min) == 0 ? 1.0 : max - min;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = 8 + (i * (size.width - 16)) / (values.length - 1);
      final y = size.height - 10 - ((values[i] - min) / span) * (size.height - 24);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = kAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
