import 'package:open_chessboard_driver/src/update_transformer.dart';

import '../../open_chessboard_driver.dart';

class DuplicateFilterTransformer extends UpdateTransformer {
  String lastFen = "";

  @override
  BoardUpdate? transform(Chessboard sender, BoardUpdate update) {
    /*final updateFen = update.board.fen;
    if (updateFen == lastFen) {
      return null;
    }
    lastFen = updateFen;*/
    if (!update.force && !update.hasChanged()) {
      return null;
    }
    return update;
  }
}