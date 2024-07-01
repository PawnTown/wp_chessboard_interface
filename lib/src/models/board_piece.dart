import './board_piece_color.dart';
import './board_piece_type.dart';

class BoardPiece {
  final String _notation;

  BoardPiece(this._notation);

  String get notation {
    return _notation;
  }

  BoardPieceColor get color {
    return _notation.toUpperCase() == _notation ? BoardPieceColor.white : BoardPieceColor.black;
  }

  BoardPieceType get type {
    switch (_notation.toLowerCase()) {
      case "n":
        return BoardPieceType.knight;
      case "b":
        return BoardPieceType.bishop;
      case "r":
        return BoardPieceType.rook;
      case "q":
        return BoardPieceType.queen;
      case "k":
        return BoardPieceType.king;
      case "p":
      default:
        return BoardPieceType.pawn;
    }
  }

  @override
  String toString() {
    return _notation;
  }

  BoardPiece clone() {
    return BoardPiece(_notation);
  }

  static bool equal(BoardPiece? a, BoardPiece? b) {
    if (a == null && b == null) return true;
    if (a == null) return false;
    if (b == null) return false;
    return a._notation == b._notation;
  }
}
