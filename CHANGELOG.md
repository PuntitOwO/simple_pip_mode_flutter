## 1.0.0

* Android 14 support by [song011794](https://github.com/song011794): [PR #12](https://github.com/PuntitOwO/simple_pip_mode_flutter/pull/12)
* Add auto enter parameter to `setAutoPipMode` by [af-ffr](https://github.com/af-ffr): [PR #8](https://github.com/PuntitOwO/simple_pip_mode_flutter/pull/8)
* Actions code refactor to pass flutter static analysis.
* Dependencies updated.
* Clean up code.

## 0.8.0

* Pip Actions implemented by [Erick Daros](https://github.com/erickdaros): [PR #6](https://github.com/PuntitOwO/simple_pip_mode_flutter/pull/6).

## 0.7.1

* Pubspec file mini-fix

## 0.7.0

* Automatic pip method implemented for Android S.
* Bugfix: [Issue #2](https://github.com/PuntitOwO/simple_pip_mode_flutter/issues/2)

## 0.6.0

* Callback enabling process simplified:
    * Kotlin PipCallbackHelperActivityWrapper added
    * Example app updated to show the new wrapper usage
    * Readme instructions update
    
* Pip Widget parameters added:
    * child widget is used if builder is null
    * pipChild widget is used if pipBuilder is null

## 0.5.1

* Initial release bugfix:
    * README fixed
    * SDK min version fixed

## 0.5.0

* Initial development release:
    * SimplePip class added with features:
        * isPipAvailable
        * isPipActivated
        * enterPipMode
        * callbacks
    * PipWidget widget added with features:
        * builder
        * pipBuilder
        * callbacks
    * Kotlin PipCallbackHelper class added