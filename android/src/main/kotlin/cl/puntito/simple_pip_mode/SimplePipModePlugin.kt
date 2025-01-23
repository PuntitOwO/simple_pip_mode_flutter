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
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler


/** PIP_METHODS enum */
enum class PIP_METHODS(val methodName: String) {
    GET_PLATFORM_VERSION("getPlatformVersion"),
    IS_PIP_AVAILABLE("isPipAvailable"),
    IS_PIP_ACTIVATED("isPipActivated"),
    IS_AUTO_PIP_AVAILABLE("isAutoPipAvailable"),
    ENTER_PIP_MODE("enterPipMode"),
    SET_PIP_LAYOUT("setPipLayout"),
    SET_IS_PLAYING("setIsPlaying"),
    SET_AUTO_PIP_MODE("setAutoPipMode"),
}

/** SimplePipModePlugin */
class SimplePipModePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

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

        ContextCompat.registerReceiver(
            context,
            broadcastReceiver,
            IntentFilter(SIMPLE_PIP_ACTION),
            RECEIVER_EXPORTED
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context.unregisterReceiver(broadcastReceiver)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            PIP_METHODS.GET_PLATFORM_VERSION.methodName -> getPlatformVersion(result)
            PIP_METHODS.IS_PIP_AVAILABLE.methodName -> isPipAvailable(result)
            PIP_METHODS.IS_PIP_ACTIVATED.methodName -> isPipActivated(result)
            PIP_METHODS.IS_AUTO_PIP_AVAILABLE.methodName -> isAutoPipAvailable(result)
            PIP_METHODS.ENTER_PIP_MODE.methodName -> enterPipMode(call, result)
            PIP_METHODS.SET_PIP_LAYOUT.methodName -> setPipLayout(call, result)
            PIP_METHODS.SET_IS_PLAYING.methodName -> setIsPlaying(call, result)
            PIP_METHODS.SET_AUTO_PIP_MODE.methodName -> setAutoPipMode(call, result)
            else -> result.notImplemented()
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

    /* METHOD IMPLEMENTATION */

    private fun getPlatformVersion(result: MethodChannel.Result) {
        result.success("Android ${Build.VERSION.RELEASE}")
    }

    private fun isPipAvailable(result: MethodChannel.Result) {
        result.success(
            activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)
        )
    }

    private fun isPipActivated(result: MethodChannel.Result) {
        result.success(activity.isInPictureInPictureMode)
    }

    private fun isAutoPipAvailable(result: MethodChannel.Result) {
        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
    }

    private fun enterPipMode(call: MethodCall, result: MethodChannel.Result) {
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
    }

    private fun setPipLayout(call: MethodCall, result: MethodChannel.Result) {
        val success = call.argument<String>("layout")?.let {
            try {
                Log.i("PIP", "layout = ${convertAction(it)}")
                actionsLayout = PipActionsLayout.valueOf(convertAction(it))
                actions = actionsLayout.remoteActions(context)
                true
            } catch (e: Exception) {
                Log.e("PIP", e.message?: "Error setting layout")
                false
            }
        } ?: false
        result.success(success)
    }

    private fun setIsPlaying(call: MethodCall, result: MethodChannel.Result) {
        call.argument<Boolean>("isPlaying")?.let { isPlaying ->
            if (actionsLayout.actions.contains(PipAction.PLAY) ||
                actionsLayout.actions.contains(PipAction.PAUSE)
            ) {
                var i = actionsLayout.actions.indexOf(PipAction.PLAY)
                if (i == -1) {
                    i = actionsLayout.actions.indexOf(PipAction.PAUSE)
                }
                if (i >= 0) {
                    actionsLayout.actions[i] =
                        if (isPlaying) PipAction.PAUSE else PipAction.PLAY
                    renderPipActions()
                    result.success(true)
                }
            } else {
                result.success(false)
            }
        } ?: result.success(false)
    }

    private fun setAutoPipMode(call: MethodCall, result: MethodChannel.Result) {
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
            result.error(
                "NotImplemented",
                "System Version less than Android S found",
                "Expected Android S or newer."
            )
        }
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

    private fun convertAction(action: String) = action
        .replace(Regex("([a-z])([A-Z])"), "$1_$2")
        .replace(Regex("([a-z])([0-9])"), "$1_$2")
        .uppercase()
}
