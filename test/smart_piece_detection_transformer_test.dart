import 'package:open_chessboard_driver/open_chessboard_driver.dart';
import 'package:open_chessboard_driver/src/constants.dart';
import 'package:open_chessboard_driver/src/mixins/app_board_stream_controller.dart';
import 'package:open_chessboard_driver/src/models/board_metadata.dart';
import 'package:open_chessboard_driver/src/transformer/smart_piece_detection_transformer.dart';
import 'package:open_chessboard_driver/src/update_transformer.dart';
import 'package:test/test.dart';

class TestDriver {
  TestDriver();
}

class TestChessboard extends Chessboard<TestDriver> with AppBoardStreamController implements AppBoardVerifier, AppBoardObserver {
  final List<String> testVerifiedFens;

  TestChessboard(super.driver, super.metadata, {this.testVerifiedFens = const []});
  
  @override
  bool verifyAppBoard(BoardPosition update) {
    return testVerifiedFens.contains(update.fen);
  }
  
  @override
  void setAppBoardVerifier(bool Function(BoardPosition boardMap) verifier) {}
}

Map<String, BoardPiece?> createDefaultBoard() {
  return emptyBoard(Constants.defaultPieces);
}

Map<String, BoardPiece?> emptyBoard([Map<String, BoardPiece?> override = const {}]) {
  return Map.fromEntries(Constants.squares.map((square) => MapEntry(square, override[square])));
}

Map<String, BoardPiece?> annonymize(Map<String, BoardPiece?> board) {
  return Map.fromEntries(Constants.squares.map((square) => MapEntry(square, board[square] != null ? BoardPiece("P") : null)));
}

List<BoardUpdate> createBoardUpdates(Map<String, BoardPiece?> start, List<dynamic Function(Map<String, BoardPiece?>)> moves) {
  List<BoardUpdate> result = [BoardUpdate(start, {})];
  for (var move in moves) {
    final last = result.last.board.map;
    final next = Map<String, BoardPiece?>.from(last.map((key, value) => MapEntry(key, value)));
    move(next);
    result.add(BoardUpdate(next, last));
  }
  return result;
}

BoardUpdate? simulatePipeline(Chessboard sender, UpdateTransformer transformer, List<BoardUpdate> updates) {
  BoardUpdate? result;
  for (var update in updates) {
    result = transformer.transform(sender, update);
  }
  return result;
}

