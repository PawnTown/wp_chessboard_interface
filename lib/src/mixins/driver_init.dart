import 'dart:async';

import '../models/driver_init_state.dart';

mixin DriverInit {
  final StreamController<DriverInitState> initStateStreamController = StreamController<DriverInitState>.broadcast();

  Stream<DriverInitState> get initStateStream {
    return initStateStreamController.stream;
  }
}