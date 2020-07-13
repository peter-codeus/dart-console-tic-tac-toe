import 'dart:math';

import 'game_board.dart';
import 'game_cell_position.dart';
import 'dart:io';

import 'game_exceptions.dart';
import 'server/tic_tac_toe_network_client.dart';
import 'token.dart';
import 'utils.dart' as utils;

class GuiUtils {
  static void renderGrid(GameBoard gameBoard) {
    print("\x1B[2J\x1B[0;0H");
    print(gameBoard.title);
    print('\t  Player Tokens:: ');
    print('   Player One: X - Player Two: O');

    print('-------------------------------------');
    print(
        '|    ${gameBoard.getCellToken(GameCellPosition.ONE)}     |      ${gameBoard.getCellToken(GameCellPosition.TWO)}     |      ${gameBoard.getCellToken(GameCellPosition.THREE)}    |');
    print('-------------------------------------');
    print(
        '|    ${gameBoard.getCellToken(GameCellPosition.FOUR)}     |      ${gameBoard.getCellToken(GameCellPosition.FIVE)}     |      ${gameBoard.getCellToken(GameCellPosition.SIX)}    |');
    print('-------------------------------------');
    print(
        '|    ${gameBoard.getCellToken(GameCellPosition.SEVEN)}     |      ${gameBoard.getCellToken(GameCellPosition.EIGHT)}     |      ${gameBoard.getCellToken(GameCellPosition.NINE)}    |');
    print('-------------------------------------');
  }

  static int main_menu() {
    print("\x1B[2J\x1B[0;0H");
    print('======== Welcome to Tic Tac Toe v1.0 =======');
    print('\t1. One Player (Man vs PC)');
    print('\t2. Two Players (Man vs Man)');
    print('\t3. Two Players (Man vs Man) Online');
    print('\t4. Instruction');
    print('\t5. Exit');
    return utils.choiceValidator(min: 1, max: 5);
  }

  static void onlineGamePlay(
      {gameBoard: GameBoard,
      client: TicTacToeNetworkClient,
      roomName: String,
      playerNumber: int
      }) async {

    int cellPosition = 0;
    Token currentPlayerToken = Token.CROSS;
    String playerNumberString = playerNumber == 1 ? "Two" : "One";
    bool myTurn = (playerNumber == 1);

    while (!gameBoard.isFull && !gameBoard.hasWinner()) {
      renderGrid(gameBoard);
      try {
        if (myTurn) {
          cellPosition = utils.choiceValidator(min: 1, max: 9);
          gameBoard.play(selectCellPosition(cellPosition), currentPlayerToken);
          await client.sendCellPosition(roomName, cellPosition);
          myTurn = false;
        } else {
          print('Waiting for Player $playerNumberString ...');
          dynamic position = await client.getCellPosition();
          gameBoard.play(selectCellPosition(int.parse(position['data'])),
              currentPlayerToken);
          myTurn = true;
        }
        currentPlayerToken = (currentPlayerToken == Token.CIRCLE) ? Token.CROSS : Token.CIRCLE;

      } on CellNotEmptyException {
        print('Cell is already occupied');
      } on Exception {
        continue;
      }
    }
  }

  static void createGameRoom() async {
    final client = TicTacToeNetworkClient();
    await client.init();

    while (true) {
      stdout.write('Please Enter Room Name or q to move back:: ');
      String roomName = stdin.readLineSync();
      if (roomName.toLowerCase() == 'q') break;

      var gameBoard =
          GameBoard(title: 'Welcome to Two Players Online (Man vs Man)');

      try {
        await client.createGameRoom(roomName);
        print('Game Room Creation ........ [OK]');
        stdout.write('--- Waiting for other player to join ....');
        await client.waitOtherPlayer();
        print('[OK]');

        await onlineGamePlay(
            client: client,
            gameBoard: gameBoard,
            playerNumber: 1,
            roomName: roomName);

        renderGrid(gameBoard);

        if (gameBoard.hasWinner()) {
          if (gameBoard.isWinner(Token.CROSS))
            print('You Won');
          else
            print('You Lost');
        } else
          print('The game was a DRAW');

        await client.disconnect(roomName, 1);
        print('\n===== Game Options =====');
        print('1. Restart');
        print('2. Move back to main menu');
        stdin.readLineSync();
        break;
      } catch (e) {
        print(e);
        stdin.readLineSync();
      }
    }
  }

