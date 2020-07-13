import 'dart:io';
import 'dart:convert' as converter;
import 'game_room.dart';
import 'protocol_transformer.dart';

import 'constants.dart';

ServerSocket server;
List<int> dataStore = [];
List<GameRoom> gameRooms = [
  GameRoom(name: 'Gamerz Zone'),
  GameRoom(name: 'Game or Leave'),
  GameRoom(name: 'Master Gamers')
];
void main() {
  startServer();
}

void startServer() async {
  try {
    server = await ServerSocket.bind(InternetAddress.anyIPv4, SERVER_PORT);
    print('Server is running on port $SERVER_PORT ...');
    server.listen(handleConnection);
  } on Exception {
    stderr.write('Error: Server could not bound on port $SERVER_PORT');
    exit(1);
  }
}

void handleConnection(Socket client) {
  //Todo:: JOIN to join game: payload username, password, game room name
  //Todo:: NEW to create game room: payload username, password, game room name
  print('New Client Connection');

  client.transform(ProtocolTransformer()).listen(
    (data) {
      print('Incoming $data');
      dynamic payload = converter.jsonDecode(data);

      switch (payload['req']) {
        case 'GAMEROOMS':
          String roomData = "";
          List<String> roomNames = gameRooms.map((room) => room.name).toList();

          for (var i = 0; i < roomNames.length; i++) {
            roomData += '"${roomNames[i]}"';
            if (i < roomNames.length - 1) roomData += ',';
          }
          roomData = '[$roomData]';

          String response = '{"status": "OK", "data": $roomData }.';
          client.write(response);

          break;
        case 'JOIN_ROOM':
          //Todo:: do some things
          String roomName = payload['data'];
          bool roomExist = false;
          for (var room in gameRooms) {
            if (!room.isActive) {
              if (room.name == roomName) {
                roomExist = true;
                room.playerTwoSocket = client;
                room.isActive = true;
                room.playerOneSocket
                    .write('{"req": "JOIN_GAME", "status": "OK"}.');
                room.isPlayerTwoConnected = true;
                break;
              }
            }
          }

          String response = '';
          print('---- Joining Room --------');
          if (roomExist)
            response = '{"status": "OK"}.';
          else
            response =
                '{"status": "NOT OK", "error": "Could not join game room"}';
          client.write(response);
          break;
        case 'CREATE_ROOM':
          String newRoomName = payload['data'];
          bool roomExist = false;
          for (var room in gameRooms) {
            if (room.name.toLowerCase() == newRoomName.toLowerCase()) {
              roomExist = true;
              break;
            }
          }

          String response = '';
          if (roomExist) {
            response =
                '{"status": "NOT OK", "error": "Game room already exists"}.';
          } else {
            final gameRoom =
                GameRoom(name: payload['data'], playerOneSocket: client);
            gameRoom.isPlayerOneConnected = true;
            gameRooms.add(gameRoom);
            response = '{"status": "OK"}.';
          }
          client.write(response);
          break;
        case "RECV_PLAY":
          break;

        case "SEND_PLAY":
          String selectedGameRoom = payload['data']['room'];
          GameRoom gameRoom =
              gameRooms.where((g) => g.name == selectedGameRoom).toSet().first;
          if (gameRoom == null) {
            client.write(
                '{"status": "NOT OK", "error": "Game room does not exist"}.');
            return;
          } else {
            String response =
                '{"status": "OK", "data": "${payload['data']['pos']}"}.';
            String ack = '{"status": "OK"}.';
            print(response);
            if (gameRoom.playerTurn == 1) {
              gameRoom.playerTwoSocket.write(response);
              gameRoom.playerOneSocket.write(ack);
              gameRoom.playerTurn = 2;
            } else {
              gameRoom.playerOneSocket.write(response);
              gameRoom.playerTwoSocket.write(ack);
              gameRoom.playerTurn = 1;
            }
          }
          break;
        case "DISCONNECT":
          String selectedGameRoom = payload['data']['room'];
          int playerNumber = int.parse(payload['data']['player']);

          GameRoom gameRoom =
              gameRooms.where((g) => g.name == selectedGameRoom).toSet().first;
          if (playerNumber == 1) {
            gameRoom.playerOneSocket.destroy();
            gameRoom.isPlayerOneConnected = false;
          } else if (playerNumber == 2) {
            gameRoom.playerTwoSocket.destroy();
            gameRoom.isPlayerTwoConnected = false;
          }
          if (!gameRoom.isPlayerOneConnected &&
              !gameRoom.isPlayerTwoConnected) {
            gameRooms.removeWhere((g) => g.name == selectedGameRoom);
          }
          break;
      }
    },
  );
}
