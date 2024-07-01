import '../../open_chessboard_driver.dart';

/// Short: dest
/// Standard: dest + check square
/// Long: src + dest + check
enum LedStyle {
  short, standard, long
}

class LedStyleConfig {
  final LedStyle style;

  LedStyleConfig({this.style = LedStyle.standard});

  static List<String> getCommitSquares(LedStyle style, BoardAppMove move) {
    final List<String> squares = [];
    final checkSquare = move.checkSquare;

    if (style == LedStyle.long) {
      squares.add(move.from);
    }

    squares.add(move.to);

    if (checkSquare != null && (style == LedStyle.standard || style == LedStyle.long)) {
      squares.add(checkSquare);
    }
    return squares;
  }

  static List<String> getAppMoveSquares(LedStyle style, BoardAppMove move) {
    final List<String> squares = [];
    final checkSquare = move.checkSquare;

    squares.add(move.from);
    squares.add(move.to);

    if (checkSquare != null && (style == LedStyle.standard || style == LedStyle.long)) {
      squares.add(checkSquare);
    }
    return squares;
  }
}