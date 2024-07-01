enum Manufacturer {
  virtual,
  dgt,
  millennium,
  chessnut,
  bryghtlabs,
  certabo,
  squareoff,
  chessup,
  ichess,
}

class BoardMetadata {
  final String deviceName;
  final Manufacturer manufacturer;
  final bool supportsPieceDetection;

  BoardMetadata(this.deviceName, this.manufacturer, this.supportsPieceDetection);
}