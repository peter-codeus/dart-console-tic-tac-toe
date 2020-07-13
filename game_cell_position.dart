enum GameCellPosition { ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE }

extension GameCellPositionUtils on GameCellPosition {

  String toShortString() {
    return this.toString().split('.').last;
  }
  
  get value {
    var value = this.toString().split('.').last;
    switch (value) {
      case 'ONE':
        return 1;
      case 'TWO':
        return 2;
      case 'THREE':
        return 3;
      case 'FOUR':
        return 4;
      case 'FIVE':
        return 5;
      case 'SIX':
        return 6;
      case 'SEVEN':
        return 7;
      case 'EIGHT':
        return 8;
      case 'NINE':
        return 9;
    }
  }
}
