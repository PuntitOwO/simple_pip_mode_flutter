package cl.puntito.simple_pip_mode

import android.app.Activity
import android.app.PictureInPictureParams
import android.app.RemoteAction
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.util.Rational
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.RECEIVER_EXPORTED
import cl.puntito.simple_pip_mode.Constants.EXTRA_ACTION_TYPE
import cl.puntito.simple_pip_mode.Constants.SIMPLE_PIP_ACTION
import cl.puntito.simple_pip_mode.actions.PipAction
import cl.puntito.simple_pip_mode.actions.PipActionsLayout
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler


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
  private var actions: MutableList<RemoteAction> = mutableListOf()
  private var actionsLayout: PipActionsLayout = PipActionsLayout.NONE

  private var callbackHelper = PipCallbackHelper()
  private var params: PictureInPictureParams.Builder? = null
  private lateinit var broadcastReceiver: BroadcastReceiver

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
    callbackHelper.setChannel(channel)
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    broadcastReceiver = object : BroadcastReceiver() {
      @RequiresApi(Build.VERSION_CODES.O)
      override fun onReceive(context: Context, intent: Intent) {
        if (SIMPLE_PIP_ACTION !== intent.action) {
          return
        }
        intent.getStringExtra(EXTRA_ACTION_TYPE)?.let {
          val action = PipAction.valueOf(it)
          action.afterAction()?.let {
            toggleAction(action)
          }
          callbackHelper.onPipAction(action)
        }
      }
    }.also { broadcastReceiver = it }

    ContextCompat.registerReceiver(context, broadcastReceiver, IntentFilter(SIMPLE_PIP_ACTION), RECEIVER_EXPORTED)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    context.unregisterReceiver(broadcastReceiver)
  }

  @RequiresApi(Build.VERSION_CODES.O)
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${Build.VERSION.RELEASE}")
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
      var params = PictureInPictureParams.Builder()
              .setAspectRatio(Rational(aspectRatio!![0], aspectRatio[1]))
              .setActions(actions)

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        params = params.setAutoEnterEnabled(autoEnter!!)
                .setSeamlessResizeEnabled(seamlessResize!!)
      }

      this.params = params

      result.success(
              activity.enterPictureInPictureMode(params.build())
      )
    } else if (call.method == "setPipLayout") {
      val success = call.argument<String>("layout")?.let {
        try {
          actionsLayout = PipActionsLayout.valueOf(it.uppercase().replace("_", ""))
          actions = actionsLayout.remoteActions(context)
          true
        } catch(e: Exception) {
          false
        }
      } ?: false
      result.success(success)
    } else if (call.method == "setIsPlaying") {
      call.argument<Boolean>("isPlaying")?.let { isPlaying ->
        if (actionsLayout.actions.contains(PipAction.PLAY) ||
                actionsLayout.actions.contains(PipAction.PAUSE)) {
          var i = actionsLayout.actions.indexOf(PipAction.PLAY)
          if (i == -1) {
            i = actionsLayout.actions.indexOf(PipAction.PAUSE)
          }
          if( i >= 0) {
            actionsLayout.actions[i] = if(isPlaying) PipAction.PAUSE else PipAction.PLAY
            renderPipActions()
            result.success(true)
          }
        } else {
          result.success(false)
        }
      } ?: result.success(false)
    } else if (call.method == "setAutoPipMode") {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val aspectRatio = call.argument<List<Int>>("aspectRatio")
        val autoEnter = call.argument<Boolean>("autoEnter")
        val seamlessResize = call.argument<Boolean>("seamlessResize")
        val params = PictureInPictureParams.Builder()
          .setAspectRatio(Rational(aspectRatio!![0], aspectRatio[1]))
          .setAutoEnterEnabled(autoEnter!!)
          .setSeamlessResizeEnabled(seamlessResize!!)
          .setActions(actions)

        this.params = params

        activity.setPictureInPictureParams(params.build())

        result.success(true)
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

  @RequiresApi(Build.VERSION_CODES.O)
  private fun toggleAction(action: PipAction) {
    actionsLayout.toggleToAfterAction(action)
    renderPipActions()
  }

  @RequiresApi(Build.VERSION_CODES.O)
  private fun renderPipActions() {
    actions = PipActionsLayout.remoteActions(context, actionsLayout.actions)
    params?.let {
      it.setActions(actions).build()
      activity.setPictureInPictureParams(it.build())
    }
  }
}
