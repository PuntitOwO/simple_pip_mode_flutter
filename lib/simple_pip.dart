import 'dart:async';

import 'package:flutter/services.dart';
import 'package:simple_pip_mode/actions/pip_action.dart';
import 'package:simple_pip_mode/actions/pip_actions_layout.dart';
import 'package:simple_pip_mode/aspect_ratio.dart';

/// Main controller class.
/// It can verify whether the system supports PIP,
/// check whether the app is currently in PIP mode,
/// request entering PIP mode,
/// and call some callbacks when the app changes its mode.
class SimplePip {
  static const _channel = MethodChannel('puntito.simple_pip_mode');

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

  /// Called when the user taps on a PIP action
  void Function(PipAction)? onPipAction;

  /// Request entering PIP mode
  Future<bool> enterPipMode({
    AspectRatio aspectRatio = const (16, 9),
    bool autoEnter = false,
    bool seamlessResize = false,
  }) async {
    Map params = {
      'aspectRatio': aspectRatio.asList,
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
    AspectRatio aspectRatio = const (16, 9),
    bool seamlessResize = false,
    bool autoEnter = true,
  }) async {
    Map params = {
      'aspectRatio': aspectRatio.asList,
      'autoEnter': autoEnter,
      'seamlessResize': seamlessResize,
    };
    final bool? setSuccessfully =
        await _channel.invokeMethod('setAutoPipMode', params);
    return setSuccessfully ?? false;
  }

  /// Updates the current actions layout with a preset layout
  /// The preset layout is defined by [PipActionsLayout] and it's equivalent enum inside Android src
  Future<bool> setPipActionsLayout(PipActionsLayout layout) async {
    Map params = {'layout': layout.name};
    final bool? setSuccessfully =
        await _channel.invokeMethod('setPipLayout', params);
    return setSuccessfully ?? false;
  }

  /// Updates the actions [PipAction.play] and [PipAction.pause]
  /// When it is called it does re-render the action inside PIP acording with [isPlaying] value
  ///
  /// If [isPlaying] is `true` then PIP will shows [PipAction.pause] action
  /// If [isPlaying] is `false` then PIP will shows [PipAction.play] action
  ///
  /// NOTE: This method should ONLY be used to update PIP action when the player state was changed by
  /// OTHER button that is NOT the PIP's one (ex.: the player play/pause button, notification controller play/pause button
  /// or whatever button you have that calls your playerController's play/pause). When user taps PIP's [PipAction.play] or
  /// [PipAction.pause] it automatically updates the action, WITHOUT NEEDING to call this [setIsPlaying] method.
  ///
  /// Only affects media actions layout presets or presets that uses [PipAction.play] or [PipAction.pause] actions.
  Future<bool> setIsPlaying(bool isPlaying) async {
    Map params = {'isPlaying': isPlaying};
    final bool? setSuccessfully =
        await _channel.invokeMethod('setIsPlaying', params);
    return setSuccessfully ?? false;
  }

  SimplePip({this.onPipEntered, this.onPipExited, this.onPipAction}) {
    if (onPipEntered != null || onPipExited != null || onPipAction != null) {
      _channel.setMethodCallHandler(
        (call) async {
          switch (call.method) {
            case 'onPipEntered':
              onPipEntered?.call();
            case 'onPipExited':
              onPipExited?.call();
            case 'onPipAction':
              String arg = call.arguments;
              PipAction action =
                  PipAction.values.firstWhere((e) => e.name == arg);
              onPipAction?.call(action);
          }
        },
      );
    }
  }
}
