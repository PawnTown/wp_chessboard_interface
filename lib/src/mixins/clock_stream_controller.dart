import 'dart:async';

import '../models/clock_side_state.dart';
import '../models/clock_state.dart';

mixin ClockStreamContoller {
  final StreamController<ClockState> updateClockStreamController = StreamController.broadcast();
  ClockState _state = ClockState(attached: false, controllable: false, left: ClockSideState(), right: ClockSideState());

  Stream<ClockState> get clockStream => updateClockStreamController.stream;
  ClockState get clockState => _state;

  void updateClockState(ClockState state) {
    _state = state;
    updateClockStreamController.add(state);
  }
}