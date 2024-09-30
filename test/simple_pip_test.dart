import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pip_mode/simple_pip.dart';

void main() {
  const MethodChannel channel = MethodChannel('puntito.simple_pip_mode');

  TestWidgetsFlutterBinding.ensureInitialized();

  bool activated = false;
  bool enterCallbackCalled = false;
  bool exitCallbackCalled = false;
  SimplePip pip = SimplePip(
    onPipEntered: () => enterCallbackCalled = true,
    onPipExited: () => exitCallbackCalled = true,
  );

  setUp(() {
    enterCallbackCalled = false;
    exitCallbackCalled = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'isPipAvailable':
          return true;
        case 'isPipActivated':
          return activated;
        case 'enterPipMode':
          activated = true;
          channel.invokeMethod('onPipEntered');
          return activated;
        case 'testExitPipMode':
          activated = false;
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
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('isPipAvailable', () async {
    expect(await SimplePip.isPipAvailable, true);
  });

  test('isPipActivated', () async {
    expect(await SimplePip.isPipActivated, false);
  });

  test('enterPipMode', () async {
    expect(await SimplePip().enterPipMode(), true);
  });

  test('callbacks', () async {
    expect(await pip.enterPipMode(), true);
    expect(await SimplePip.isPipActivated, true);
    expect(enterCallbackCalled, true);
    await channel.invokeMethod('testExitPipMode');
    expect(await SimplePip.isPipActivated, false);
    expect(exitCallbackCalled, true);
  });
}
