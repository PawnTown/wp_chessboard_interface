import '../../open_chessboard_driver.dart';
import '../utils.dart';

class BoardPosition {
  final Map<String, BoardPiece?> map;

  BoardPosition(this.map);

  String get fen {
    return Utils.boardMapToFen(map);
  }
}