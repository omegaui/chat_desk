import 'dart:convert';
import 'dart:io';

import 'package:chat_desk/core/io/logger.dart';
import 'package:chat_desk/core/server/server_events.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:http/http.dart' as http;

late ShelfRunContext serverContext;

var host = "127.0.0.1";
var port = 8080;
var code = "";

void main() async {
  dynamic config = jsonDecode(File("server-config.json").readAsStringSync());
  serverContext = await shelfRun(_initServer,
      defaultBindAddress: config['host'],
      defaultBindPort: config['port'],
      onStartFailed: (e) =>
          streamLog(initError, "Cannot Launch Server at this address!"),
      onStarted: (address, portNumber) {
        host = address.toString();
        port = portNumber;
        code = config['code'];
        streamLog(initSuccess, "Server Started Successfully! $address");
      },
      onWillClose: () {
        terminateAllSessions();
      });
}

Handler _initServer() {
  var server = Router().plus;
  server.get('/ping', () => Response.ok("chat_desk_server"));
  server.get("/connect/<client>",
      (Request request, String raw) => clientJoinEvent(raw));
  server.get("/onboard/<client>",
      (Request request, String raw) => userListFetchEvent(raw));
  return server;
}

void closeServer() async {
  await serverContext.close();
}

Future<bool> doesServerExists(String host, int port) async {
  try {
    var response = await http.get(Uri.parse("http://$host:$port/ping"));
    return response.statusCode == 200;
  } on Exception {
    return false;
  }
}
