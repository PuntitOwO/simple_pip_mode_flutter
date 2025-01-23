/// PIP Actions Layout preset
///
/// This layouts are defined on a ENUM inside Android src, where is
/// specified the actions each layout should show.
///
///
/// [none] do not show any actions on PIP mode
/// [media] shows `previous`, `pause/play`, `next` actions (on this specific order)
/// [mediaOnlyPause] shows only `pause/play` action
/// [mediaLive] shows `live` and `pause/play` actions (on this specific order)
/// [mediaWithSeek10] shows `previous`, `pause/play`, `next`, `seek10` actions (on this specific order)
enum PipActionsLayout {
  none,
  media,
  mediaOnlyPause,
  mediaLive,
  mediaWithSeek10,
}

// TODO(PuntitOwO): Implement generic layouts on runtime, so plugin users can create theirs own layouts without needing to update this preset
