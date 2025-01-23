// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:simple_pip_mode/actions/pip_action.dart';
import 'package:simple_pip_mode/actions/pip_actions_layout.dart';
import 'package:simple_pip_mode/simple_pip.dart';

/// Widget that uses PIP callbacks to build some widgets depending on PIP state.
/// At least one of [builder] or [child] must not be null.
/// At least one of [pipBuilder] or [pipChild] must not be null.
///
/// Parameters:
/// * [pipBuilder] function is used when app is in PIP mode.
/// * [pipChild] widget is used when app is in PIP mode and [pipBuilder] is null.
/// * [builder] function is used when app is not in PIP mode.
/// * [child] widget is used when app is not in PIP mode and [builder] is null.
/// * [onPipEntered] function is called when app enters PIP mode.
/// * [onPipExited] function is called when app exits PIP mode.
/// * [pipLayout] defines the PIP actions preset layout.
///
/// See also:
/// * [SimplePip], to handle callbacks.
class PipWidget extends StatefulWidget {
  final VoidCallback? onPipEntered;
  final VoidCallback? onPipExited;
  final Function(PipAction)? onPipAction;
  @Deprecated(
    'Use a Builder widget as the child instead. '
    'This field will be removed in v2.0.0.',
  )
  final Widget Function(BuildContext)? builder;
  final Widget? child;
  @Deprecated(
    'Use a Builder widget as the pipChild instead. '
    'This field will be removed in v2.0.0.',
  )
  final Widget Function(BuildContext)? pipBuilder;
  final Widget? pipChild;
  final PipActionsLayout pipLayout;
  const PipWidget({
    super.key,
    this.onPipEntered,
    this.onPipExited,
    this.onPipAction,
    this.builder,
    this.child,
    this.pipBuilder,
    this.pipChild,
    this.pipLayout = PipActionsLayout.none,
  })  : assert(child != null || builder != null),
        assert(pipChild != null || pipBuilder != null);

  @override
  PipWidgetState createState() => PipWidgetState();
}

class PipWidgetState extends State<PipWidget> {
  /// Pip controller to handle callbacks
  late final SimplePip pip;

  /// Whether the app is currently in PIP mode
  bool _pipMode = false;

  Widget? get builder =>
      widget.builder != null ? Builder(builder: widget.builder!) : null;
  Widget? get pipBuilder =>
      widget.pipBuilder != null ? Builder(builder: widget.pipBuilder!) : null;

  @override
  void initState() {
    super.initState();
    pip = SimplePip(
      onPipEntered: onPipEntered,
      onPipExited: onPipExited,
      onPipAction: onPipAction,
    );
    pip.setPipActionsLayout(widget.pipLayout);
  }

  /// The app entered PIP mode
  void onPipEntered() {
    setState(() => _pipMode = true);
    widget.onPipEntered?.call();
  }

  /// The app exited PIP mode
  void onPipExited() {
    setState(() => _pipMode = false);
    widget.onPipExited?.call();
  }

  /// The user taps one PIP action
  void onPipAction(PipAction action) => widget.onPipAction?.call(action);

  @override
  Widget build(BuildContext context) {
    return _pipMode
        ? (pipBuilder ?? widget.pipChild!)
        : (builder ?? widget.child!);
  }
}
