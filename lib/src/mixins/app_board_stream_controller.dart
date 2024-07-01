import 'dart:async';

import '../../open_chessboard_driver.dart';

mixin AppBoardStreamController<T> on Chessboard<T> {
  StreamController<AppBoardState> appBoardStreamController = StreamController.broadcast();

  AppBoardState _appBoard = AppBoardState(board: {});

  AppBoardState get appBoard => _appBoard;
  
  Stream<AppBoardState> get appBoardStream => appBoardStreamController.stream;
  
  Future<void> updateAppBoard(AppBoardState state) async {
    _appBoard = state;
    appBoardStreamController.add(state);
    await afterAppBoardUpdate(state);
    retriggerBoardUpdate();
  }

  Future<void> afterAppBoardUpdate(AppBoardState state) async {}
}