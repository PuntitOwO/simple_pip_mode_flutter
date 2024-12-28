package cl.puntito.simple_pip_mode.actions

import android.app.RemoteAction
import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi

enum class PipActionsLayout(
    var actions: MutableList<PipAction>,
) {
    NONE(mutableListOf()),
    MEDIA(mutableListOf(PipAction.PREVIOUS, PipAction.PAUSE, PipAction.NEXT)),
    MEDIA_ONLY_PAUSE(mutableListOf(PipAction.PAUSE)),
    MEDIA_LIVE(mutableListOf(PipAction.LIVE, PipAction.PAUSE)),
    MEDIA_WITH_SEEK_10(mutableListOf(PipAction.REWIND,PipAction.PAUSE, PipAction.FORWARD));

    @RequiresApi(Build.VERSION_CODES.O)
    fun remoteActions(context: Context): MutableList<RemoteAction> =
        remoteActions(context, actions)

    @RequiresApi(Build.VERSION_CODES.O)
    fun toggleToAfterAction(pipAction: PipAction) {
        pipAction.afterAction()?.let { afterAction ->
            val a = actions.firstOrNull{ it == pipAction }
            a?.let {
                val i = actions.indexOf(a)
                actions[i] = afterAction
            }
        }
    }

    companion object {

        @RequiresApi(Build.VERSION_CODES.O)
        fun remoteActions(context: Context, actions: MutableList<PipAction>): MutableList<RemoteAction> =
            actions.map { a -> a.toRemoteAction(context) }.toMutableList()

    }
}