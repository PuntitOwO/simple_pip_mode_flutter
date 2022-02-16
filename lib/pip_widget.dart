import 'package:flutter/material.dart';
import 'package:simple_pip_mode/simple_pip.dart';

/// Widget that uses PIP callbacks to build some widgets depending on PIP state.
///
/// Parameters:
/// * [pipBuilder] function is used when app is in PIP mode. Must not be null.
/// * [builder] function is used when app is not in PIP mode. Must not be null.
/// * [onPipEntered] function is called when app enters PIP mode.
/// * [onPipExited] function is called when app exits PIP mode.
///
/// See also:
/// * [SimplePip], to handle callbacks.
class PipWidget extends StatefulWidget {
  final VoidCallback? onPipEntered;
  final VoidCallback? onPipExited;
  final Widget Function(BuildContext) builder;
  final Widget Function(BuildContext) pipBuilder;
  const PipWidget({
    Key? key,
    this.onPipEntered,
    this.onPipExited,
    required this.builder,
    required this.pipBuilder,
  }) : super(key: key);

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
    );
  }

  /// The app entered PIP mode
  void onPipEntered() {
    setState(() {
      _pipMode = true;
    });
    widget.onPipEntered?.call();
  }

  /// The app exited PIP mode
  void onPipExited() {
    setState(() {
      _pipMode = false;
    });
    widget.onPipExited?.call();
  }

  @override
  Widget build(BuildContext context) {
    return _pipMode ? widget.pipBuilder(context) : widget.builder(context);
  }
}
