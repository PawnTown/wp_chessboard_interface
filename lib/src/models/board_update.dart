import 'package:open_chessboard_driver/src/models/board_position.dart';
import 'package:open_chessboard_driver/src/utils.dart';

import '../constants.dart';
import './board_piece.dart';
import './square_update.dart';
import './square_update_type.dart';

class BoardUpdate {
  final BoardPosition board;
  final BoardPosition prevBoard;
  final bool isReversed;
  final bool force;

  BoardUpdate(Map<String, BoardPiece?> board, Map<String, BoardPiece?> prevBoard, {this.isReversed = false, this.force = false})
    : board = BoardPosition(board), prevBoard = BoardPosition(prevBoard);

  bool hasChanged() {
    for (var square in Constants.squares) {
      if (board.map[square] != prevBoard.map[square]) {
        return true;
      }
    }
    return false;
  }

  List<SquareUpdate> squareUpdates() {
    List<SquareUpdate> result = [];
    for (var square in board.map.keys) {
      final piece = board.map[square];
      final prevPiece = prevBoard.map[square];
      if (!BoardPiece.equal(piece, prevPiece)) {
        if (piece == null && prevPiece != null) {
          result.add(SquareUpdate(square, prevPiece, SquareUpdateType.pickUp));
          continue;
        } else if (piece != null && prevPiece == null) {
          result.add(SquareUpdate(square, piece, SquareUpdateType.setDown));
          continue;
        } else if (piece != null && prevPiece != null) {
          result.add(SquareUpdate(square, prevPiece, SquareUpdateType.pickUp));
          result.add(SquareUpdate(square, piece, SquareUpdateType.setDown));
          continue;
        }
      }
    }
    return result;
  }

  BoardUpdate copyReversed() {
    return BoardUpdate(_reversedBoard(board.map), prevBoard.map, isReversed: true);
  }

  BoardUpdate copyWithBoardMap(Map<String, BoardPiece?> board) {
    return BoardUpdate(board, prevBoard.map, isReversed: isReversed);
  }

  Map<String, BoardPiece?> _reversedBoard(Map<String, BoardPiece?> boardState) {
    Map<String, BoardPiece?> mapped = {};
    for (var square in boardState.keys) {
      mapped[Utils.inverseSquare(square)] = boardState[square];
    }
    return mapped;
  }
}