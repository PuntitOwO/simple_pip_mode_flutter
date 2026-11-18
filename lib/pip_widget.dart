import 'package:flutter/material.dart';
import 'package:simple_pip_mode/actions/pip_action.dart';
import 'package:simple_pip_mode/actions/pip_actions_layout.dart';
import 'package:simple_pip_mode/simple_pip.dart';

/// Widget that uses PIP callbacks to build some widgets depending on PIP state.
///
/// Parameters:
/// * [pipChild] widget is used when app is in PIP mode.
/// * [child] widget is used when app is not in PIP mode.
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
  final Widget child;
  final Widget pipChild;
  final PipActionsLayout pipLayout;
  const PipWidget({
    super.key,
    this.onPipEntered,
    this.onPipExited,
    this.onPipAction,
    this.pipLayout = PipActionsLayout.none,
    required this.child,
    required this.pipChild,
  });

  @override
  PipWidgetState createState() => PipWidgetState();
}

class PipWidgetState extends State<PipWidget> {
  /// Pip controller to handle callbacks
  late final SimplePip pip;

  /// Whether the app is currently in PIP mode
  bool _pipMode = false;

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
  Widget build(BuildContext context) =>
      _pipMode ? widget.pipChild : widget.child;
}
