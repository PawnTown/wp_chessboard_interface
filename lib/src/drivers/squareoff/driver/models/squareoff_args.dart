import '../../../../models/communication_client.dart';

class SquareoffArgs {
  final CommunicationClient client;
  final Duration initialDelay;

  SquareoffArgs(this.client, { this.initialDelay = const Duration(milliseconds: 300) });
}