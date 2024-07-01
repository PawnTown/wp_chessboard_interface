import '../../squareoff_driver.dart';
import '../answer.dart';
import '../command.dart';

class GetBoard extends Command<Map<String, bool>> {
  GetBoard() : super("30", "R", BoardStateMessage());
}

class BoardStateMessage extends Answer<Map<String, bool>> {
  BoardStateMessage(): super("30");

  @override
  Map<String, bool> process(String msg) {
    List<bool> rawBoard = msg.split("#")[1].split("").map((e) => e == "1").toList();
    Map<String, bool> board = {};
    for (var i = 0; i < SquareoffDriver.squares.length; i++) {
      board[SquareoffDriver.squares[i]] = rawBoard[i];
    }
    return board;
  }
}