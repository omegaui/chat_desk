import 'dart:convert';

import 'package:chat_desk/core/client/client.dart';
import 'package:chat_desk/core/io/logger.dart';
import 'package:chat_desk/core/io/message.dart';
import 'package:chat_desk/io/server_handler.dart';
import 'package:chat_desk/ui/screens/chat_room/chat_room.dart';
import 'package:chat_desk/ui/screens/chat_room/user_tabs.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ChatArea extends StatefulWidget {
  const ChatArea({
    super.key,
    required this.client,
  });

  final Client client;

  @override
  State<ChatArea> createState() => ChatAreaState();
}

class ChatAreaState extends State<ChatArea> {
  List<Message> messages = [];
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  GlobalKey<OnlineTrackerState> onlineTrackerKey = GlobalKey();

  void rebuild(List<Message> messages) {
    setState(() {
      this.messages = messages;
    });
  }

  void rebuildDock(bool value) {
    onlineTrackerKey.currentState?.rebuild(value);
  }

  void pushToChat(String text) {
    setState(() {
      var time = DateTime.now();
      messages.add(Message(
          type: "text",
          sender: widget.client.id,
          message: text,
          receiver: thisClient.id,
          time: "${time.hour}:${time.minute}"));
    });
  }

  @override
  void initState() {
    thisClient.request(jsonEncode({
      "type": "request",
      "code": fetchMessages,
      "with-id": widget.client.id,
    }));
    super.initState();
  }

  Widget _buildSession() {
    return Column(
      key: const ValueKey("1"),
      children: [
        SizedBox(
          height: 60,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image(
                  image: avatarCache[widget.client.id] as MemoryImage,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.client.id,
                  style: const TextStyle(
                      fontFamily: "Sen", fontSize: 20, color: Colors.white),
                ),
              ),
              OnlineTracker(
                key: onlineTrackerKey,
                client: widget.client,
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppUtils.buildTooltip(
                    text: "Close Chat!",
                    child: IconButton(
                      onPressed: () => chatWith(null),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                      ),
                      iconSize: 20,
                      splashRadius: 20,
                    ),
                  ),
                ),
              ))
            ],
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: _buildChats(),
                ))),
        SizedBox(
          height: 60,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.grey.shade800.withOpacity(0.1),
                    width: 400,
                    child: TextField(
                      controller: messageController,
                      cursorColor: Colors.greenAccent,
                      textInputAction: TextInputAction.none,
                      onSubmitted: (value) {
                        thisClient.transmit(
                            widget.client.id, messageController.text);
                        setState(() {
                          var time = DateTime.now();
                          messages.add(Message(
                              type: "text",
                              sender: thisClient.id,
                              message: messageController.text,
                              receiver: widget.client.id,
                              time: "${time.hour}:${time.minute}"));
                          messageController.text = "";
                        });
                      },
                      style: const TextStyle(
                        fontFamily: "Sen",
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: Colors.grey.shade800.withOpacity(0.7),
                              width: 2),
                        ),
                        hintText: "Type your message here ...",
                        hintStyle: TextStyle(
                          fontFamily: "Itim",
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Transform.rotate(
                angle: -0.65,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.grey,
                  ),
                  iconSize: 30,
                  splashRadius: 25,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  List<Widget> _buildChats() {
    List<Widget> chats = [];
    for (Message message in messages) {
      chats.add(Chat(message: message));
    }
    if (scrollController.positions.isNotEmpty) {
      scrollController.animateTo(scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic);
    }
    return chats;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 132,
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: _buildSession(),
    );
  }
}

class Chat extends StatelessWidget {
  const Chat({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: message.sender == thisClient.id
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (message.sender == thisClient.id)
          Text(
            message.time,
            style: TextStyle(
                fontFamily: "Sen",
                fontSize: 14,
                color: Colors.grey.withOpacity(0.6)),
          ),
        if (message.type == 'text')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              message.message,
              style: const TextStyle(
                  fontFamily: "Sen", fontSize: 16, color: Colors.white),
            ),
          ),
        if (message.type == 'image')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Container(
              width: 300,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(9, 9)),
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(-9, -9)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  base64Url.decode(message.message),
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
        if (message.sender != thisClient.id)
          Text(
            message.time,
            style: TextStyle(
                fontFamily: "Sen",
                fontSize: 14,
                color: Colors.grey.withOpacity(0.6)),
          ),
      ],
    );
  }
}

class OnlineTracker extends StatefulWidget {
  const OnlineTracker({super.key, required this.client});

  final Client client;

  @override
  State<OnlineTracker> createState() => OnlineTrackerState();
}

class OnlineTrackerState extends State<OnlineTracker> {
  bool show = false;

  void rebuild(bool show) => setState(() {
        this.show = show;
      });

  @override
  Widget build(BuildContext context) {
    if (show) {
      return Lottie.asset('assets/lottie-animations/online.json', width: 40);
    }
    return const SizedBox();
  }
}
