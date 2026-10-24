import '../config.dart';
import 'home_bus.dart';

HomeBus createHomeBus(
  TerminalConfig config, {
  required StatusCallback onStatus,
  required StateCallback onState,
}) {
  onStatus(BusState.demo, 'Demo mode - nothing is published');
  return _DemoBus();
}

class _DemoBus implements HomeBus {
  @override
  BusState get state => BusState.demo;

  @override
  String get detail => 'Demo mode - nothing is published';

  @override
  void connect() {}

  @override
  void publish(List<String> targetIds, String payload) {}

  @override
  void dispose() {}
}
