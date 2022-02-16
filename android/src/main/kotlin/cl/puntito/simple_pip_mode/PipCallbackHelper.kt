package cl.puntito.simple_pip_mode

import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine


open class PipCallbackHelper {
  private val CHANNEL = "puntito.simple_pip_mode"
  private lateinit var channel: MethodChannel

  fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
  }

  fun onPictureInPictureModeChanged(active: Boolean) {
    if (active) {
      channel.invokeMethod("onPipEntered", null)
    } else {
      channel.invokeMethod("onPipExited", null)
    }
  }
}