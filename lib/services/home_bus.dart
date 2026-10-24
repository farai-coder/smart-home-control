import 'home_bus_stub.dart' if (dart.library.io) 'home_bus_io.dart' as impl;
import '../config.dart';

enum BusState { demo, connecting, live, offline }

typedef StatusCallback = void Function(BusState state, String detail);
typedef StateCallback = void Function(String id, Map<String, dynamic> fields);

/// The app's link to the house. Only lights, plugs, fans, climate, covers,
/// locks and sensors are wired to Zigbee2MQTT; the rest stay on-screen demos.
abstract class HomeBus {
  BusState get state;
  String get detail;
  void connect();
  void publish(List<String> targetIds, String payload);
  void dispose();
}

HomeBus createHomeBus(
  TerminalConfig config, {
  required StatusCallback onStatus,
  required StateCallback onState,
}) {
  return impl.createHomeBus(
    config,
    onStatus: onStatus,
    onState: onState,
  );
}
