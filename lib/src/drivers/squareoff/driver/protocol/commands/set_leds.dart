import '../command.dart';

class SetLeds extends Command<void> {
  SetLeds(List<String> squares): super("25", squares.join("").toLowerCase(), null);
}
