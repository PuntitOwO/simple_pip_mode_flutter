import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';

/// Main controller class.
/// It can verify whether the system supports PIP,
/// check whether the app is currently in PIP mode,
/// request entering PIP mode,
/// and call some callbacks when the app changes its mode.
class SimplePip {
  static const MethodChannel _channel =
      MethodChannel('puntito.simple_pip_mode');

  /// Whether this device supports PIP mode.
  static Future<bool> get isPipAvailable async {
    final bool? isAvailable = await _channel.invokeMethod('isPipAvailable');
    return isAvailable ?? false;
  }

  /// Whether the device supports AutoEnter PIP parameter (Android S)
  static Future<bool> get isAutoPipAvailable async {
    final bool? isAvailable = await _channel.invokeMethod('isAutoPipAvailable');
    return isAvailable ?? false;
  }

  /// Whether the app is currently in PIP mode.
  static Future<bool> get isPipActivated async {
    final bool? isActivated = await _channel.invokeMethod('isPipActivated');
    return isActivated ?? false;
  }

  /// Called when the app enters PIP mode
  VoidCallback? onPipEntered;

  /// Called when the app exits PIP mode
  VoidCallback? onPipExited;

  /// Request entering PIP mode
  Future<bool> enterPipMode({
    aspectRatio = const [16, 9],
    autoEnter = false,
    seamlessResize = false,
  }) async {
    Map params = {
      'aspectRatio': aspectRatio,
      'autoEnter': autoEnter,
      'seamlessResize': seamlessResize,
    };
    final bool? enteredSuccessfully =
        await _channel.invokeMethod('enterPipMode', params);
    return enteredSuccessfully ?? false;
  }

  /// Request setting automatic PIP mode.
  /// Android 12 (Android S, API level 31) or newer required.
  Future<bool> setAutoPipMode({
    aspectRatio = const [16, 9],
    seamlessResize = false,
  }) async {
    Map params = {
      'aspectRatio': aspectRatio,
      'autoEnter': true,
      'seamlessResize': seamlessResize,
    };
    final bool? setSuccessfully =
        await _channel.invokeMethod('setAutoPipMode', params);
    return setSuccessfully ?? false;
  }

  SimplePip({this.onPipEntered, this.onPipExited}) {
    if (onPipEntered != null || onPipExited != null) {
      _channel.setMethodCallHandler(
        (call) async {
          if (call.method == 'onPipEntered') {
            onPipEntered?.call();
          } else if (call.method == 'onPipExited') {
            onPipExited?.call();
          }
        },
      );
    }
  }
}
