import '../answer.dart';
import '../model/piece_update.dart';

class FieldUpdateAnswer extends Answer<FieldUpdate> {
  FieldUpdateAnswer() : super("0");

  @override
  FieldUpdate process(String msg) {
    String body = msg.split("#")[1];
    return FieldUpdate(
      field: body.substring(0, 2),
      type: body.substring(2, 3) == "u" ? FieldUpdateType.pickUp : FieldUpdateType.setDown
    );
  }
}