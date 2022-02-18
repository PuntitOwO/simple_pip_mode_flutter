[![Pub page](https://img.shields.io/badge/pub-simple__pip__mode__flutter-brightgreen)](https://pub.dev/packages/simple_pip_mode)
[![License](https://img.shields.io/github/license/PuntitOwO/simple_pip_mode_flutter)](https://github.com/PuntitOwO/simple_pip_mode_flutter/blob/main/LICENSE)

A complete Picture-In-Picture mode plugin for android API level 26+ (Android Oreo).

Provides methods to check feature availability, enter PIP mode and callbacks.

![pip_example](https://user-images.githubusercontent.com/69210614/154329387-bd90ce0b-d563-4173-b2d0-2cbcc62b670c.gif)

# Features

* Verify PIP system availability and current state.
* Method to enter PIP mode, with aspect ratio, auto enter and seamless resize parameters.
* On PIP mode change Callbacks.
* Widget to build PIP-dependent layouts.

# Installation

In the `dependencies:` section of your `pubspec.yaml`, add the following line:
```
  simple_pip_mode: <latest_version>
```

# Usage

This section has example code for the following tasks:
* [Update manifest](#update-manifest)
* [Verify PIP support](#verify-pip-support)
* [Entering PIP mode](#entering-pip-mode)
* [Enabling callbacks](#enabling-callbacks)
* [Using callbacks](#using-callbacks)
* [Using the PIP Widget](#using-the-pip-widget)

## Update manifest

Add `android:supportsPictureInPicture="true"` to the activity on your `AndroidManifest.xml`.

## Verify pip support

Use `SimplePip.isPipAvailable` and `SimplePip.isPipActivated` static getters to verify whether the device supports Picture In Picture feature and the feature is currently activated respectively.

## Entering pip mode

Import `simple_pip.dart` file and call `enterPipMode` method.

```dart
import 'package:simple_pip_mode/simple_pip.dart';

class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.picture_in_picture),
      onPressed: () => SimplePip().enterPipMode(),
    );
  }
}
```

## Enabling callbacks

There's two ways of enabling callbacks:
* [Activity wrapper](#activity-wrapper) (New in 0.6.0!)
* [Callback helper](#callback-helper)

### Activity wrapper 

This is the easiest way to enable the callbacks.

Just import the wrapper class in your main activity file, and inherit from it.

#### Kotlin
```kotlin
import cl.puntito.simple_pip_mode.PipCallbackHelperActivityWrapper

class MainActivity: PipCallbackHelperActivityWrapper() {
}
```
#### Java
```java
import cl.puntito.simple_pip_mode.PipCallbackHelperActivityWrapper;

class MainActivity extends PipCallbackHelperActivityWrapper {
}
```
Done! now you can use PIP callbacks and the PIP widget.

### Callback helper

If something went wrong with [Activity wrapper](#activity-wrapper) or you don't want to wrap your activity,
you can enable callbacks using the callback helper.

To do so, in your main activity file import the callback helper.
```kotlin
import cl.puntito.simple_pip_mode.PipCallbackHelper
```
Instance a callback helper, provide the flutter engine to it, and finally, call helper on callback.

#### Kotlin
```kotlin
class MainActivity: FlutterActivity() {
  //...
  private var callbackHelper = PipCallbackHelper()
  //...
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    callbackHelper.configureFlutterEngine(flutterEngine)
  }
  
  override fun onPictureInPictureModeChanged(active: Boolean, newConfig: Configuration?) {
    callbackHelper.onPictureInPictureModeChanged(active)
  }
  //...
}
```
#### Java
```java
public class MainActivity extends FlutterActivity {
    //...
    private final PipCallbackHelper callbackHelper = new PipCallbackHelper();
    //...
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        callbackHelper.configureFlutterEngine(flutterEngine);
    }
    
    @Override
    public void onPictureInPictureModeChanged(boolean active, Configuration newConfig) {
        callbackHelper.onPictureInPictureModeChanged(active);
    }
    //...
}
```
Done! now you can use PIP callbacks and the PIP widget.

## Using callbacks

To use callbacks, just pass them as parameters to `SimplePip` constructor.
```dart
SimplePip _pip = SimplePip(
  onPipEntered: () => doSomething(),
  onPipExited: () => doSomeOtherThing(),
);
```

## Using the PIP widget

To use the widget, you need to [enable callbacks](#enabling-callbacks) first.
Import `pip_widget.dart` file. 

Add a `PipWidget` widget to your tree and give it a `builder` or a `child`, and a `pipBuilder` or a `pipChild`.
```dart
import 'package:simple_pip_mode/pip_widget.dart';
class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return PipWidget(
      builder: (context) => Text('This is built when PIP mode is not active'),
      child: Text('This widget is not used because builder is not null'),
      //pipBuilder: (context) => Text('This is built when PIP mode is active'),
      pipChild: Text('This widget is used because pipBuilder is null'),
    );
  }
}
```
You can also pass callbacks directly to `PipWidget`.

# Notes

## Multi-platform apps

Every `SimplePip` method calls android native code, so make sure you only make a call to a `SimplePip` method when running in an Android device.
This includes `SimplePip.isPipAvailable`.

Calling `SimplePip` methods on a non-Android device will raise a `MissingPluginException` error.

# Contribute

I'm currently working on more features, so issues and pull requests are appreciated!
