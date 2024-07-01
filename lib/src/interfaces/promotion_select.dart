import "package:open_chessboard_driver/src/models/board_piece.dart";

abstract interface class PromotionSelect {
    Stream<BoardPiece> get promotionSelectionStream;
}