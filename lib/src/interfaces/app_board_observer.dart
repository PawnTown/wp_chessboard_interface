import "package:open_chessboard_driver/open_chessboard_driver.dart";
import "../utils.dart";

abstract interface class AppBoardObserver {
    Stream<AppBoardState> get appBoardStream;
    AppBoardState get appBoard;
    
    Future<void> updateAppBoard(AppBoardState boardMap);
}

class AppBoardState {
  final Map<String, BoardPiece?> board;
  final GamePlayerColor turn;
  final CastelingRights castelingOptions;
  final bool enPassant;
  final int halfMove;
  final int fullMove;

  AppBoardState({
    required this.board,
    this.turn = GamePlayerColor.white,
    this.castelingOptions = const CastelingRights(false, false, false, false),
    this.enPassant = false,
    this.halfMove = 0,
    this.fullMove = 1,
  });

  AppBoardState copyWith({
    Map<String, BoardPiece?>? board,
    GamePlayerColor? turn,
    CastelingRights? castelingOptions,
    bool? enPassant,
    int? halfMove,
    int? fullMove,
  }) {
    return AppBoardState(
      board: board ?? this.board,
      turn: turn ?? this.turn,
      castelingOptions: castelingOptions ?? this.castelingOptions,
      enPassant: enPassant ?? this.enPassant,
      halfMove: halfMove ?? this.halfMove,
      fullMove: fullMove ?? this.fullMove,
    );
  }

  String get fen {
    String fenString = Utils.boardMapToFen(board);
    fenString += " ${turn == GamePlayerColor.white ? "w" : "b"}";
    fenString += " ${castelingOptions.whiteKingSide ? "K" : ""}${castelingOptions.whiteQueenSide ? "Q" : ""}${castelingOptions.blackKingSide ? "k" : ""}${castelingOptions.blackQueenSide ? "q" : ""}";
    fenString += " ${enPassant ? "e" : "-"}";
    fenString += " $halfMove";
    fenString += " $fullMove";
    return fenString;
  }

  AppBoardState.fromFen(String fen): 
    board = Utils.fenToBoardMap(fen),
    turn = Utils.fenTurn(fen),
    castelingOptions = Utils.fenCastelingRights(fen),
    enPassant = Utils.fenEnPassant(fen),
    halfMove = Utils.fenHalfMove(fen),
    fullMove = Utils.fenFullMove(fen);
}