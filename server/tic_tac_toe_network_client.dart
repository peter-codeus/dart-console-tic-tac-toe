import 'dart:async';
import 'dart:io';
import 'dart:convert' as converter;
import 'constants.dart';
import 'protocol_transformer.dart';

void main() async {
  var client = TicTacToeNetworkClient();
  await client.init();
  dynamic response = await client.createGameRoom('New Game Room 2');
  // dynamic response = await client.findGameRooms();
  print(response);
  // client.close();
}

class TicTacToeNetworkClient {
  Socket clientSocket;
  Completer completer;
  StreamSubscription clientSubscription;

  TicTacToeNetworkClient() {
    // print('Network client started');
  }

  void init() async {
    // print('Initializing Client');
    try {
      clientSocket = await Socket.connect(SERVER_ADDRESS, SERVER_PORT);
      clientSubscription = clientSocket
          .transform(ProtocolTransformer())
          .listen(onData, onError: onError, onDone: onDone);
      // socketWriter('{"req": "GAMEROOMS"}.');
      // socketWriter('command 1');
      // socketWriter('command 2');

    } catch (e) {
      rethrow;
    }

    // await Future.delayed(Duration(seconds: 10),);
  }

  Future<dynamic> printToServer(String data) {
    if (clientSocket != null) {
      completer = Completer();
      clientSocket.write(data);
      return completer.future;
    }
    return null;
  }

  Future<dynamic> findGameRooms() async {
    return await this.printToServer('{"req": "GAMEROOMS"}.');
  }

  Future<dynamic> joinGameRoom(String roomName) async {
    return await this
        .printToServer('{"req": "JOIN_ROOM", "data": "$roomName"}.');
  }

  Future<dynamic> createGameRoom(String roomName) async {
    return await this
        .printToServer('{"req": "CREATE_ROOM", "data": "$roomName"}.');
  }

  Future<dynamic> getCellPosition() async
  {
    return await this.printToServer('{"req": "RECV_PLAY"}.');
  }

  Future<dynamic> sendCellPosition(String gameRoom, int position) async
  {
    return await this.printToServer('{"req": "SEND_PLAY", "data": {"pos": "$position", "room": "$gameRoom"}}.');
  }

  Future<dynamic> waitOtherPlayer() async {
    completer = Completer();
    return completer.future;
  }

  Future<dynamic> disconnect(String roomName, int playerNumber) async
  {
    return await this.printToServer('{"req": "DISCONNECT", "data": {"room": "$roomName", "player": "$playerNumber"}}.');
  }

  onData(data) {
    var serverData = converter.jsonDecode(data);
    if (serverData['error'] != null)
      completer.completeError(serverData['error']);
    else
      completer.complete(serverData);
    completer = null;
  }

  onError(error) {
    print(error);
  }

  onDone() {
    completer.complete(null);
    // print('Done ... transmitting data');
  }

  void close() {
    if (clientSocket != null) {
      clientSocket.destroy();
    }
  }

}
