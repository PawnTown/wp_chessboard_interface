import '../answer.dart';
import '../command.dart';

class NewGame extends Command<bool> {
  NewGame(): super("14", "1", NewGameReady());
}

class NewGameReady extends Answer<bool> {
  NewGameReady(): super("14");

  @override
  bool process(String msg) {
    return msg.split("#")[1] == "GO*";
  }
}