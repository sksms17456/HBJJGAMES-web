/// Game mode selection.
enum GameMode {
  /// Timed 1-50 mode — tap numbers 1 through 50 as fast as possible.
  basic,

  /// Survival mode — keep tapping before time runs out, looping at 999.
  infinite,
}

/// High-level phase of a game session.
enum GamePhase {
  /// Waiting to start (pre-countdown or initial state).
  ready,

  /// Actively playing.
  playing,

  /// Paused (e.g. app went to background).
  paused,

  /// Game completed or time ran out.
  finished,
}

/// Visual state of an individual number card on the board.
enum CardState {
  /// Front number is visible.
  faceUp,

  /// Card is mid-flip animation.
  flipping,

  /// Back number is visible (front was cleared).
  faceDown,
}