void main() {
  test('SmartPieceDetectionTransformer should detect e2e4', () {
    final chessboard = TestChessboard(TestDriver(), BoardMetadata("TestBoard", Manufacturer.virtual, false));
    final transformer = SmartPieceDetectionTransformer();

    final updateList = createBoardUpdates(annonymize(createDefaultBoard()), [
      (Map<String, BoardPiece?> board) => (board['e2'] = null),
      (Map<String, BoardPiece?> board) => (board['e4'] = BoardPiece("P")),
    ]);

    final result = simulatePipeline(chessboard, transformer, updateList);

    expect(result?.board.map["e2"]?.notation, null);
    expect(result?.board.map["e4"]?.notation, 'P');
    expect(transformer.possibleStates.length, 1);
    expect(transformer.possibleStates.first.floatingPieces.length, 0);
  });

  test('SmartPieceDetectionTransformer should detect e1c3', () {
    final chessboard = TestChessboard(TestDriver(), BoardMetadata("TestBoard", Manufacturer.virtual, false));
    final transformer = SmartPieceDetectionTransformer();

    final updateList = createBoardUpdates(annonymize(createDefaultBoard()), [
      (Map<String, BoardPiece?> board) => (board['b1'] = null),
      (Map<String, BoardPiece?> board) => (board['c3'] = BoardPiece("P")),
    ]);

    final result = simulatePipeline(chessboard, transformer, updateList);

    expect(result?.board.map["b1"]?.notation, null);
    expect(result?.board.map["c3"]?.notation, 'N');
    expect(transformer.possibleStates.length, 1);
    expect(transformer.possibleStates.first.floatingPieces.length, 0);
  });

  test('SmartPieceDetectionTransformer e4 takes d5 1/2', () {
    final chessboard = TestChessboard(TestDriver(), BoardMetadata("TestBoard", Manufacturer.virtual, false), testVerifiedFens: ["rnbqkbnr/ppp1pppp/8/3P4/8/8/PPPP1PPP/RNBQKBNR"]);
    final transformer = SmartPieceDetectionTransformer();

    final updateList = createBoardUpdates(annonymize(createDefaultBoard()), [
      (Map<String, BoardPiece?> board) => (board['e2'] = null),
      (Map<String, BoardPiece?> board) => (board['e4'] = BoardPiece("P")),
      (Map<String, BoardPiece?> board) => (board['d7'] = null),
      (Map<String, BoardPiece?> board) => (board['d5'] = BoardPiece("P")),
      (Map<String, BoardPiece?> board) => (board['d5'] = null),
      (Map<String, BoardPiece?> board) => (board['e4'] = null),
      (Map<String, BoardPiece?> board) => (board['d5'] = BoardPiece("P")),
    ]);

    final result = simulatePipeline(chessboard, transformer, updateList);

    expect(result?.board.map["e2"]?.notation, null);
    expect(result?.board.map["d7"]?.notation, null);
    expect(result?.board.map["e4"]?.notation, null);
    expect(result?.board.map["d5"]?.notation, 'P');
    expect(transformer.possibleStates.length, 2);
    expect(transformer.possibleStates.first.floatingPieces.length, 1);
  });

  test('SmartPieceDetectionTransformer e4 takes d5 2/2', () {
    final chessboard = TestChessboard(TestDriver(), BoardMetadata("TestBoard", Manufacturer.virtual, false), testVerifiedFens: ["rnbqkbnr/ppp1pppp/8/3P4/8/8/PPPP1PPP/RNBQKBNR"]);
    final transformer = SmartPieceDetectionTransformer();

    final updateList = createBoardUpdates(annonymize(createDefaultBoard()), [
      (Map<String, BoardPiece?> board) => (board['e2'] = null),
      (Map<String, BoardPiece?> board) => (board['e4'] = BoardPiece("P")),
      (Map<String, BoardPiece?> board) => (board['d7'] = null),
      (Map<String, BoardPiece?> board) => (board['d5'] = BoardPiece("P")),
      (Map<String, BoardPiece?> board) => (board['e4'] = null),
      (Map<String, BoardPiece?> board) => (board['d5'] = null),
      (Map<String, BoardPiece?> board) => (board['d5'] = BoardPiece("P")),
    ]);

    final result = simulatePipeline(chessboard, transformer, updateList);

    expect(result?.board.map["e2"]?.notation, null);
    expect(result?.board.map["d7"]?.notation, null);
    expect(result?.board.map["e4"]?.notation, null);
    expect(result?.board.map["d5"]?.notation, 'P');
    expect(transformer.possibleStates.length, 2);
    expect(transformer.possibleStates.first.floatingPieces.length, 1);
  });

  test('SmartPieceDetectionTransformer start from midgame', () async {
    final chessboard = TestChessboard(TestDriver(), BoardMetadata("TestBoard", Manufacturer.virtual, false));
    final transformer = SmartPieceDetectionTransformer();

    final rawBoard = emptyBoard({
      "e1": BoardPiece("K"),
      "e8": BoardPiece("k"),
      "a7": BoardPiece("P")
    });
    final appBoard = AppBoardState(board: rawBoard);

    await chessboard.updateAppBoard(appBoard);
    final result = transformer.transform(chessboard, BoardUpdate(annonymize(rawBoard), {}));

    expect(result.board.map["e1"]?.notation, "K");
    expect(result.board.map["e8"]?.notation, "k");
    expect(result.board.map["a7"]?.notation, "P");
    expect(result.board.map["a2"]?.notation, null);
  });
}