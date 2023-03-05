import 'dart:convert';

import 'package:chat_desk/core/client/client.dart';
import 'package:chat_desk/core/io/logger.dart';
import 'package:chat_desk/core/io/message.dart';
import 'package:chat_desk/core/server/server.dart';
import 'package:shelf_plus/shelf_plus.dart';

List<Client> clients = [];
List<Message> messages = [];
Map<String, WebSocketSession> sessionMap = {};
Map<String, String> clientsOnSameChats = {};
Map<String, String> companions = {};

WebSocketSession clientJoinEvent(String raw) {
  Client client = Client.fromParameter(raw);
  if (client.authenticate(code)) {
    if (sessionMap.containsKey(client.id)) {
      var session = WebSocketSession();
      Future.delayed(const Duration(seconds: 2), () {
        session.send(createResponse(
            connectionRefused, "Connection Refused by the server!",
            cause: userAlreadyExist));
        session.close();
      });
      return session;
    }
    return WebSocketSession(
        onOpen: (session) => notifyJoinOf(session, client),
        onClose: (session) => notifyExitOf(session, client),
        onMessage: (session, data) => handleRequests(session, client, data));
  } else {
    var session = WebSocketSession();
    Future.delayed(const Duration(seconds: 2), () {
      session.send(createResponse(
          connectionRefused, "Connection Refused by the server!",
          cause: unauthorized));
      session.close();
    });
    return session;
  }
}

dynamic userListFetchEvent(String raw) {
  Client client = Client.fromParameter(raw);
  if (client.authenticate(code)) {
    dynamic users = clients.where((cx) => cx.id != client.id).toList();
    return Uri.encodeFull({"\"users\"": users}.toString());
  } else {
    return {"type": "server-response", "code": unauthorized};
  }
}

void notifyJoinOf(WebSocketSession session, Client client) {
  clients.add(client);
  sessionMap.putIfAbsent(client.id, () => session);
  Future.delayed(const Duration(seconds: 2), () {
    session.send(
        createResponse(connectionEstablished, "Connected to the server!"));
    sessionMap.forEach((otherID, otherSession) {
      if (otherID != client.id) {
        otherSession.send(createResponse(clientJoined, client.id));
      }
    });
  });
}

void notifyExitOf(WebSocketSession session, Client client) {
  session.close();
  clients.remove(client);
  sessionMap.remove(client.id);
  sessionMap.forEach((otherID, otherSession) {
    otherSession.send(createResponse(clientExited, client.id));
  });
}

void handleRequests(WebSocketSession session, Client client, String source) {
  dynamic data = jsonDecode(source);
  if (data['type'] == 'text') {
    var time = DateTime.now();
    messages.add(Message(
        sender: client.id,
        message: data["message"],
        receiver: data['receiver'],
        time: "${time.hour}:${time.minute}"));
    if (data['receiver'] == "*") {
      sessionMap.forEach((otherID, otherSession) {
        if (otherID != client.id) {
          otherSession.send(sendMessage(client.id, data["message"]));
        }
      });
    } else {
      sessionMap[data['receiver']]
          ?.send(sendMessage(client.id, data["message"]));
    }
  } else if (data['type'] == 'request') {
    if (data['code'] == fetchMessages) {
      String otherID = data['with-id'];
      session.send(createResponse(
          fetchMessages,
          messages
              .where((m) => m.between(client.id, otherID))
              .toList()
              .toString(),
          cause: otherID));
    }
  } else if (data['type'] == 'client-side-change') {
    if (data['code'] == chatSwitched) {
      clientsOnSameChats.update(client.id, (value) => data['with-id'],
          ifAbsent: () => data['with-id']);
      sessionMap.forEach((id, session) {
        session.send(createResponse(chatCompanion, clientsOnSameChats));
      });
    }
  } else if (data['type'] == 'server-termination') {
    serverContext.close();
  }
}

void terminateAllSessions() {
  for (var session in sessionMap.values) {
    session.send(createResponse(serverClosing, "Session Terminated"));
    session.close();
  }
}
