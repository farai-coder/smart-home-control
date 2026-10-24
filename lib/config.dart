/// Terminal settings, baked in at build time with `--dart-define`.
///
/// The Pi build passes LIVE=true and the broker address. A web or test build
/// keeps LIVE=false so it never opens a socket.
class TerminalConfig {
  const TerminalConfig({
    this.host = const String.fromEnvironment('MQTT_HOST',
        defaultValue: 'localhost'),
    this.port = const int.fromEnvironment('MQTT_PORT', defaultValue: 1883),
    this.baseTopic = const String.fromEnvironment('MQTT_BASE',
        defaultValue: 'zigbee2mqtt'),
    this.live = const bool.fromEnvironment('LIVE', defaultValue: false),
  });

  final String host;
  final int port;
  final String baseTopic;
  final bool live;

  String get label => '$host:$port';
}
