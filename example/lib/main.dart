import 'package:flutter/material.dart';
import 'package:simple_pip_mode/actions/pip_action.dart';
import 'package:simple_pip_mode/actions/pip_actions_layout.dart';
import 'dart:async';

import 'package:simple_pip_mode/simple_pip.dart'; // To enter pip mode and receive callbacks
import 'package:simple_pip_mode/pip_widget.dart'; // To build pip mode dependent layouts

/// Some aspect ratio presets to choose
const aspectRatios = [
  [1, 1],
  [2, 3],
  [3, 2],
  [16, 9],
  [9, 16],
];

void main() {
  // Make sure binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExampleApp());
}

/// Example App to show usage of PIP mode
class ExampleApp extends StatefulWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  bool pipAvailable = false;
  List<int> aspectRatio = aspectRatios.first;
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

  List<DropdownMenuItem<PipActionsLayout>> layoutList() {
    return PipActionsLayout.values
        .map<DropdownMenuItem<PipActionsLayout>>(
          (PipActionsLayout value) => DropdownMenuItem<PipActionsLayout>(
            child: Text(value.name),
            value: value,
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
        onPipAction: (action) {
          print("PIP ACTION TAP: " + action.name);
          switch (action) {
            case PipAction.play:
              // example: videoPlayerController.play();
              setState(() {
                isPlaying = true;
                actionResponse = "Playing";
              });
              break;
            case PipAction.pause:
              // example: videoPlayerController.pause();
              setState(() {
                isPlaying = false;
                actionResponse = "Paused";
              });
              break;
            case PipAction.live:
              // example: videoPlayerController.forceLive();
              setState(() {
                actionResponse = "Go to live view";
              });
              break;
            case PipAction.next:
              // example: videoPlayerController.next();
              setState(() {
                actionResponse = "Next";
              });
              break;
            case PipAction.previous:
              // example: videoPlayerController.previous();
              setState(() {
                actionResponse = "Previous";
              });
              break;
            default:
              break;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Pip Plugin example app'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity),
              Text('Pip is ${pipAvailable ? '' : 'not '}Available'),
              const Text('Pip is not activated'),
              DropdownButton<List<int>>(
                value: aspectRatio,
                onChanged: (List<int>? newValue) {
                  if (newValue == null) return;
                  if (autoPipSwitch) {
                    pip.setAutoPipMode(
                      aspectRatio: newValue,
                      seamlessResize: true,
                    );
                  }
                  setState(() {
                    aspectRatio = newValue;
                  });
                },
                items: aspectRatios
                    .map<DropdownMenuItem<List<int>>>(
                      (List<int> value) => DropdownMenuItem<List<int>>(
                        child: Text('${value.first} : ${value.last}'),
                        value: value,
                      ),
                    )
                    .toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Auto Enter (Android S): '),
                  Switch(
                    value: autoPipSwitch,
                    onChanged: autoPipAvailable
                        ? (newValue) {
                            setState(() {
                              autoPipSwitch = newValue;
                            });
                          }
                        : null,
                  ),
                ],
              ),
              IconButton(
                onPressed: pipAvailable
                    ? () => pip.enterPipMode(
                          aspectRatio: aspectRatio,
                        )
                    : null,
                icon: const Icon(Icons.picture_in_picture),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(
                  thickness: 1,
                ),
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
                      onChanged: (PipActionsLayout? newValue) {
                        if (newValue == null) return;
                        pip.setPipActionsLayout(newValue);
                        pip.setIsPlaying(true);
                        setState(() {
                          isPlaying = true;
                          pipActionsLayout = newValue;
                        });
                      },
                      items: layoutList(),
                    ),
                  ],
                ),
              ),
              pipActionsLayout != PipActionsLayout.none
                  ? Column(
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
                                  icon: Icon(
                                      isPlaying ? Icons.pause : Icons.play_arrow))
                            ],
                          ),
                      ),
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("Obs.: Tap the simulated player button to see the PIP actions be updated on PIP mode, when you tap PIP actions on PIP mode it will reflect here too"),
                        )
                    ],
                  )
                  : Container(),
            ],
          ),
        ),
        // pip builder is null so pip child is used when in pip mode
        pipChild: Scaffold(
          appBar: AppBar(
            title: const Text('Pip Mode'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity),
              const Text('Pip activated'),
              pipActionsLayout != PipActionsLayout.none
                  ? IconButton(
                      onPressed: () {
                        bool newValue = !isPlaying;
                        pip.setIsPlaying(newValue);
                        setState(() {
                          isPlaying = newValue;
                        });
                      },
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow))
                  : Container(),
              pipActionsLayout != PipActionsLayout.none
                  ? Text(actionResponse)
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
