/// PIP Action preset
///
/// This actions are defined on a ENUM inside Android src, where is
/// specified each action drawable, name, description and a [afterAction]
/// that shows after the action is tap. Ex.: play's after action is pause
/// and vice-versa.
///
///
/// [play] Play action represented by triangle play icon
/// [pause] Pause action represented by double vertical bars pause icon
/// [previous] Previous action represented by previous icon
/// [next] Next action represented by next icon
/// [live] Live action (force player seeker to show latest content) represented by sorround icon
enum PipAction {
  play,
  pause,
  previous,
  next,
  live,
  rewind,
  forward,
}

// TODO(PuntitOwO): Create implement generic actions on runtime, so plugin users can create theirs own actions without needing to update this preset
