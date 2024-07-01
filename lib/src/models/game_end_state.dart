import 'game_ending.dart';
import 'game_player_color.dart';

class GameEndState {
  final GamePlayerColor winner;
  final GameEnding type;

  GameEndState(this.winner, this.type);
}