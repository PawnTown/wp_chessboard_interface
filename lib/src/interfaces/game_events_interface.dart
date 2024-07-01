import "../models/game_end_state.dart";
import "../models/board_app_move.dart";

abstract interface class GameEventsInterface {
    Future<void> gameEnded(GameEndState state);
    Future<void> setMove(BoardAppMove move);
    Future<void> setPosition(String fen);
}