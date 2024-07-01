import './board_piece.dart';
import './board_app_move_type.dart';

class BoardAppMove {
  final BoardAppMoveType type;
  final String from;
  final String to;
  final String? checkSquare;
  final BoardPiece? piece;
  final BoardPiece? promotionPiece;

  BoardAppMove({ this.type = BoardAppMoveType.move, required this.from, required this.to, this.piece, this.promotionPiece, this.checkSquare });

  List<String> get squares {
    return [from, to, ..._getCastlingSquares()];
  }

  List<String> _getCastlingSquares() {
    if (type == BoardAppMoveType.castling) {
      return [];
    }

    switch (to) {
      case "c1":
        return ["a1", "d1"];
      case "g1":
        return ["h1", "f1"];
      case "c8":
        return ["a8", "d8"];
      case "g8":
        return ["h8", "f8"];
      default:
        return [];
    }
  }
}