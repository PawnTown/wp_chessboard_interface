import 'dart:async';
import 'package:open_chessboard_driver/src/constants.dart';
import 'package:open_chessboard_driver/src/models/board_app_move.dart';
import 'package:open_chessboard_driver/src/utils.dart';
import 'package:synchronized/synchronized.dart';
import '../drivers/squareoff/squareoffdriver.dart';
import '../interfaces/battery_monitor.dart';
import '../interfaces/led_controller.dart';
import '../interfaces/loggable.dart';
import '../models/board_battery_update.dart';
import '../models/board_log_message.dart';
import '../models/board_metadata.dart';
import '../models/board_piece.dart';
import '../models/board_piece_delta.dart';
import '../chessboard.dart';
import '../mixins/basic_logger.dart';
import '../models/led_style_config.dart';

class SquareoffChessboard extends Chessboard<SquareoffDriver> with BasicLogger implements Loggable, LedController, BatteryMonitor {
  StreamController<BoardBatteryUpdate> batteryUpdateStreamController = StreamController.broadcast();
  late Timer _boardUpdateTimer;
  late Timer _batteryUpdateTimer;
  BoardBatteryUpdate _batteryStatus = BoardBatteryUpdate(0, false);

  @override
  BoardBatteryUpdate get batteryStatus => _batteryStatus; 

  SquareoffChessboard(SquareoffDriver driver) : super(driver, BoardMetadata("SquareOff Pro", Manufacturer.squareoff, false)) {
    // Board Updates
    driver.getBoardUpdateStream()
      .handleError((e) => addLogMessage(BoardLogMessageType.error, "Error while parsing board update", error: e))
      .listen((board) {
        addLogMessage(BoardLogMessageType.message, "Board update: $board");
        updateBoardState(_mapBoardState(board));
      });

    driver.getFieldUpdateStream()
      .handleError((e) => addLogMessage(BoardLogMessageType.error, "Error while parsing field update", error: e))
      .listen((_) {
        addLogMessage(BoardLogMessageType.message, "Field update");
        driver.getBoard();
      });

    // Board Changes
    _boardUpdateTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      driver.getBoard();
    });

    // Battery Changes
    _batteryUpdateTimer = Timer.periodic(Duration(seconds: 15), (timer) async {
      _updateBattery(await driver.getBatteryStatus());
    });
    
    _init();
  }

  void _init() async {
    await driver.getBoard();
    Future.delayed(Duration(seconds: 3)).then((_) async {
      _updateBattery(await driver.getBatteryStatus());
    });
    Future.delayed(Duration(seconds: 1)).then((_) {
      driver.newGame();
    });
  }

  void _updateBattery(BatteryStatus? batteryStatus) {
    double? batteryLevel = batteryStatus?.batteryLevel;
    if (batteryLevel == null) {
      return;
    }

    if (batteryLevel < 3) {
      batteryLevel = 0;
    } else if (batteryLevel >= 4) {
      batteryLevel = 1;
    } else {
      batteryLevel = batteryLevel - 3;
    }

    addLogMessage(BoardLogMessageType.message, "Battery update: $batteryLevel");
    _batteryStatus = BoardBatteryUpdate(batteryLevel, false);
    batteryUpdateStreamController.add(_batteryStatus);
  }

  Map<String, BoardPiece?> _mapBoardState(Map<String, bool> boardMap) {
    Map<String, BoardPiece?> result = {};
    for (var square in boardMap.keys) {
      final squareOccupied = boardMap[square];
      result[square] = squareOccupied != null && squareOccupied ? BoardPiece("P") : null;
    }
    return result;
  }

  @override
  Stream<BoardBatteryUpdate> get onBatteryUpdate => batteryUpdateStreamController.stream;

  Lock ledLock = Lock();
  List<String> ledPattern = [];

  @override
  Future<void> resetLeds() {
    return ledLock.synchronized(() async {
      ledPattern = [];
      await setLeds(ledPattern).timeout(Duration(seconds: 1));
    });
  }

  @override
  Future<void> setAppMoveLeds(BoardAppMove move, { LedStyleConfig? config }) {
    final style = config?.style ?? LedStyle.standard;
    
    return ledLock.synchronized(() async {
      final squares = LedStyleConfig.getAppMoveSquares(style, move);
      await setLeds(squares).timeout(Duration(seconds: 1));
    });
  }
  
  @override
  Future<void> welcomeLeds() {
    return ledLock.synchronized(() async {
      await setLeds(Constants.squares);
      await Future.delayed(Duration(milliseconds: 200));
      await setLeds([]);
    });
  }

  @override
  Future<void> setDeltaLeds(List<BoardPieceDelta> delta, { LedStyleConfig? config }) {    
    return ledLock.synchronized(() async {
      ledPattern = [];
      for (var item in delta) {
        ledPattern.add(item.square);
      }
      await setLeds(ledPattern).timeout(Duration(seconds: 1));
    });
  }

  @override
  Future<void> setCommitMoveLeds(BoardAppMove move, { LedStyleConfig? config }) {   
    final style = config?.style ?? LedStyle.standard;

    return ledLock.synchronized(() async {
      final squares = LedStyleConfig.getCommitSquares(style, move);
      await setLeds(squares).timeout(Duration(seconds: 1));
      await setLeds(ledPattern).timeout(Duration(seconds: 1));
    });
  }

  Future<void> setLeds(List<String> squares) async {
    if (state.isReversed) {
      squares = squares.map(Utils.inverseSquare).toList();
    }
    await driver.setLeds(squares).timeout(Duration(seconds: 1));
  }
  
  @override
  void dispose() {
    super.dispose();
    _batteryUpdateTimer.cancel();
    _boardUpdateTimer.cancel();
  }
  
}