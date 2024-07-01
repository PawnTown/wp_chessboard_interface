import '../answer.dart';
import '../command.dart';
import '../model/battery_status.dart';

class RequestBattery extends Command<BatteryStatus> {
  RequestBattery() : super("4", "", BatteryStatusAnswer());
}

class BatteryStatusAnswer extends Answer<BatteryStatus> {
  BatteryStatusAnswer(): super("22");

  @override
  BatteryStatus process(String msg) {
    return BatteryStatus(double.parse(msg.split("#")[1].replaceAll("*", "")));
  }
}