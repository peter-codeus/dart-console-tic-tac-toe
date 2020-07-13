// Cell is not empty

import 'game_cell_position.dart';

class CellNotEmptyException implements Exception {
  GameCellPosition cellPosition;

  CellNotEmptyException(this.cellPosition);

  String toString() {
    if (cellPosition == null) return "Exception";
    return "Exception: The cell number '${cellPosition.toShortString().toLowerCase()}' is not empty";
  }
}