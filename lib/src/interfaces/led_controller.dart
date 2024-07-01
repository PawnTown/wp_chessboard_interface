import "package:open_chessboard_driver/src/models/led_style_config.dart";

import "../models/board_app_move.dart";
import "../models/board_piece_delta.dart";

abstract interface class LedController {
    /// Sets the leds for the welcome animation
    Future<void> welcomeLeds();

    /// Sets the leds if the chessboard and the app are out of sync
    Future<void> setDeltaLeds(List<BoardPieceDelta> delta, { LedStyleConfig? config });

    /// Resets all leds
    Future<void> resetLeds();

    /// A indicator fot the user that the last move played was accepted by the app
    Future<void> setCommitMoveLeds(BoardAppMove move, { LedStyleConfig? config });

    /// Set the leds for the last move played in the app
    Future<void> setAppMoveLeds(BoardAppMove mov, { LedStyleConfig? config });
}