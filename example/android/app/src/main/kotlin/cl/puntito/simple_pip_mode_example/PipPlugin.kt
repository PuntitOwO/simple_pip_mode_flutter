package cl.puntito.simple_pip_mode_example

import android.content.res.Configuration
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
// Import the callback helper
import cl.puntito.simple_pip_mode.PipCallbackHelper

class PipPlugin: FlutterActivity() {
  // Instance a callback helper to make use of PIP callbacks
  private var callbackHelper = PipCallbackHelper()

  // Provide Flutter Engine object to the helper
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    callbackHelper.configureFlutterEngine(flutterEngine)
  }

  // Call this method to make calls to flutter app
  override fun onPictureInPictureModeChanged(active: Boolean, newConfig: Configuration?) {
    callbackHelper.onPictureInPictureModeChanged(active)
  }
}
