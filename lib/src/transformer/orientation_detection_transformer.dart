import 'package:open_chessboard_driver/src/update_transformer.dart';

import '../../open_chessboard_driver.dart';
import '../constants.dart';

class OrientationDetectionTransformer extends UpdateTransformer {
  static final List<String> firstTwoRows = Constants.squares.where((e) => e.substring(1, 2) == "1" || e.substring(1, 2) == "2").toList();
  static final List<String> lastTwoRows = Constants.squares.where((e) => e.substring(1, 2) == "7" || e.substring(1, 2) == "8").toList();
  BoardPieceColor orientation = BoardPieceColor.white;

  @override
  BoardUpdate transform(Chessboard sender, BoardUpdate update) {
    final startPosOfColor = isColorStartPos(update.board.map);
    if (startPosOfColor != null) {
      orientation = startPosOfColor;
    }

    if (orientation == BoardPieceColor.black) {
      return update.copyReversed();
    }
    return update;
  }

  // Only checks if first two rows and last two rows occoupied by same color
  BoardPieceColor? isColorStartPos(Map<String, BoardPiece?> state) {
    int blackInFirstLines = firstTwoRows.where((e) => state[e]?.color == BoardPieceColor.black).length;
    int whiteInLastLines = lastTwoRows.where((e) => state[e]?.color == BoardPieceColor.white).length;

    if (whiteInLastLines == 16 && blackInFirstLines == 16) {
      return BoardPieceColor.black;
    }

    int whiteInFirstLines = firstTwoRows.where((e) => state[e]?.color == BoardPieceColor.white).length;
    int blackInLastLines = lastTwoRows.where((e) => state[e]?.color == BoardPieceColor.black).length;

    if (whiteInFirstLines == 16 && blackInLastLines == 16) {
      return BoardPieceColor.white;
    }

    return null;
  }
}