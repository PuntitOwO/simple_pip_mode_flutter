import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pip_mode/pip_widget.dart';
import 'package:simple_pip_mode/simple_pip.dart';

void main() {
  const MethodChannel channel = MethodChannel('puntito.simple_pip_mode');

  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'widget rendering should change when pip mode changes',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PipWidget(
            builder: (_) => const Text('off'),
            pipBuilder: (_) => const Text('on'),
          ),
        ),
      );
      final PipWidgetState state = tester.state(find.byType(PipWidget));
      SimplePip pip = state.pip;

      TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'enterPipMode':
            channel.invokeMethod('onPipEntered');
            break;
          // Simulate calling the exited callback
          case 'testExitPipMode':
            channel.invokeMethod('onPipExited');
            break;
          // This handler overrides the SimplePip handler, so we add cases here.
          case 'onPipEntered':
            pip.onPipEntered?.call();
            break;
          case 'onPipExited':
            pip.onPipExited?.call();
            break;
        }
        return null;
      });

      expect(find.text('off'), findsOneWidget);
      expect(find.text('on'), findsNothing);

      await pip.enterPipMode();
      await tester.pump();

      expect(find.text('off'), findsNothing);
      expect(find.text('on'), findsOneWidget);

      await channel.invokeMethod('testExitPipMode');
      await tester.pump();

      expect(find.text('off'), findsOneWidget);
      expect(find.text('on'), findsNothing);
    },
  );
}
