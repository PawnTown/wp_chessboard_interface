import 'dart:async';
import 'package:open_chessboard_driver/src/mixins/driver_init.dart';

import '../../../models/driver_init_state.dart';
import 'models/squareoff_args.dart';
import './squareoff_message.dart';
import 'protocol/commands/field_update.dart';
import 'protocol/commands/get_board.dart';
import 'protocol/commands/new_game.dart';
import 'protocol/commands/request_battery.dart';
import 'protocol/commands/set_leds.dart';
import 'protocol/commands/trigger_game_event.dart';
import 'protocol/model/battery_status.dart';
import 'protocol/model/game_event.dart';
import 'protocol/model/piece_update.dart';
import 'protocol/model/request_config.dart';

class SquareoffDriver with DriverInit {

  final SquareoffArgs args;
  final StreamController<SquareOffMessage> _inputStreamController;
  final List<int> _buffer;

  late Stream<SquareOffMessage> _inputStream;
  String? _version;

  static List<String> squares = [
    'a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8',
    'b1', 'b2', 'b3', 'b4', 'b5', 'b6', 'b7', 'b8',
    'c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7', 'c8',
    'd1', 'd2', 'd3', 'd4', 'd5', 'd6', 'd7', 'd8',
    'e1', 'e2', 'e3', 'e4', 'e5', 'e6', 'e7', 'e8',
    'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8',
    'g1', 'g2', 'g3', 'g4', 'g5', 'g6', 'g7', 'g8',
    'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'h7', 'h8'
  ];

  String? get version => _version;

  SquareoffDriver(this.args):
  _inputStreamController = StreamController<SquareOffMessage>(),
  _buffer = [] {
    initStateStreamController.add(DriverInitState.uninitialized);
    args.client.receiveStream.listen(_handleInputStream);
    _inputStream = _inputStreamController.stream.asBroadcastStream();
    _init();
  }

  Future<void> _init({ Duration initialDelay = const Duration(milliseconds: 300) }) async {
    initStateStreamController.add(DriverInitState.initializing);
    await Future.delayed(initialDelay);
    initStateStreamController.add(DriverInitState.initialized);
  }

  void _handleInputStream(List<int> chunk) {
    print("R > ${chunk.map((n) => String.fromCharCode(n & 127))}");
    _buffer.addAll(chunk);

    if (_buffer.length > 1000) {
      _buffer.removeRange(0, _buffer.length - 1000);
    }

    do {
      try {
        SquareOffMessage message = SquareOffMessage.parse(_buffer);
        _buffer.removeRange(0, message.getLength() - 1);
        _inputStreamController.add(message);
        // print("[IMessage] valid (" + message.getCode() + ")");
      } on SquareOffInvalidMessageException catch (e) {
        skipBadBytes(e.skipBytes, _buffer);
        // print("[IMessage] invalid");
      } on SquareOffUncompleteMessage {
        // wait longer
        break;
      } catch (err) {
        print("Unknown parse-error: $err");
        _buffer.clear();
        break;
      }
    } while (_buffer.isNotEmpty);
  }

  Stream<SquareOffMessage> getInputStream() {
    return _inputStream;
  }

  void skipBadBytes(int start, List<int> buffer) {
    buffer.removeRange(0, start);
  }

  Stream<FieldUpdate> getFieldUpdateStream() {
    return getInputStream()
        .where(
            (SquareOffMessage msg) => msg.getCode() == FieldUpdateAnswer().code)
        .map((SquareOffMessage msg) => FieldUpdateAnswer().process(msg.getMessage()));
  }

  Stream<Map<String, bool>> getBoardUpdateStream() {
    return getInputStream()
        .where(
            (SquareOffMessage msg) => msg.getCode() == BoardStateMessage().code)
        .map((SquareOffMessage msg) => BoardStateMessage().process(msg.getMessage()));
  }

  Future<bool?> newGame({ RequestConfig config = const RequestConfig(0, Duration(seconds: 5)) }) {
    return NewGame().request(args.client, _inputStream, config);
  }

  Future<Map<String, bool>?> getBoard({ RequestConfig config = const RequestConfig(0, Duration(seconds: 5)) }) {
    return GetBoard().request(args.client, _inputStream, config);
  }

  Future<BatteryStatus?> getBatteryStatus({ RequestConfig config = const RequestConfig(0, Duration(seconds: 5)) }) {
    return RequestBattery().request(args.client, _inputStream, config);
  }

  Future<void> setLeds(List<String> squares) {
    return SetLeds(squares).send(args.client);
  }

  Future<void> triggerGameEvent(GameEvent event) {
    return TriggerGameEvent(event).send(args.client);
  }

}
