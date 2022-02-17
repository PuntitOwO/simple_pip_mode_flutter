import 'package:flutter/material.dart';
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
  late SimplePip pip;

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
    setState(() {
      pipAvailable = isAvailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Pip widget can build different widgets for each mode
      home: PipWidget(
        // builder is null so child is used when not in pip mode
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
              IconButton(
                onPressed: pipAvailable
                    ? () => pip.enterPipMode(
                          aspectRatio: aspectRatio,
                        )
                    : null,
                icon: const Icon(Icons.picture_in_picture),
              ),
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
            children: const [
              SizedBox(width: double.infinity),
              Text('Pip activated'),
            ],
          ),
        ),
      ),
    );
  }
}
