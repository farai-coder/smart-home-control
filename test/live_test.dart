import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_control/config.dart';
import 'package:smart_home_control/logic/commands.dart';
import 'package:smart_home_control/services/home_bus.dart';
import 'package:smart_home_control/state/home_controller.dart';

class FakeBus implements HomeBus {
  final List<String> sent = <String>[];
  BusState _state = BusState.demo;

  @override
  BusState get state => _state;

  @override
  String get detail => 'fake';

  @override
  void connect() {
    _state = BusState.live;
  }

  @override
  void publish(List<String> targetIds, String payload) {
    for (final id in targetIds) {
      sent.add('$id $payload');
    }
  }

  @override
  void dispose() {}
}

HomeController live(FakeBus bus) {
  final c = HomeController(
    config: const TerminalConfig(live: true),
    bus: bus,
  );
  c.start();
  return c;
}

void main() {
  group('command payloads', () {
    test('a light command carries its target and payload', () {
      final c = HomeController();
      final result = c.run('turn off the lounge lights');
      expect(result.publishes, isTrue);
      expect(result.targetIds, <String>['lounge_light']);
      expect(result.payload, '{"state":"OFF"}');
    });

    test('multi room targets share one payload', () {
      final c = HomeController();
      final result = c.run('turn on the bedroom lights');
      expect(result.targetIds,
          <String>['bedroom_light_1', 'bedroom_light_2']);
      expect(result.payload, '{"state":"ON"}');
    });

    test('brightness is published on the Zigbee 0-254 scale', () {
      final c = HomeController();
      final result = c.run('set bedroom 1 brightness to 60 percent');
      expect(result.payload, contains('"brightness":152'));
    });

    test('colour temperature is published in mireds', () {
      final c = HomeController();
      final result =
          c.run('set the kitchen light colour temperature to 5000 kelvin');
      expect(result.payload, contains('"color_temp":200'));
      expect(result.payload, isNot(contains('colour_temp')));
    });

    test('colour is published under the zigbee key', () {
      final c = HomeController();
      final result = c.run('set the lamp colour to blue');
      expect(result.payload, contains('"color"'));
      expect(result.payload, contains('#4F8ECF'));
    });

    test('read only commands do not publish', () {
      final c = HomeController();
      expect(c.run('check gate status').publishes, isFalse);
      expect(c.run('read the entrance sensor').publishes, isFalse);
      expect(c.run('activate movie night').publishes, isFalse);
    });
  });

  group('live publishing', () {
    test('a panel toggle publishes the changed state', () {
      final bus = FakeBus();
      final c = live(bus);
      final ceiling = c.byId('ceiling_light')!;
      expect(ceiling.on, isFalse);

      c.toggle(ceiling);

      expect(bus.sent, <String>['ceiling_light {"state":"ON"}']);
    });

    test('a command publishes once per target', () {
      final bus = FakeBus();
      final c = live(bus);
      c.run('turn on the bedroom lights');

      expect(bus.sent, <String>[
        'bedroom_light_1 {"state":"ON"}',
        'bedroom_light_2 {"state":"ON"}',
      ]);
    });

    test('a slider change publishes only the moved field', () {
      final bus = FakeBus();
      final c = live(bus);
      final lamp = c.byId('lounge_light')!;

      c.mutate(() => lamp.brightness = 30);

      expect(bus.sent, <String>['lounge_light {"brightness":76}']);
    });

    test('a lock publishes LOCK and UNLOCK', () {
      final bus = FakeBus();
      final c = live(bus);
      final door = c.byId('front_door')!;

      c.mutate(() => door.locked = false);
      c.mutate(() => door.locked = true);

      expect(bus.sent, <String>[
        'front_door {"state":"UNLOCK"}',
        'front_door {"state":"LOCK"}',
      ]);
    });

    test('a scene publishes each affected device', () {
      final bus = FakeBus();
      final c = live(bus);
      c.run('activate movie night');

      expect(bus.sent, contains('lounge_light {"brightness":51}'));
      expect(bus.sent, contains('lounge_blinds {"position":0,"state":"CLOSE"}'));
    });

    test('media stays local because no broker mapping exists', () {
      final bus = FakeBus();
      final c = live(bus);
      c.run('pause media');
      expect(bus.sent, isEmpty);
    });

    test('demo builds never open a bus', () {
      final bus = FakeBus();
      final c = HomeController(bus: bus);
      c.start();
      c.run('turn on the kitchen lights');
      expect(bus.sent, isEmpty);
    });
  });

  group('inbound state', () {
    test('broker state lands on the device', () {
      final bus = FakeBus();
      final c = live(bus);

      c.applyState('kitchen_light', <String, dynamic>{
        'state': 'OFF',
        'brightness': 127,
        'color_temp': 333,
        'color': <String, dynamic>{'hex': '#4F8ECF'},
      });

      final light = c.byId('kitchen_light')!;
      expect(light.on, isFalse);
      expect(light.brightness, 50);
      expect(light.kelvin, 3003);
      expect(light.colour, 'blue');
      expect(bus.sent, isEmpty);
    });

    test('covers and locks map their state strings', () {
      final c = live(FakeBus());

      c.applyState('lounge_blinds', <String, dynamic>{'state': 'CLOSE'});
      expect(c.byId('lounge_blinds')!.position, 0);
      expect(c.byId('lounge_blinds')!.state, 'closed');

      c.applyState('front_door', <String, dynamic>{'state': 'UNLOCK'});
      expect(c.byId('front_door')!.locked, isFalse);
    });

    test('availability marks a device offline', () {
      final c = live(FakeBus());
      c.applyState('garden_light', <String, dynamic>{'__online': false});
      expect(c.byId('garden_light')!.online, isFalse);
    });

    test('unknown topics are ignored', () {
      final c = live(FakeBus());
      c.applyState('not_a_device', <String, dynamic>{'state': 'ON'});
      expect(c.devices.every((d) => d.id != 'not_a_device'), isTrue);
    });
  });

  group('command results', () {
    test('a failed command carries no payload', () {
      final c = HomeController();
      final CommandResult result = c.run('make me a sandwich');
      expect(result.ok, isFalse);
      expect(result.publishes, isFalse);
    });
  });
}
