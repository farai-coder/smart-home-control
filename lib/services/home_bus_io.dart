import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../config.dart';
import 'home_bus.dart';

HomeBus createHomeBus(
  TerminalConfig config, {
  required StatusCallback onStatus,
  required StateCallback onState,
}) {
  return MqttHomeBus(config, onStatus: onStatus, onState: onState);
}

/// Speaks MQTT 3.1.1 to the local Mosquitto broker.
///
/// Zigbee2MQTT publishes device state to `<base>/<friendly_name>` and accepts
/// commands on `<base>/<friendly_name>/set`. The bus subscribes to everything
/// under the base topic, forwards device state to the controller and republishes
/// commands on the matching `set` topic.
class MqttHomeBus implements HomeBus {
  MqttHomeBus(
    this.config, {
    required this.onStatus,
    required this.onState,
  });

  final TerminalConfig config;
  final StatusCallback onStatus;
  final StateCallback onState;

  MqttServerClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updates;
  Timer? _retry;
  int _attempt = 0;
  bool _closed = false;
  bool _opening = false;

  BusState _state = BusState.connecting;
  String _detail = 'Not connected';

  @override
  BusState get state => _state;

  @override
  String get detail => _detail;

  @override
  void connect() {
    _closed = false;
    _open();
  }

  Future<void> _open() async {
    if (_closed || _opening) return;
    _opening = true;
    _retry?.cancel();
    _updates?.cancel();
    _updates = null;
    _set(BusState.connecting, 'Connecting to ${config.label}');

    final id = 'smart-home-pi-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final client = MqttServerClient.withPort(config.host, id, config.port);
    client.keepAlivePeriod = 30;
    client.connectTimeoutPeriod = 6000;
    client.logging(on: false);
    client.onConnected = () {
      _attempt = 0;
      _set(BusState.live, 'Live on ${config.label}');
    };
    client.onDisconnected = () {
      if (_closed) return;
      _set(BusState.offline, 'Lost ${config.label} - retrying');
      _scheduleRetry();
    };

    _client = client;
    try {
      final status = await client.connect();
      if (status?.state != MqttConnectionState.connected) {
        throw StateError('broker did not accept the connection');
      }
      client.subscribe('${config.baseTopic}/#', MqttQos.atMostOnce);
      _updates = client.updates?.listen(_onMessages);
      _set(BusState.live, 'Live on ${config.label}');
    } catch (_) {
      _set(BusState.offline, 'No broker at ${config.label} - retrying');
      try {
        client.disconnect();
      } catch (_) {
        // The socket may already be gone.
      }
      _scheduleRetry();
    } finally {
      _opening = false;
    }
  }

  void _onMessages(List<MqttReceivedMessage<MqttMessage>> events) {
    for (final event in events) {
      final prefix = '${config.baseTopic}/';
      final topic = event.topic;
      if (!topic.startsWith(prefix)) continue;
      final rest = topic.substring(prefix.length);

      if (rest.contains('/')) {
        if (rest.endsWith('/availability')) {
          final name = rest.substring(0, rest.length - '/availability'.length);
          final text = _text(event.payload);
          onState(name, <String, dynamic>{'__online': text == 'online'});
        }
        continue;
      }

      final Object? decoded;
      try {
        decoded = jsonDecode(_text(event.payload));
      } catch (_) {
        continue;
      }
      if (decoded is Map) {
        onState(rest, Map<String, dynamic>.from(decoded));
      }
    }
  }

  String _text(MqttMessage message) {
    final publish = message as MqttPublishMessage;
    return MqttPublishPayload.bytesToStringAsString(publish.payload.message);
  }

  @override
  void publish(List<String> targetIds, String payload) {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }
    for (final id in targetIds) {
      final builder = MqttClientPayloadBuilder()..addString(payload);
      client.publishMessage(
        '${config.baseTopic}/$id/set',
        MqttQos.atLeastOnce,
        builder.payload!,
      );
    }
  }

  void _scheduleRetry() {
    if (_closed) return;
    final seconds = math.min(30, 2 + math.pow(2, math.min(_attempt, 4)).toInt());
    _attempt++;
    _retry?.cancel();
    _retry = Timer(Duration(seconds: seconds), _open);
  }

  void _set(BusState state, String detail) {
    _state = state;
    _detail = detail;
    onStatus(state, detail);
  }

  @override
  void dispose() {
    _closed = true;
    _retry?.cancel();
    _updates?.cancel();
    try {
      _client?.disconnect();
    } catch (_) {
      // Nothing to close.
    }
  }
}
