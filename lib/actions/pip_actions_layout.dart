/// PIP Actions Layout preset
/// 
/// This layouts are defined on a ENUM inside Android src, where is 
/// specified the actions each layout should show.
/// 
/// TODO: Implement generic layouts on runtime, so plugin users can
/// create theirs own layouts without needing to update this preset
/// 
/// 
/// [none] do not show any actions on PIP mode
/// [media] shows `previous`, `pause/play`, `next` actions (on this specific order)
/// [media_only_pause] shows only `pause/play` action
/// [media_live] shows `live` and `pause/play` actions (on this specific order)
/// 
enum PipActionsLayout {
  none,
  media,
  media_only_pause,
  media_live
}