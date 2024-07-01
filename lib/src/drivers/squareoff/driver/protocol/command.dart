import 'dart:typed_data';

import '../../../../models/communication_client.dart';
import '../squareoff_message.dart';
import './answer.dart';
import 'model/request_config.dart';

abstract class Command<T> {
  String code;
  String body;
  Answer<T>? answer;

  Command(this.code, this.body, this.answer);

  Future<String> messageBuilder() async {
    return "$code#$body*";
  }

  Future<void> send(CommunicationClient client) async {
    String messageString = await messageBuilder();
    List<int> message = messageString.codeUnits;
    await client.send(Uint8List.fromList(message));
  }

  Future<T?> request(
    CommunicationClient client,
    Stream<SquareOffMessage> inputStream,
    [RequestConfig config = const RequestConfig()]
  ) async {
    Future<T?> result = getReponse(inputStream);
    try {
      await send(client);
      T? resultValue = await result.timeout(config.timeout);
      return resultValue;
    } catch (e) {
      if (config.retries <= 0) {
        rethrow;
      }
      await Future.delayed(config.retryDelay);
      return request(client, inputStream, config.withDecreasedRetry());
    }
  }

  Future<T?> getReponse(Stream<SquareOffMessage> inputStream) async {
    final answer = this.answer;
    if (answer == null) return null;
    SquareOffMessage message = await inputStream
        .firstWhere((SquareOffMessage msg) => msg.getCode() == answer.code);
    return answer.process(message.getMessage());
  }
}