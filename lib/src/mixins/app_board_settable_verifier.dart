import '../../open_chessboard_driver.dart';

mixin AppBoardSettableVerifier<T> on Chessboard<T> {
  bool Function (BoardPosition boardMap)? _verifyAppBoard;

  setAppBoardVerifier(bool Function (BoardPosition boardMap) verifier) {
    _verifyAppBoard = verifier;
  }
  
  bool verifyAppBoard(BoardPosition boardMap) {
    final verifier = _verifyAppBoard;
    if (verifier != null) {
      return verifier(boardMap);
    }
    return true;
  }
}