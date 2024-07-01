enum GameEvent {
  kingInCheck, blackWins, whiteWins, draw
}

// GameEvent to string
extension GameEventToString on GameEvent {
  String toShortString() {
    switch (this) {
      case GameEvent.kingInCheck:
        return "ck";
      case GameEvent.blackWins:
        return "bl";
      case GameEvent.whiteWins:
        return "wt";
      case GameEvent.draw:
        return "dw";
      default:
        return "";
    }
  }
}