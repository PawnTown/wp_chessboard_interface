import "../models/board_battery_update.dart";

abstract interface class BatteryMonitor {
  Stream<BoardBatteryUpdate> get onBatteryUpdate;
  BoardBatteryUpdate get batteryStatus;
}