  static void joinGameRoom() async {
    final client = TicTacToeNetworkClient();
    await client.init();
    var gameBoard =
        GameBoard(title: 'Welcome to Two Players Online (Man vs Man)');
    String selectedGameRoom;

    print('\nFetching game rooms ... \n');
    dynamic gameRooms = await client.findGameRooms();

    if (!gameRooms['data'].isEmpty) {
      print('---- Select Game Room -----');
      for (var i = 0; i < gameRooms['data'].length; i++) {
        print('\t${i + 1}. ${gameRooms['data'][i]}');
      }
      int gameRoom =
          utils.choiceValidator(min: 1, max: gameRooms['data'].length);
      selectedGameRoom = gameRooms['data'][gameRoom - 1];
      try {
        stdout.write('-- Joining Game Room \'${selectedGameRoom}\' .... ');
        // dynamic data =
        await client.joinGameRoom(selectedGameRoom);
        print('[OK]');

        await onlineGamePlay(
            client: client,
            gameBoard: gameBoard,
            playerNumber: 2,
            roomName: selectedGameRoom);

        renderGrid(gameBoard);

        if (gameBoard.hasWinner()) {
          if (gameBoard.isWinner(Token.CROSS))
            print('You Lost');
          else
            print('You Won');
        } else
          print('The game was a DRAW');
        await client.disconnect(selectedGameRoom, 2);
        print('\n===== Game Options =====');
        print('1. Restart');
        print('2. Move back to main menu');
        stdin.readLineSync();
      } on Exception catch (e) {
        print(e);
        print("Could not join game room");
      }
    }
  }

  static void twoPlayersOnline() async {
    while (true) {
      print("\x1B[2J\x1B[0;0H");
      print('======= Two players, Online Version ======');
      print('1. Create Game Room');
      print('2. Join Game Room');
      print('3. Back To Main Menu');
      int choice = utils.choiceValidator(min: 1, max: 3);

      try {
        switch (choice) {
          case 1: //Create Game Room
            await createGameRoom();
            break;
          case 2: // Join Game Room
            await joinGameRoom();
            break;
          case 3:
            return;
        }
      } catch (e) {
        // print(e);
        print(
            'Failed to connect to server, Please check your internet connection');
        print(
            'Press r to restart or any other key to move back to main menu ...');
        stdout.write('Action:: ');
        String userInput = stdin.readLineSync();
        if (userInput.toUpperCase() != 'R') break;
      }
    }
  }

  static Future<void> twoPlayersLocal({bool computer = false}) async {
    while (true) {
      GameBoard gameBoard = GameBoard(
          title: 'Welcome to Two Players Local (' +
              (computer ? 'Man vs PC' : 'Man vs Man') +
              ')');
      Token currentPlayerToken = Token.CROSS;
      bool computerPlayerTurn = false;

      while (!gameBoard.isFull && !gameBoard.hasWinner()) {
        print("\x1B[2J\x1B[0;0H");
        renderGrid(gameBoard);

        int cellPosition = 0;

        while (true) {
          try {
            if (computerPlayerTurn) {
              cellPosition = oneToNinePcGenerator();
            } else {
              if (currentPlayerToken == Token.CROSS) {
                print('Player One\'s Turn:: ');
              } else {
                if (!computer) print('Player Two\'s Turn:: ');
              }
              cellPosition = utils.choiceValidator(min: 1, max: 9);
            }
            gameBoard.play(
                selectCellPosition(cellPosition), currentPlayerToken);
            break;
          } on CellNotEmptyException {
            if (!computerPlayerTurn) print('Cell is already occupied \n');
            await Future.delayed(Duration(milliseconds: 400));
          } on Exception {
            continue;
          }
        }

        if (currentPlayerToken == Token.CROSS) {
          currentPlayerToken = Token.CIRCLE;
          if (computer) computerPlayerTurn = true;
        } else {
          if (computer) {
            computerPlayerTurn = false;
            print('Computer\'s Turn:: ');
            await Future.delayed(Duration(milliseconds: 400));
          }
          currentPlayerToken = Token.CROSS;
        }
      }
      renderGrid(gameBoard);

      if (gameBoard.hasWinner()) {
        if (gameBoard.isWinner(Token.CROSS))
          print('Player One Won');
        else if (computer)
          print('Computer Won');
        else
          print('Player Two Won');
      } else
        print('The game was a DRAW');

      print('\n===== Game Options =====');
      print('1. Restart');
      print('2. Move back to main menu');

      if (utils.choiceValidator(min: 1, max: 2) == 2) break;
    }
  }

  static GameCellPosition selectCellPosition(int pos) {
    switch (pos) {
      case 1:
        return GameCellPosition.ONE;
      case 2:
        return GameCellPosition.TWO;
      case 3:
        return GameCellPosition.THREE;
      case 4:
        return GameCellPosition.FOUR;
      case 5:
        return GameCellPosition.FIVE;
      case 6:
        return GameCellPosition.SIX;
      case 7:
        return GameCellPosition.SEVEN;
      case 8:
        return GameCellPosition.EIGHT;
      case 9:
        return GameCellPosition.NINE;
      default:
        return null;
    }
  }

  static int oneToNinePcGenerator() => Random().nextInt(9) + 1;

  static void instructions() {
    print("\x1B[2J\x1B[0;0H");
    print('\t=========== Instructions ============');
    print(
        '\t\tFrom the menu select the choice you desire \n if you select ..... etc');
    print('Press any key to continue ...');
    stdin.readLineSync();
  }

  static bool exit_app() {
    print("\x1B[2J\x1B[0;0H");
    print('\t======== Are you sure you want to exit ? ============');
    print('\t\t\t1. Yes');
    print('\t\t\t2. No');
    return utils.choiceValidator(min: 1, max: 2) == 1;
  }
}
