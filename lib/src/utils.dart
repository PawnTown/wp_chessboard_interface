import 'package:open_chessboard_driver/src/constants.dart';
import 'package:open_chessboard_driver/src/drivers/chessup/driver/chessup_protocol.dart';

import '../open_chessboard_driver.dart';

abstract class Utils {

  static String inverseSquare(String square) {
    return Constants.squares[_flipIndex(Constants.squares.indexOf(square.toLowerCase()), length: 64)];
  }

  static int _flipIndex(int index, {int length = 8}) {
    if (length % 2 == 0) {
      int middle = (length + 1) ~/ 2;
      return middle - index + middle - 1;
    }

    int middle = length ~/ 2 + 1;
    return middle - index + middle;
  }

  static String boardMapToFen(Map<String, BoardPiece?> map) {
    StringBuffer fen = StringBuffer();
    
    for (int rank = 8; rank >= 1; rank--) {
      int emptySquares = 0;
      
      for (String file in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
        String square = '$file$rank';
        
        if (map.containsKey(square)) {
          final piece = map[square];
          if (piece != null) {
            if (emptySquares > 0) {
              fen.write(emptySquares.toString());
              emptySquares = 0;
            }
            fen.write(piece.notation);
            continue;
          }
        }
        emptySquares++;
      }
      
      if (emptySquares > 0) {
        fen.write(emptySquares.toString());
      }
      
      if (rank > 1) {
        fen.write('/');
      }
    }
    
    return fen.toString();
  }

  static Map<String, BoardPiece?> fenToBoardMap(String fen) {
    Map<String, BoardPiece?> map = {};
    List<String> ranks = fen.split(' ')[0].split('/');
    for (var i = 0; i < 8; i++) {
      final rank = ranks[i];
      int squaresSet = 0;
      for (var j = 0; j < 8; j++) {
        final notation = rank[j];
        
        if (ChessUpProtocol.pieces.values.contains(notation)) {
          final square = ChessUpProtocol.squares[i * 8 + j];
           map[square] = BoardPiece(notation);
           squaresSet++;
        } else {
          final emptySquares = int.parse(notation);
          for (var k = 0; k < emptySquares; k++) {
            final square = ChessUpProtocol.squares[i * 8 + (j + k)];
            map[square] = null;
          }
          squaresSet += emptySquares;
        }

        if (squaresSet == 8) {
          break;
        }
      }
    }
    return map;
  }

  static GamePlayerColor fenTurn(String fen) {
    return fen.split(' ')[1] == 'w' ? GamePlayerColor.white : GamePlayerColor.black;
  }

  static CastelingRights fenCastelingRights(String fen) {
    String casteling = fen.split(' ')[2];
    return CastelingRights(
      casteling.contains('K'),
      casteling.contains('Q'),
      casteling.contains('k'),
      casteling.contains('q'),
    );
  }

  static bool fenEnPassant(String fen) {
    return fen.split(' ')[3] != '-';
  }

  static int fenHalfMove(String fen) {
    return int.parse(fen.split(' ')[4]);
  }

  static int fenFullMove(String fen) {
    return int.parse(fen.split(' ')[5]);
  }

}