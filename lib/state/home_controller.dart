import 'package:flutter/foundation.dart';

import '../data/devices.dart';
import '../logic/commands.dart';

class ActivityEntry {
  const ActivityEntry(this.text, this.time, {this.ok = true, this.deviceId});

  final String text;
  final String time;
  final bool ok;
  final String? deviceId;
}

class AppRoute {
  const AppRoute(this.name, {this.id, this.room});

  final String name;
  final String? id;
  final String? room;
}

class HomeController extends ChangeNotifier {
  HomeController({
    List<Device>? devices,
    List<String>? plates,
  })  : devices = devices ?? demoDevices(),
        plates = plates ?? <String>['ABC 1234', 'ZIM 4567'];

  final List<Device> devices;
  final List<String> plates;
  final List<ActivityEntry> activity = <ActivityEntry>[];
  final List<CommandResult> results = <CommandResult>[];
  final List<String> added = <String>[];
  final List<AppRoute> history = <AppRoute>[];

  AppRoute route = const AppRoute('dashboard');
  String filter = 'All';
  String? plateMessage;
  bool plateMessageOk = true;

  Device? byId(String? id) {
    if (id == null) return null;
    for (final d in devices) {
      if (d.id == id) return d;
    }
    return null;
  }

  List<String> get roomNames {
    final names = <String>[];
    for (final d in devices) {
      if (!names.contains(d.room)) names.add(d.room);
    }
    return names;
  }

  List<Device> devicesIn(String room) =>
      devices.where((d) => d.room == room).toList();

  List<ActivityEntry> activityFor(String deviceId) => activity
      .where((entry) => entry.deviceId == deviceId)
      .take(4)
      .toList();

  void go(String name, {String? id, String? room}) {
    history.add(route);
    route = AppRoute(name, id: id, room: room);
    notifyListeners();
  }

  void back() {
    if (history.isEmpty) {
      route = const AppRoute('dashboard');
    } else {
      route = history.removeLast();
    }
    notifyListeners();
  }

  void tab(String name) {
    history.clear();
    route = AppRoute(name);
    notifyListeners();
  }

  void setFilter(String value) {
    filter = value;
    notifyListeners();
  }

  void mutate(VoidCallback change, {String? logText, String? deviceId}) {
    change();
    if (logText != null) {
      log(logText, deviceId: deviceId);
    }
    notifyListeners();
  }

  void log(String text, {bool ok = true, String? deviceId}) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    activity.insert(0, ActivityEntry(text, time, ok: ok, deviceId: deviceId));
    if (activity.length > 30) {
      activity.removeRange(30, activity.length);
    }
  }

  void toggle(Device d) {
    if (!const <String>['light', 'switch', 'fan', 'climate', 'media']
        .contains(d.type)) {
      return;
    }
    final next = !d.on;
    mutate(() => d.on = next,
        logText: '${d.name} -> ${next ? 'on' : 'off'}', deviceId: d.id);
  }

  CommandResult run(String text) {
    final result = runCommand(text, CommandStore(devices, plates));
    results.insert(0, result);
    if (results.length > 6) {
      results.removeRange(6, results.length);
    }
    log(result.text, ok: result.ok, deviceId: result.deviceId);
    notifyListeners();
    return result;
  }

  void addPlate(String plate) {
    final clean = plate.toUpperCase().trim();
    if (plates.contains(clean)) {
      plateMessage = '$clean is already on the whitelist';
      plateMessageOk = false;
    } else {
      plates.add(clean);
      plateMessage = 'Added $clean to the whitelist (${plates.length} plates)';
      plateMessageOk = true;
      log(plateMessage!, deviceId: 'gate');
    }
    notifyListeners();
  }

  void removePlate(String plate) {
    plates.remove(plate);
    plateMessage = 'Removed $plate';
    plateMessageOk = true;
    log(plateMessage!, deviceId: 'gate');
    notifyListeners();
  }

  void checkPlate(String plate) {
    final clean = plate.toUpperCase().trim();
    final known = plates.contains(clean);
    plateMessage = known
        ? '$clean is on the whitelist - gate access granted'
        : '$clean is not on the whitelist - gate stays closed';
    plateMessageOk = known;
    notifyListeners();
  }

  void addFound(String name) {
    if (!added.contains(name)) {
      added.add(name);
      log('$name added to your home');
    }
    notifyListeners();
  }
}
