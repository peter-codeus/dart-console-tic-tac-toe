enum Token { CROSS, CIRCLE, EMPTY }

extension ParseToString on Token {
  String toShortString() {
    return this.toString().split('.').last;
  }

  String get value {
    var value = this.toString().split('.').last;
    if (value == 'CROSS')
      return 'X';
    else if(value == 'CIRCLE')
      return 'O';
    else
      return ' ';
  }
}
