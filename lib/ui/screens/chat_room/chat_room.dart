import 'dart:convert';

import 'package:chat_desk/core/io/logger.dart';
import 'package:chat_desk/io/server_handler.dart';
import 'package:chat_desk/main.dart';
import 'package:chat_desk/ui/screens/chat_room/chat_area.dart';
import 'package:chat_desk/ui/screens/chat_room/user_tabs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

GlobalKey<UserTabsState> userTabKey = GlobalKey();
ChatArea? currentChatArea;

void chatWith(ChatArea? area) {
  if (area == null) {
    thisClient.notifyChange(jsonEncode(
        {"type": "client-side-change", "code": chatSwitched, "with-id": ""}));
  }
  currentChatArea = area;
  chatRoomKey.currentState?.rebuild(area);
}

void refreshUserTabs() async {
  try {
    var response = await http.get(Uri.parse(
        'http://$superHost:$superPort/onboard/${thisClient.toString()}'));
    var urlDecoded = Uri.decodeFull(response.body);
    userTabKey.currentState?.rebuild(users: jsonDecode(urlDecoded)['users']);
  } on Exception {}
}

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatRoom> {
  ChatArea? chatArea;

  void rebuild(ChatArea? area) {
    setState(() {
      chatArea = area;
    });
  }

  Widget _buildEmptyPage() {
    return Column(
      key: const ValueKey("2"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/lottie-animations/chat.json', width: 250),
        Text(
          "Click any user to start chatting",
          style: TextStyle(
              fontFamily: "Itim",
              fontSize: 22,
              color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: const [
              IconButton(
                onPressed: pop,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
                splashRadius: 15,
              ),
              Text(
                "Your Chat Room",
                style: TextStyle(
                  fontFamily: "Sen",
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(width: 300, child: UserTabs(key: userTabKey)),
              const SizedBox(width: 5),
              Expanded(
                  child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: chatArea ?? _buildEmptyPage(),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
