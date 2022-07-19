package cl.puntito.simple_pip_mode

import android.app.Activity
import android.app.PictureInPictureParams
import android.content.Context
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Build
import android.util.Rational
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.sql.DriverManager.println

/** SimplePipModePlugin */
class SimplePipModePlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private val CHANNEL = "puntito.simple_pip_mode"
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private lateinit var activity: Activity

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  @RequiresApi(Build.VERSION_CODES.O)
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "isPipAvailable") {
      result.success(
          activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)
      )
    } else if (call.method == "isPipActivated") {
      result.success(activity.isInPictureInPictureMode)
    } else if (call.method == "isAutoPipAvailable") {
      result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
    } else if (call.method == "enterPipMode") {
      val aspectRatio = call.argument<List<Int>>("aspectRatio")
      val autoEnter = call.argument<Boolean>("autoEnter")
      val seamlessResize = call.argument<Boolean>("seamlessResize")
      // TODO(add actions)
      var params = PictureInPictureParams.Builder()
          .setAspectRatio(Rational(aspectRatio!![0], aspectRatio[1]))

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        params = params.setAutoEnterEnabled(autoEnter!!)
            .setSeamlessResizeEnabled(seamlessResize!!)
      }

      result.success(
          activity.enterPictureInPictureMode(params.build())
      )
    } else if (call.method == "setAutoPipMode") {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val aspectRatio = call.argument<List<Int>>("aspectRatio")
        val autoEnter = call.argument<Boolean>("autoEnter")
        val seamlessResize = call.argument<Boolean>("seamlessResize")
        // TODO(add actions)
        var params = PictureInPictureParams.Builder()
            .setAspectRatio(Rational(aspectRatio!![0], aspectRatio[1]))
            .setAutoEnterEnabled(autoEnter!!)
            .setSeamlessResizeEnabled(seamlessResize!!)

        result.success(
            activity.setPictureInPictureParams(params.build())
        )
      } else {
        result.error("NotImplemented", "System Version less than Android S found", "Expected Android S or newer.")
      }
    } else {
      result.notImplemented()
    }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
  }

}
