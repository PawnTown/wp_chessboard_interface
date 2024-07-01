enum BoardLogMessageType {
  error, message
}

class BoardLogMessage {
  final DateTime created;
  final String description;
  final BoardLogMessageType type;
  final List<int>? buffer;
  final Object? error;

  BoardLogMessage(this.created, this.type, this.description, { this.buffer, this.error });
}