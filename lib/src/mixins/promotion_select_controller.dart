import 'dart:async';

import '../models/board_piece.dart';

mixin PromotionSelectController {
  final StreamController<BoardPiece> updateClockStreamController = StreamController.broadcast();
  Stream<BoardPiece> get promotionSelectionStream => updateClockStreamController.stream;

  void sendPromotion(BoardPiece state) {
    updateClockStreamController.add(state);
  }
}