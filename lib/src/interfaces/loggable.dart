import "../models/board_log_message.dart";

abstract interface class Loggable {
  Stream<BoardLogMessage> get logStream;
  List<BoardLogMessage> get messageLog;
}