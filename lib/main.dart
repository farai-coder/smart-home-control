import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'data/devices.dart';
import 'screens/add_device.dart';
import 'screens/analysis.dart';
import 'screens/dashboard.dart';
import 'screens/device_screen.dart';
import 'screens/rooms.dart';
import 'screens/voice_sheet.dart';
import 'state/home_controller.dart';

void main() {
  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kScreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kAccent,
          brightness: Brightness.light,
        ),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final HomeController _controller = HomeController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: kNavy,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2200),
        ),
      );
  }

  void _openVoice() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceSheet(controller: _controller),
    );
  }

  Widget _screen() {
    final c = _controller;
    switch (c.route.name) {
      case 'rooms':
        return RoomsScreen(controller: c);
      case 'room':
        return RoomScreen(controller: c, room: c.route.room ?? 'Lounge');
      case 'device':
        final device = c.byId(c.route.id);
        if (device == null) {
          return DashboardScreen(controller: c, onToast: _toast);
        }
        return DeviceScreen(
          controller: c,
          device: device,
          onToast: _toast,
        );
      case 'analysis':
        return const AnalysisScreen();
      case 'add':
        return AddDeviceScreen(controller: c, onToast: _toast);
      default:
        return DashboardScreen(controller: c, onToast: _toast);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final c = _controller;
        final isAdd = c.route.name == 'add';

        return PhoneFrame(
          child: Scaffold(
            backgroundColor: isAdd ? kNavy : kScreen,
            body: SafeArea(
              bottom: false,
              child: _screen(),
            ),
            bottomNavigationBar: _TabBar(controller: c, dark: isAdd),
            floatingActionButton: isAdd
                ? null
                : FloatingActionButton(
                    onPressed: _openVoice,
                    backgroundColor: kAccent,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.mic_none),
                  ),
          ),
        );
      },
    );
  }
}

class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return ColoredBox(color: kScreen, child: child);
        }
        final height = math.min(880.0, constraints.maxHeight - 48);
        return ColoredBox(
          color: kCanvas,
          child: Center(
            child: Container(
              width: 420,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(44),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x2E121824),
                    blurRadius: 60,
                    offset: Offset(0, 26),
                  ),
                  BoxShadow(
                    color: Color(0xFFFFFFFF),
                    spreadRadius: 10,
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0xFFD8DADE),
                    spreadRadius: 12,
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(44),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.controller, required this.dark});

  final HomeController controller;
  final bool dark;

  static const List<MapEntry<String, MapEntry<String, IconData>>> tabs =
      <MapEntry<String, MapEntry<String, IconData>>>[
    MapEntry<String, MapEntry<String, IconData>>(
        'dashboard', MapEntry<String, IconData>('Dashboard', Icons.home_outlined)),
    MapEntry<String, MapEntry<String, IconData>>(
        'rooms', MapEntry<String, IconData>('Rooms', Icons.grid_view_rounded)),
    MapEntry<String, MapEntry<String, IconData>>(
        'analysis', MapEntry<String, IconData>('Analysis', Icons.bar_chart)),
    MapEntry<String, MapEntry<String, IconData>>(
        'add', MapEntry<String, IconData>('Add', Icons.add)),
  ];

  String get _active {
    final name = controller.route.name;
    if (name == 'room' || name == 'device') return 'rooms';
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final muted = dark ? Colors.white.withValues(alpha: 0.55) : kMuted;
    final activeColour = dark ? Colors.white : kAccent;

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      decoration: BoxDecoration(
        color: dark ? kNavy : Colors.white,
        border: Border(
          top: BorderSide(
            color: dark ? Colors.white.withValues(alpha: 0.08) : kLine,
          ),
        ),
      ),
      child: Row(
        children: tabs.map((tab) {
          final active = _active == tab.key;
          return Expanded(
            child: GestureDetector(
              key: ValueKey<String>('tab-${tab.key}'),
              onTap: () => controller.tab(tab.key),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    tab.value.value,
                    size: 21,
                    color: active ? activeColour : muted,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tab.value.key,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: active ? activeColour : muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
