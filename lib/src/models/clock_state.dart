import 'package:open_chessboard_driver/src/models/clock_side_state.dart';

class ClockState {
  final bool attached;
  final bool controllable;
  final ClockSideState left;
  final ClockSideState right;
  final DateTime createdAt = DateTime.now();

  ClockState({required this.attached, required this.controllable, required this.left, required this.right});
}