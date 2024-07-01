import 'dart:typed_data';
import 'dart:async';

import 'communication_type.dart';

class CommunicationClient {
  final CommunicationType type;
  final Future<void> Function(Uint8List) send;
  final StreamController<Uint8List> _inputStreamController = StreamController<Uint8List>.broadcast();

  Stream<Uint8List> get receiveStream {
    return _inputStreamController.stream;
  }

  CommunicationClient(this.type, this.send);

  handleReceive(Uint8List message) {
    _inputStreamController.add(message);
  }
}

class CommunicationClientWithAck extends CommunicationClient {
  final StreamController<Uint8List> _ackStreamController = StreamController<Uint8List>();
  Stream<Uint8List>? _ackStream;

  Stream<Uint8List> get ackStream {
    _ackStream ??= _ackStreamController.stream.asBroadcastStream();
    return _ackStream!;
  }

  CommunicationClientWithAck(CommunicationType type, Future<void> Function(Uint8List) send): super(type, send);

  handleAckReceive(Uint8List message) {
    _ackStreamController.add(message);
  }
}