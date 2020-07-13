import 'dart:io';

class GameRoom
{
  String name;
  Socket playerOneSocket, playerTwoSocket;
  bool isActive = false;
  int playerTurn = 1;
  bool isPlayerOneConnected = false, isPlayerTwoConnected = false;

  GameRoom({this.name, this.playerOneSocket, this.playerTwoSocket});
}