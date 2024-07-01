import "package:open_chessboard_driver/open_chessboard_driver.dart";

abstract interface class AppBoardVerifier {
  void setAppBoardVerifier(bool Function (BoardPosition boardMap) verifier);
  bool verifyAppBoard(BoardPosition boardMap);
}