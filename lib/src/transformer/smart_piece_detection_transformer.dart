import 'package:open_chessboard_driver/src/constants.dart';
import 'package:open_chessboard_driver/src/update_transformer.dart';

import '../chessboard.dart';
import '../interfaces/app_board_observer.dart';
import '../interfaces/app_board_verifier.dart';
import '../models/board_piece.dart';
import '../models/board_position.dart';
import '../models/board_update.dart';

class AnonymousFloatingPiece {
  final String pickedUp;
  final BoardPiece piece;

  AnonymousFloatingPiece(this.pickedUp, this.piece);
}

class SmartPieceDetectionState {
  int sort = 0;
  List<AnonymousFloatingPiece> floatingPieces;
  Map<String, BoardPiece?> boardMap;

  SmartPieceDetectionState clone() {
    return SmartPieceDetectionState(
      floatingPieces.map((e) => AnonymousFloatingPiece(e.pickedUp, e.piece)).toList(),
      boardMap.map((key, value) => MapEntry(key, value))
    );
  }

  SmartPieceDetectionState(this.floatingPieces, this.boardMap);
}

class SmartPieceDetectionTransformer extends UpdateTransformer {
  List<SmartPieceDetectionState> possibleStates = [
    SmartPieceDetectionState([], {}),
  ];

  Map<String, BoardPiece?> getAppBoardState(Chessboard sender) {
    if (sender is AppBoardObserver) {
      return (sender as AppBoardObserver).appBoard.board;
    }
    return {};
  }

  @override
  BoardUpdate transform(Chessboard sender, BoardUpdate update) {
    List<SmartPieceDetectionState> nextStates = [];
    final appBoardState = getAppBoardState(sender);

    for (var s in possibleStates) {
      final state = s.clone();
      nextStates.addAll(mapPieceBindings(state, update.board.map, appBoardState).map(applyDefaultPostionBinding).toList());
    }

    for (var state in nextStates) {
      final syncPossiblity = possibleAppBoardSync(state.boardMap, appBoardState);

      // Possible to fallback to app board -> take it
      if (syncPossiblity != null) {
        state.boardMap = syncPossiblity;
        possibleStates = [state];
        return update.copyWithBoardMap(state.boardMap);
      }

      // Possible next board state
      if (sender is AppBoardVerifier) {
        final verifier = sender as AppBoardVerifier;
        if (verifier.verifyAppBoard(BoardPosition(state.boardMap))) {
          possibleStates = [state];
          return update.copyWithBoardMap(state.boardMap);
        }
      }
    }

    final fens = <String>{};
    if (nextStates.length > 4) {
      nextStates = nextStates.take(4).toList();
    }
    nextStates.retainWhere((x) => fens.add(BoardPosition(x.boardMap).fen));

    possibleStates = nextStates;
    return update.copyWithBoardMap(nextStates.first.boardMap);
  }

  List<SmartPieceDetectionState> mapPieceBindings(
    SmartPieceDetectionState state,
    Map<String, BoardPiece?> boardMap,
    Map<String, BoardPiece?> appBoardState
  ) {
    // Removed Pieces
    for (String square in Constants.squares) {
      final removedPiece = state.boardMap[square];
      if (boardMap[square] == null && removedPiece != null) {
        state.floatingPieces.add(AnonymousFloatingPiece(square, removedPiece));
        state.boardMap[square] = null;
      }
    }

    // Add pieces, all possibilities
    List<SmartPieceDetectionState> branches = [state];
    for (String square in boardMap.keys) {

      // go through all branches
      List<SmartPieceDetectionState> newBranches = [];
      for (var b in branches) {
        if (boardMap[square] != null && b.boardMap[square] == null) {
          // Piece was set down 
          if (b.floatingPieces.isEmpty) {
            b.boardMap[square] = appBoardState[square] ?? BoardPiece("P");
            continue;
          }

          // There are floating pieces
          final firstPiece = b.floatingPieces.removeLast();
          b.boardMap[square] = firstPiece.piece;

          // Add branches for additional floating pieces
          for (var possibleOtherPiece in b.floatingPieces) {
            final branchState = b.clone();
            branchState.boardMap[square] = possibleOtherPiece.piece;
            branchState.floatingPieces.remove(possibleOtherPiece);
            newBranches.add(branchState);
          }
        }
      }
      branches.addAll(newBranches);
    }
    return branches;
  }

  BoardPiece? predictPiece(SmartPieceDetectionState state, String square, Map<String, BoardPiece?> appBoardState) {
    BoardPiece? result;
    if (state.floatingPieces.length == 1) {
      result = state.floatingPieces.first.piece;
      state.floatingPieces = [];
    } else if (state.floatingPieces.length == 2) {
      if (state.floatingPieces.last.pickedUp == square) {
        // A takes B
        result = state.floatingPieces.first.piece;
        state.floatingPieces = state.floatingPieces.where((e) => e.pickedUp != square && e.pickedUp != state.floatingPieces.first.pickedUp).toList();
      } else if (state.floatingPieces.first.pickedUp == square) {
         // B takes A
        result = state.floatingPieces.last.piece;
        state.floatingPieces = state.floatingPieces.where((e) => e.pickedUp != square && e.pickedUp != state.floatingPieces.last.pickedUp).toList();
      } else {
        // Something else try to guess with game controller
        AnonymousFloatingPiece? gcPredictedPiece = predictGameControllerPiece(state, square, appBoardState);
        if (gcPredictedPiece != null) {
          result = gcPredictedPiece.piece;
          state.floatingPieces = state.floatingPieces.where((e) => e != gcPredictedPiece && e.pickedUp != square).toList();
        } else {
          result = state.floatingPieces.last.piece;
          state.floatingPieces = [state.floatingPieces.first];
        }
      }
    } else if (state.floatingPieces.length > 2) {
      AnonymousFloatingPiece floatingPiece = state.floatingPieces.last;
      result = floatingPiece.piece;
      state.floatingPieces = state.floatingPieces.where((e) => e != floatingPiece && e.pickedUp != square).toList();
    }
    return result;
  }

  AnonymousFloatingPiece? predictGameControllerPiece(SmartPieceDetectionState state, String square, Map<String, BoardPiece?> appBoardState) {
    return state.floatingPieces.where((e) => BoardPiece.equal(e.piece, appBoardState[square])).firstOrNull;
  }

  SmartPieceDetectionState applyDefaultPostionBinding(SmartPieceDetectionState state) {
    SmartPieceDetectionState newState = state.clone();
    for (var square in Constants.squares) {
      if (square.endsWith("1") || square.endsWith("2") || square.endsWith("7") || square.endsWith("8")) {
        if (state.boardMap[square] == null) {
          return state; // Board is not in default position
        } else {
          newState.boardMap[square] = Constants.defaultPieces[square];
        }
      } else {
        if (state.boardMap[square] != null) {
          return state; // Board is not in default position
        } else {
          newState.boardMap[square] = null;
        }
      }
    }

    newState.floatingPieces = [];
    return newState;
  }

  Map<String, BoardPiece?>? possibleAppBoardSync(Map<String, BoardPiece?> board, Map<String, BoardPiece?> appBoardState) {
    for (var square in Constants.squares) {
      final boardSqOccupied = board[square] != null;
      final appBoardSqOccupied = appBoardState[square] != null;
      if (boardSqOccupied != appBoardSqOccupied) {
        return null;
      }
    }
    return appBoardState;
  }

}