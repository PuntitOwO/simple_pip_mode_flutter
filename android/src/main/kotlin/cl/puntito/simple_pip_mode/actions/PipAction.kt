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
    private val title: String,
    private val description: String,
    private val afterAction: String? = null,
) {
    PLAY(R.drawable.ic_baseline_play_arrow_24, "Play", "Play media", "PAUSE"),
    PAUSE(R.drawable.ic_baseline_pause_24, "Pause", "Pause media", "PLAY"),
    NEXT(R.drawable.ic_baseline_skip_next_24, "Next", "Skip to next media"),
    PREVIOUS(R.drawable.ic_baseline_skip_previous_24, "Previous", "Back to previous media"),
    LIVE(R.drawable.ic_surround_sound_24, "Live", "Go to live");

    @RequiresApi(Build.VERSION_CODES.O)
    fun toRemoteAction(context: Context) : RemoteAction = RemoteAction(
        Icon.createWithResource(context, icon),
        title,
        description,
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