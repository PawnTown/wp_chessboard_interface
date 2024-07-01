import 'chessboard.dart';

import 'drivers/squareoff/squareoffdriver.dart';
import 'chessboards/squareoff_chessboard.dart';
export 'drivers/squareoff/driver/models/squareoff_args.dart';

abstract class ChessboardConnectionFactory {

  static Future<Chessboard<SquareoffDriver>> connectToSquareoffBoard(SquareoffArgs args, { Duration timeout = const Duration(seconds: 10) }) async {
    final driver = SquareoffDriver(args);
    await driver.initStateStream.firstWhere((e) => e == DriverInitState.initialized).timeout(timeout);

    return SquareoffChessboard(driver);
  }

}
