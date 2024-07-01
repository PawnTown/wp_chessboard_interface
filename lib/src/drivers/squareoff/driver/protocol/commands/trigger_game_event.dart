import '../command.dart';
import '../model/game_event.dart';

class TriggerGameEvent extends Command<void> {
  TriggerGameEvent(GameEvent event): super("27", event.toShortString(), null);
}
