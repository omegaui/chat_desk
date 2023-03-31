import 'dart:convert';
import 'dart:io';

import 'package:chat_desk/core/client/client.dart';
import 'package:chat_desk/core/io/logger.dart';
import 'package:chat_desk/core/io/message.dart';
import 'package:chat_desk/io/app_style.dart';
import 'package:chat_desk/io/server_handler.dart';
import 'package:chat_desk/ui/screens/chat_room/chat_room.dart';
import 'package:chat_desk/ui/screens/chat_room/controls/chat.dart';
import 'package:chat_desk/ui/screens/chat_room/controls/chat_components/lottie_button.dart';
import 'package:chat_desk/ui/screens/chat_room/user_tabs.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:file_picker/file_picker.dart';
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

  void pushToChat(String id, String type, dynamic message) {
    setState(() {
      var time = DateTime.now();
      messages.add(Message(
          id: id,
          type: type,
          sender: widget.client.id,
          message: message,
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

  @override
  void dispose() {
    scrollController.dispose();
    messageController.dispose();
    super.dispose();
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
                  style: TextStyle(
                      fontFamily: "Sen",
                      fontSize: 20,
                      color: currentStyle.getTextColor()),
                ),
              ),
              OnlineTracker(
                key: onlineTrackerKey,
                client: widget.client,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AppUtils.buildTooltip(
                        text: "Scroll to bottom",
                        child: Transform.rotate(
                          angle: -1.5708,
                          child: IconButton(
                            onPressed: slideDown,
                            icon: const Icon(
                              Icons.keyboard_double_arrow_left,
                              color: Colors.grey,
                            ),
                            iconSize: 32,
                            splashRadius: 25,
                          ),
                        ),
                      ),
                    ),
                    Padding(
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
                  ],
                ),
              )
            ],
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: _buildChats(),
                ))),
        const SizedBox(height: 20),
        SizedBox(
          height: 60,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: currentStyleMode == AppStyle.dark
                        ? Colors.grey.shade800.withOpacity(0.1)
                        : Colors.white.withOpacity(0.7),
                    width: MediaQuery.of(context).size.width - 460,
                    child: TextField(
                      controller: messageController,
                      cursorColor: Colors.greenAccent,
                      textInputAction: TextInputAction.none,
                      onTap: () {
                        thisClient.notifyCompanionSwitch(widget.client.id);
                        messageArrivedMap.update(
                            widget.client.id, (value) => false,
                            ifAbsent: () => false);
                        userTabKey.currentState?.rebuild();
                      },
                      onSubmitted: (value) {
                        setState(() {
                          var time = DateTime.now();
                          thisClient.transmit(
                              widget.client.id,
                              messageController.text,
                              "${thisClient.id}:${widget.client.id}>$time");
                          messages.add(Message(
                              id: "${thisClient.id}:${widget.client.id}>$time",
                              type: "text",
                              sender: thisClient.id,
                              message: messageController.text.trim(),
                              receiver: widget.client.id,
                              time: "${time.hour}:${time.minute}"));
                          messageController.text = "";
                        });
                      },
                      style: TextStyle(
                        fontFamily: "Sen",
                        fontSize: 15,
                        color: currentStyle.getTextColor(),
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
                              color: currentStyleMode == AppStyle.dark
                                  ? Colors.grey.shade800.withOpacity(0.7)
                                  : Colors.grey.withOpacity(0.7),
                              width: 2),
                        ),
                        hintText: "Type your message here ...",
                        hintStyle: TextStyle(
                          fontFamily: "Itim",
                          fontSize: 18,
                          color: currentStyle.getTextColor().withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              AppUtils.buildTooltip(
                text: "Send Images",
                child: LottieButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      dialogTitle: "Pick Images to send to ${widget.client.id}",
                      type: FileType.image,
                      allowMultiple: true,
                    );
                    if (result != null) {
                      for (var path in result.paths) {
                        var time = DateTime.now();
                        var data =
                            base64UrlEncode(File(path!).readAsBytesSync());
                        thisClient.transmit(widget.client.id, data,
                            "${thisClient.id}:${widget.client.id}>$time",
                            type: "image");
                        messages.add(Message(
                            id: "${thisClient.id}:${widget.client.id}>$time",
                            type: "image",
                            sender: thisClient.id,
                            message: data,
                            receiver: widget.client.id,
                            time: "${time.hour}:${time.minute}"));
                        setState(() {});
                      }
                    }
                  },
                  lottieAnimationPath: "assets/lottie-animations/image.json",
                ),
              ),
              const SizedBox(width: 5),
              AppUtils.buildTooltip(
                text: "Send Files",
                child: LottieButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      dialogTitle: "Pick Files to send to ${widget.client.id}",
                      allowMultiple: true,
                    );
                    if (result != null) {
                      for (var path in result.paths) {
                        if (!AppUtils.isBinary(path!)) {
                          var time = DateTime.now();
                          var data = AppUtils.generateFileMetadata(path);
                          thisClient.transmit(widget.client.id, data,
                              "${thisClient.id}:${widget.client.id}>$time",
                              type: "text-file");
                          messages.add(Message(
                              id: "${thisClient.id}:${widget.client.id}>$time",
                              type: "text-file",
                              sender: thisClient.id,
                              message: data,
                              receiver: widget.client.id,
                              time: "${time.hour}:${time.minute}"));
                          setState(() {});
                        }
                      }
                    }
                  },
                  lottieAnimationPath: "assets/lottie-animations/file.json",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChats() {
    List<Widget> chats = [];
    for (Message message in messages) {
      chats.add(Chat(message: message));
    }
    slideDown();
    return chats;
  }

  void slideDown() {
    if (scrollController.positions.isNotEmpty) {
      scrollController.animateTo(scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 132,
      decoration: BoxDecoration(
        color: currentStyleMode == AppStyle.dark
            ? Colors.grey.shade800.withOpacity(0.1)
            : Colors.white.withOpacity(0.7),
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: _buildSession(),
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
    return Text(
      "(Offline)",
      style: TextStyle(
          fontFamily: "Sen",
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: currentStyle.getTextColor()),
    );
  }
}
