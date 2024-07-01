import 'package:open_chessboard_driver/src/models/clock_state.dart';

import '../models/clock_run_state.dart';

abstract interface class ClockController {
    Stream<ClockState> get clockStream;
    ClockState get clockState;

    /// Let the clock beep
    Future<void> clockBeep(Duration duration);

    /// Set the clock to the given time
    Future<void> clockSet({ required Duration timeLeft, required Duration timeRight, required ClockRunState runState });

    /// Set Clock Text
    Future<void> clockText(String text, { Duration beep = Duration.zero});

}