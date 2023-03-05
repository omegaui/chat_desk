import 'dart:convert';
import 'dart:io';

import 'package:chat_desk/core/client/client.dart';
import 'package:chat_desk/core/io/app_manager.dart';
import 'package:chat_desk/core/io/logger.dart';
import 'package:chat_desk/core/io/message.dart';
import 'package:chat_desk/main.dart';
import 'package:chat_desk/ui/screens/chat_room/chat_room.dart';
import 'package:chat_desk/ui/screens/chat_room/user_tabs.dart';
import 'package:chat_desk/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';

ServerHandler? serverHandler;
late Client thisClient;
String? companionID = "";

var superHost = "127.0.0.1";
var superPort = 8080;

class ServerHandler {
  final String host;
  final int port;
  late Process _serverProcess;

  ServerHandler(this.host, this.port);

  void start(Function onStartComplete, Function onStartFailed) async {
    _serverProcess =
        await Process.start('dart', ["lib/core/server/server.dart"]);
    _serverProcess.stdout.transform(utf8.decoder).forEach((response) {
      try {
        dynamic log = jsonDecode(response);
        if (log['type'] == 'server-response') {
          int code = log['code'];
          if (code == initSuccess) {
            onStartComplete.call();
          } else if (code == initError) {
            serverHandler = null;
            onStartFailed.call();
          }
        }
      } on Exception {
        print(response);
      }
    });
  }

  void requestClose() {
    thisClient.request(jsonEncode({"type": "server-termination"}));
  }
}

Future<void> hostServer(String host, int port, String code,
    {onStartComplete, onStartFailed}) async {
  File("server-config.json").writeAsStringSync(
      jsonEncode({"host": host, "port": port, "code": code}));
  serverHandler = ServerHandler(host, port);
  serverHandler?.start(onStartComplete, onStartFailed);
}

void joinServer(String host, int port,
    {Function(String host, int port)? onJoinSuccess,
    Function(dynamic)? onJoinError}) {
  superHost = host;
  superPort = port;
  thisClient = Client(
    id: AppManager.getUsername(),
    description: AppManager.getDescription(),
    code: codeController.text,
    avatar: base64UrlEncode(
        File(AppManager.getAvatar() as String).readAsBytesSync()),
  );

  thisClient.connect(host, port, (message) {
    debugPrint("response from server: $message");
    dynamic response = jsonDecode(message);
    if (response['type'] == 'server-response') {
      if (response['code'] == connectionEstablished) {
        setStatus(response['message'], Colors.blue);
        onJoinSuccess?.call(host, port);
      } else if (response['code'] == connectionRefused) {
        setStatus(response['message'], Colors.red);
        onJoinError?.call(response);
      } else if (response['code'] == clientJoined) {
        refreshUserTabs();
      } else if (response['code'] == clientExited) {
        refreshUserTabs();
      } else if (response['code'] == fetchMessages) {
        String messageSource = response['message'];
        dynamic messagesData = jsonDecode(messageSource);
        List<Message> messages = [];
        messagesData.forEach((m) => messages.add(Message.fromJSON(m)));
        chatKeys[response['cause']]?.currentState?.rebuild(messages);
      } else if (response['code'] == chatCompanion) {
        var companionMap = response['message'];
        for (var id in chatKeys.keys) {
          chatKeys[id]
              ?.currentState
              ?.rebuildDock(companionMap[companionMap[id]] == id);
        }
      } else if (response['code'] == serverClosing) {
        connectedToServer = false;
        pop();
        Future.delayed(const Duration(seconds: 1), () {
          setStatus(response['message'], Colors.indigo);
        });
      }
    } else if (response['type'] == 'text') {
      chatKeys[response['sender']]
          ?.currentState
          ?.pushToChat(response['message']);
    }
  });
}
