import 'game_cell_position.dart';
import 'game_exceptions.dart';
import 'token.dart';

class GameBoard {
  final String title;
  List<Token> _grid = List.generate(9, (index) => Token.EMPTY);

  bool get isFull => !_grid.contains(Token.EMPTY);

  GameBoard({this.title});

  void play(GameCellPosition position, Token token) {
    if (_grid[position.value - 1] != Token.EMPTY)
      throw CellNotEmptyException(position);
    else
      _grid[position.value - 1] = token;
  }

  String getCellToken(GameCellPosition position) => _grid[position.value-1].value;

  bool isWinner(Token token)
  {
    return (_grid[0] == token && _grid[1] == token && _grid[2] == token ) ||
        (_grid[0] == token && _grid[3] == token && _grid[6] == token ) ||
        (_grid[0] == token && _grid[4] == token && _grid[8] == token ) ||
        (_grid[1] == token && _grid[4] == token && _grid[7] == token ) ||
        (_grid[2] == token && _grid[5] == token && _grid[8] == token ) ||
        (_grid[3] == token && _grid[4] == token && _grid[5] == token ) ||
        (_grid[6] == token && _grid[7] == token && _grid[8] == token ) ||
        (_grid[2] == token && _grid[4] == token && _grid[6] == token );
  }

  bool isDraw() => this.isFull && !hasWinner();

  bool hasWinner() => isWinner(Token.CIRCLE) || isWinner(Token.CROSS);

  void clear() => _grid.forEach((e) { e = Token.EMPTY; });
  
}
