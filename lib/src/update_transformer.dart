import 'package:open_chessboard_driver/open_chessboard_driver.dart';

abstract class UpdateTransformer {
  BoardUpdate? transform(Chessboard sender, BoardUpdate update);
}