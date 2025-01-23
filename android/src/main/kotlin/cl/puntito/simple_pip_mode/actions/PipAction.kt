package cl.puntito.simple_pip_mode.actions

import android.app.PendingIntent
import android.app.RemoteAction
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import androidx.annotation.RequiresApi
import cl.puntito.simple_pip_mode.Constants.EXTRA_ACTION_TYPE
import cl.puntito.simple_pip_mode.Constants.SIMPLE_PIP_ACTION
import cl.puntito.simple_pip_mode.R

enum class PipAction(
    private val icon: Int,
    private val title: Int,
    private val description: Int,
    private val afterAction: String? = null,
) {
    PLAY(R.drawable.ic_baseline_play_arrow_24, R.string.pip_action_play, R.string.pip_action_play_description, "PAUSE"),
    PAUSE(R.drawable.ic_baseline_pause_24, R.string.pip_action_pause, R.string.pip_action_pause_description, "PLAY"),
    NEXT(R.drawable.ic_baseline_skip_next_24, R.string.pip_action_next, R.string.pip_action_next_description),
    PREVIOUS(R.drawable.ic_baseline_skip_previous_24, R.string.pip_action_previous, R.string.pip_action_previous_description),
    LIVE(R.drawable.ic_surround_sound_24, R.string.pip_action_live, R.string.pip_action_live_description,),
    REWIND(R.drawable.ic_baseline_replay_10_24, R.string.pip_action_rewind_10, R.string.pip_action_rewind_10_description),
    FORWARD(R.drawable.ic_baseline_forward_10_24, R.string.pip_action_forward_10, R.string.pip_action_forward_10_description);

    @RequiresApi(Build.VERSION_CODES.O)
    fun toRemoteAction(context: Context) : RemoteAction = RemoteAction(
        Icon.createWithResource(context, icon),
        context.getString(title),
        context.getString(description),
        PendingIntent.getBroadcast(
            context, ordinal,
            Intent(SIMPLE_PIP_ACTION).putExtra(EXTRA_ACTION_TYPE, name),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    )

    fun afterAction() : PipAction? {
        return afterAction?.let {
            valueOf(it)
        }
    }
}