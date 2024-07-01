
import 'dart:async';

import '../open_chessboard_driver.dart';
import './models/board_metadata.dart';
import './transformer/orientation_detection_transformer.dart';
import './transformer/duplicate_filter_transformer.dart';
import './update_transformer.dart';

abstract class Chessboard<T> {
  final T driver;
  final BoardMetadata metadata;
  final StreamController<BoardUpdate> updateStreamController = StreamController.broadcast();
  final List<UpdateTransformer> boardTransformer = [
    OrientationDetectionTransformer(),
    DuplicateFilterTransformer(),
  ];

  BoardUpdate _state = BoardUpdate({}, {});

  Chessboard(this.driver, this.metadata);

  Stream<BoardUpdate> get stream => updateStreamController.stream;
  BoardUpdate get state => _state;

  Map<String, BoardPiece?> _previousBoardState = {};
  void updateBoardState(Map<String, BoardPiece?> boardState, {bool force = false}) {
    _state = BoardUpdate(boardState, _previousBoardState, force: force);
    for (var transformer in boardTransformer) {
      final tState = transformer.transform(this, _state);
      if (tState == null) {
        return;
      }
      _state = tState;
    }
    
    updateStreamController.add(_state);
    _previousBoardState = _state.board.map;
  }

  void retriggerBoardUpdate() {
    updateBoardState(_state.board.map, force: true);
  }
  
  void dispose() {
    updateStreamController.close();
  }
}