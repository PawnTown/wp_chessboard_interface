import 'dart:async';

import '../models/board_log_message.dart';

mixin BasicLogger {
  final List<BoardLogMessage> messageLog = [];
  final StreamController<BoardLogMessage> _logController = StreamController<BoardLogMessage>.broadcast();
  int maxLogLength = 100;
  Stream<BoardLogMessage> get logStream {
    return _logController.stream;
  }

  void addLogMessage(BoardLogMessageType type, String description , { Object? error, List<int>? buffer }) {
    final message = BoardLogMessage(DateTime.now(), type, description, buffer: buffer, error: error);
    messageLog.insert(0, message);
    _logController.add(message);
    while (messageLog.length > maxLogLength) {
      messageLog.removeLast();
    }
  }
}