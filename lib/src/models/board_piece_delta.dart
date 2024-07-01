import './board_piece.dart';

enum BoardPieceDeltaAction {
  pieceMissing, pieceNeedsRemoval
}

class BoardPieceDelta {
  final String square;
  final BoardPiece piece;
  final BoardPieceDeltaAction action;

  BoardPieceDelta(this.square, this.piece, this.action);
}