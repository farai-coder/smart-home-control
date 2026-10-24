import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_control/main.dart';

void main() {
  testWidgets('dashboard renders and tabs navigate', (tester) async {
    await tester.pumpWidget(const SmartHomeApp());
    await tester.pumpAndSettle();

    expect(find.text('My Home'), findsOneWidget);
    expect(find.text('Air Conditioner'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Scenes'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Scenes'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('tab-rooms')));
    await tester.pumpAndSettle();
    expect(find.text('Kitchen'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('tab-analysis')));
    await tester.pumpAndSettle();
    expect(find.text('Energy use'), findsOneWidget);
    expect(find.text('385'), findsOneWidget);
  });

  testWidgets('room opens a device with its controls', (tester) async {
    await tester.pumpWidget(const SmartHomeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('tab-rooms')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kitchen'));
    await tester.pumpAndSettle();
    expect(find.text('All devices'), findsOneWidget);

    await tester.tap(find.text('Kitchen Light').first);
    await tester.pumpAndSettle();

    expect(find.text('Brightness'), findsOneWidget);
    expect(find.text('Colour temperature'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('zigbee2mqtt/kitchen_light/set'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('zigbee2mqtt/kitchen_light/set'), findsOneWidget);
  });

  testWidgets('voice sheet runs a command against the home', (tester) async {
    await tester.pumpWidget(const SmartHomeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pumpAndSettle();
    expect(find.text('Voice control'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'turn on the bedroom lights',
    );
    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Bedroom Light 1 and Bedroom Light 2 -> on'),
      findsOneWidget,
    );
    expect(
      find.textContaining('zigbee2mqtt/bedroom_light_1/set'),
      findsOneWidget,
    );
  });
}
