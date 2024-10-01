import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pip_mode/pip_widget.dart';
import 'package:simple_pip_mode/simple_pip.dart';

void main() {
  const MethodChannel channel = MethodChannel('puntito.simple_pip_mode');

  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'builder rendering should change when pip mode changes',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PipWidget(
            builder: (_) => const Text('builder'),
            pipBuilder: (_) => const Text('pipbuilder'),
            pipChild: const Text('pipchild'),
            child: const Text('child'),
          ),
        ),
      );
      final PipWidgetState state = tester.state(find.byType(PipWidget));
      SimplePip pip = state.pip;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
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

      expect(find.text('builder'), findsOneWidget);
      expect(find.text('pipbuilder'), findsNothing);

      await pip.enterPipMode();
      await tester.pump();

      expect(find.text('builder'), findsNothing);
      expect(find.text('pipbuilder'), findsOneWidget);

      await channel.invokeMethod('testExitPipMode');
      await tester.pump();

      expect(find.text('builder'), findsOneWidget);
      expect(find.text('pipbuilder'), findsNothing);
    },
  );
  testWidgets(
    'child rendering should change when pip mode changes',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PipWidget(
            pipChild: Text('pipchild'),
            child: Text('child'),
          ),
        ),
      );
      final PipWidgetState state = tester.state(find.byType(PipWidget));
      SimplePip pip = state.pip;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
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

      expect(find.text('child'), findsOneWidget);
      expect(find.text('pipchild'), findsNothing);

      await pip.enterPipMode();
      await tester.pump();

      expect(find.text('child'), findsNothing);
      expect(find.text('pipchild'), findsOneWidget);

      await channel.invokeMethod('testExitPipMode');
      await tester.pump();

      expect(find.text('child'), findsOneWidget);
      expect(find.text('pipchild'), findsNothing);
    },
  );
}
