import 'package:open_chessboard_driver/src/models/square_update_type.dart';

import './board_piece.dart';

class SquareUpdate {
  final String square;
  final BoardPiece piece;
  final SquareUpdateType action;

  SquareUpdate(this.square, this.piece, this.action);

  String getNotation({bool takes = false, String from = ""}) {
    if (action == SquareUpdateType.pickUp) return "";
    return piece.notation + from + (takes ? "x" : "") + square;
  }

  @override
  String toString() {
    return "$square: ${piece.notation}${action == SquareUpdateType.pickUp ? " (Pickup)" : " (Set)"}";
  }

  static bool equals(SquareUpdate? a, SquareUpdate? b) {
    return a != null && b != null && BoardPiece.equal(a.piece, b.piece) && a.square == b.square && a.action == b.action;
  }
}