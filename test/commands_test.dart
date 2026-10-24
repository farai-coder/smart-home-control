import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_control/logic/commands.dart';
import 'package:smart_home_control/state/home_controller.dart';

void main() {
  group('command catalogue', () {
    test('every listed command succeeds', () {
      for (final group in commandGroups) {
        final controller = HomeController();
        for (final item in group.items) {
          final result = controller.run(item.phrase);
          expect(
            result.ok,
            isTrue,
            reason:
                '${group.title} / ${item.label}: "${item.phrase}" -> ${result.text}',
          );
        }
      }
    });

    test('catalogue holds 59 commands', () {
      final total =
          commandGroups.fold<int>(0, (sum, group) => sum + group.items.length);
      expect(total, 59);
    });
  });

  group('lights', () {
    test('turning on the lounge lights targets the lamp', () {
      final c = HomeController();
      final result = c.run('turn on the lounge lights');
      expect(result.ok, isTrue);
      expect(c.byId('lounge_light')!.on, isTrue);
      expect(result.action, contains('zigbee2mqtt/lounge_light/set'));
    });

    test('spoken brightness lands on the bedroom lights', () {
      final c = HomeController();
      final result = c.run('set bedroom 1 brightness to 60 percent');
      expect(result.ok, isTrue);
      expect(c.byId('bedroom_light_1')!.brightness, 60);
      expect(c.byId('bedroom_light_2')!.brightness, 60);
      expect(c.byId('bedroom_light_1')!.on, isTrue);
    });

    test('colour and colour temperature both apply', () {
      final c = HomeController();
      c.run('set the lamp colour to blue');
      expect(c.byId('lounge_light')!.colour, 'blue');

      final warm = c.run(
          'set the kitchen light colour temperature to 5000 kelvin');
      expect(warm.ok, isTrue);
      expect(c.byId('kitchen_light')!.kelvin, 5000);
    });

    test('a room without lights is refused', () {
      final c = HomeController();
      final result = c.run('turn on the garage lights');
      expect(result.ok, isFalse);
      expect(result.text, contains('garage'));
    });
  });

  group('climate, covers and media', () {
    test('thermostat target is clamped and applied', () {
      final c = HomeController();
      final result = c.run('set the thermostat temperature to 22 degrees');
      expect(result.ok, isTrue);
      expect(c.byId('ac_entrance')!.target, 22);
      expect(c.byId('ac_entrance')!.on, isTrue);
    });

    test('blinds position maps to open state', () {
      final c = HomeController();
      final result = c.run('set the lounge blinds position to 40 percent');
      expect(result.ok, isTrue);
      expect(c.byId('lounge_blinds')!.position, 40);
      expect(c.byId('lounge_blinds')!.state, 'open');
    });

    test('media source and volume update', () {
      final c = HomeController();
      expect(c.run('select media source HDMI 2').ok, isTrue);
      expect(c.byId('smart_tv')!.source, 'HDMI 2');

      expect(c.run('set media volume to 30').ok, isTrue);
      expect(c.byId('smart_tv')!.volume, 30);
      expect(c.byId('smart_tv')!.muted, isFalse);
    });

    test('next track moves forward and keeps playing', () {
      final c = HomeController();
      final before = c.byId('smart_tv')!.track;
      expect(c.run('next track').ok, isTrue);
      expect(c.byId('smart_tv')!.track, before + 1);
      expect(c.byId('smart_tv')!.playing, isTrue);
    });
  });

  group('scenes and security', () {
    test('movie night changes lights, blinds and TV', () {
      final c = HomeController();
      final result = c.run('activate movie night');
      expect(result.ok, isTrue);
      expect(c.byId('lounge_light')!.brightness, 20);
      expect(c.byId('lounge_blinds')!.position, 0);
      expect(c.byId('smart_tv')!.playing, isTrue);
      expect(c.byId('scene_movie')!.lastRun, isNotNull);
    });

    test('gate opens, reports status and stops', () {
      final c = HomeController();
      expect(c.run('open the gate').ok, isTrue);
      expect(c.byId('gate')!.state, 'open');

      final status = c.run('check the gate status');
      expect(status.ok, isTrue);
      expect(status.text, contains('open'));

      expect(c.run('stop the gate').ok, isTrue);
      expect(c.byId('gate')!.state, 'stopped');
    });

    test('alarm arms and siren toggles', () {
      final c = HomeController();
      expect(c.run('arm the alarm').ok, isTrue);
      expect(c.byId('alarm')!.armed, isTrue);

      expect(c.run('trigger the siren').ok, isTrue);
      expect(c.byId('alarm')!.siren, isTrue);

      expect(c.run('stop the siren').ok, isTrue);
      expect(c.byId('alarm')!.siren, isFalse);
    });

    test('vacuum dock and locate work', () {
      final c = HomeController();
      expect(c.run('start the vacuum').ok, isTrue);
      expect(c.byId('vacuum')!.state, 'cleaning');

      expect(c.run('send the vacuum to the dock').ok, isTrue);
      expect(c.byId('vacuum')!.state, 'docked');

      expect(c.run('locate the vacuum').ok, isTrue);
    });
  });

  group('vehicle plates', () {
    test('known plate is allowed', () {
      final c = HomeController();
      final result = c.run('check plate ABC 1234');
      expect(result.ok, isTrue);
      expect(result.text, contains('granted'));
    });

    test('unknown plate is refused', () {
      final c = HomeController();
      final result = c.run('check plate QRS 4455');
      expect(result.ok, isFalse);
      expect(result.text, contains('not on the whitelist'));
    });

    test('plates can be added and removed', () {
      final c = HomeController();
      final add = c.run('add plate QRS 4455 to the whitelist');
      expect(add.ok, isTrue);
      expect(c.plates, contains('QRS 4455'));

      final check = c.run('check plate QRS 4455');
      expect(check.ok, isTrue);

      final remove = c.run('remove plate QRS 4455 from the whitelist');
      expect(remove.ok, isTrue);
      expect(c.plates, isNot(contains('QRS 4455')));
    });

    test('a plate without a number is rejected', () {
      final c = HomeController();
      final result = c.run('check plate');
      expect(result.ok, isFalse);
    });
  });

  group('fallbacks', () {
    test('unknown sentence is refused without touching devices', () {
      final c = HomeController();
      final before = c.byId('lounge_light')!.on;
      final result = c.run('make me a sandwich');
      expect(result.ok, isFalse);
      expect(c.byId('lounge_light')!.on, before);
    });

    test('blank input is refused', () {
      final c = HomeController();
      expect(c.run('   ').ok, isFalse);
    });
  });
}
