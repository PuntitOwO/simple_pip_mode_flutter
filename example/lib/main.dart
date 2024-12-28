// ignore_for_file: sort_child_properties_last

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide AspectRatio;
import 'package:simple_pip_mode/actions/pip_action.dart';
import 'package:simple_pip_mode/actions/pip_actions_layout.dart';
import 'package:simple_pip_mode/aspect_ratio.dart';
import 'package:simple_pip_mode/pip_widget.dart'; // To build pip mode dependent layouts
import 'package:simple_pip_mode/simple_pip.dart'; // To enter pip mode and receive callbacks

/// Some aspect ratio presets to choose
const aspectRatios = [
  (1, 1),
  (2, 3),
  (3, 2),
  (16, 9),
  (9, 16),
];

void main() {
  // Make sure binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExampleApp());
}

/// Example App to show usage of PIP mode
class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  bool pipAvailable = false;
  AspectRatio aspectRatio = aspectRatios.first;
  bool autoPipAvailable = false;
  bool autoPipSwitch = false;
  late SimplePip pip;

  PipActionsLayout pipActionsLayout = PipActionsLayout.none;
  // Used to represent interaction with PIP actions
  bool isPlaying = true;
  String actionResponse = "";

  @override
  void initState() {
    super.initState();
    // Instance a pip without callbacks to use it only to activate pip mode
    pip = SimplePip();
    requestPipAvailability();
  }

  /// Checks if system supports PIP mode
  Future<void> requestPipAvailability() async {
    var isAvailable = await SimplePip.isPipAvailable;
    var isAutoPipAvailable = await SimplePip.isAutoPipAvailable;
    setState(() {
      pipAvailable = isAvailable;
      autoPipAvailable = isAutoPipAvailable;
    });
  }

  /// List of available layouts
  List<DropdownMenuItem<PipActionsLayout>> get layoutList {
    return PipActionsLayout.values
        .map<DropdownMenuItem<PipActionsLayout>>(
          (PipActionsLayout layout) => DropdownMenuItem<PipActionsLayout>(
            value: layout,
            child: Text(layout.name),
          ),
        )
        .toList();
  }

  /// List of available aspect ratio presets
  List<DropdownMenuItem<AspectRatio>> get aspectRatioList {
    return aspectRatios
        .map<DropdownMenuItem<AspectRatio>>(
          (AspectRatio ratio) => DropdownMenuItem<AspectRatio>(
            value: ratio,
            child: Text(ratio.name),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Pip widget can build different widgets for each mode
      home: PipWidget(
        // builder is null so child is used when not in pip mode
        pipLayout: pipActionsLayout,
        onPipAction: _handlePipAction,
        child: Scaffold(
          appBar: AppBar(title: const Text('PiP Plugin example app')),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('PiP Available: '),
                  Icon(pipAvailable ? Icons.check : Icons.close),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('PiP Activated: '),
                  Icon(Icons.close),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Aspect ratio: '),
                  DropdownButton<AspectRatio>(
                    value: aspectRatio,
                    onChanged: _handleAspectRatioSelection,
                    items: aspectRatioList,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Auto Enter (Android S): '),
                  Switch(
                    value: autoPipSwitch,
                    onChanged: autoPipAvailable ? _handleAutoSwitch : null,
                  ),
                ],
              ),
              IconButton(
                onPressed: pipAvailable ? _handleEnterPip : null,
                icon: const Icon(Icons.picture_in_picture),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(thickness: 1),
              ),
              const Text("PIP Actions:"),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text("Current actions layout: "),
                    DropdownButton<PipActionsLayout>(
                      value: pipActionsLayout,
                      onChanged: _handlePipActionsLayoutSelection,
                      items: layoutList,
                    ),
                  ],
                ),
              ),
              if (pipActionsLayout != PipActionsLayout.none)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text("Simulated player: "),
                          IconButton(
                            onPressed: () {
                              bool newValue = !isPlaying;
                              pip.setIsPlaying(newValue);
                              setState(() {
                                isPlaying = newValue;
                                actionResponse = "";
                              });
                            },
                            isSelected: isPlaying,
                            icon: const Icon(Icons.play_arrow),
                            selectedIcon: const Icon(Icons.pause),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Obs.: "
                        "Tap the simulated player button to see the PIP "
                        "actions be updated on PIP mode, when you tap PIP "
                        "actions on PIP mode it will reflect here too",
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        // pip builder is null so pip child is used when in pip mode
        pipChild: Scaffold(
          appBar: AppBar(title: const Text('Pip Mode')),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: double.maxFinite),
              const Text('PiP activated'),
              if (pipActionsLayout != PipActionsLayout.none) ...[
                Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                Text(actionResponse),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _handlePipActionsLayoutSelection(PipActionsLayout? newValue) {
    if (newValue == null) return;
    pip.setPipActionsLayout(newValue);
    pip.setIsPlaying(true);
    setState(() {
      isPlaying = true;
      pipActionsLayout = newValue;
    });
  }

  void _handleEnterPip() => pip.enterPipMode(
        aspectRatio: aspectRatio,
        autoEnter: autoPipSwitch,
        seamlessResize: autoPipSwitch,
      );

  void _handleAutoSwitch(newValue) {
    pip.setAutoPipMode(
      aspectRatio: aspectRatio,
      autoEnter: newValue,
      seamlessResize: newValue,
    );
    setState(() => autoPipSwitch = newValue);
  }

  void _handleAspectRatioSelection(AspectRatio? newValue) {
    if (newValue == null) return;
    pip.setAutoPipMode(
      aspectRatio: newValue,
      autoEnter: autoPipSwitch,
      seamlessResize: autoPipSwitch,
    );
    setState(() => aspectRatio = newValue);
  }

  void _handlePipAction(PipAction action) {
    if (kDebugMode) print("PIP ACTION TAP: ${action.name}");
    switch (action) {
      case PipAction.play:
        // example: videoPlayerController.play();
        setState(() {
          isPlaying = true;
          actionResponse = "Playing";
        });
      case PipAction.pause:
        // example: videoPlayerController.pause();
        setState(() {
          isPlaying = false;
          actionResponse = "Paused";
        });
      case PipAction.live:
        // example: videoPlayerController.forceLive();
        setState(() => actionResponse = "Go to live view");
      case PipAction.next:
        // example: videoPlayerController.next();
        setState(() => actionResponse = "Next");
      case PipAction.previous:
        // example: videoPlayerController.previous();
        setState(() => actionResponse = "Previous");
      case PipAction.rewind:
        // example: videoPlayerController.seek(-10);
        setState(() => actionResponse = "Rewind");
      case PipAction.forward:
        // example: videoPlayerController.seek(10);
        setState(() => actionResponse = "Forward");
    }
  }
}
