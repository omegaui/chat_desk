import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:chat_desk/core/client/client.dart';
import 'package:chat_desk/core/io/logger.dart';
import 'package:chat_desk/core/io/message.dart';
import 'package:chat_desk/io/server_handler.dart';
import 'package:chat_desk/main.dart';
import 'package:chat_desk/ui/screens/chat_room/chat_room.dart';
import 'package:chat_desk/ui/screens/chat_room/user_tabs.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Map<String, Uint8List> imageCache = {};

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

  void pushToChat(String id, String type, String text) {
    setState(() {
      var time = DateTime.now();
      messages.add(Message(
          id: id,
          type: type,
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
                              id: "${thisClient.id}:${widget.client.id}>$time",
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
            child: ImageHolder(message: message),
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

class ImageHolder extends StatefulWidget {
  const ImageHolder({super.key, required this.message});

  final Message message;

  @override
  State<ImageHolder> createState() => _ImageHolderState();
}

class _ImageHolderState extends State<ImageHolder> {
  bool hover = false;

  double width = 300;
  double height = 250;

  Uint8List _getImage() {
    if (imageCache.containsKey(widget.message.id)) {
      return imageCache[widget.message.id]!;
    }
    Uint8List data = base64Url.decode(widget.message.message);
    imageCache.putIfAbsent(widget.message.id, () => data);
    MemoryImage(data).resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((image, synchronousCall) {
        setState(() {
          width = min(96, image.image.width.toDouble());
          height = min(96, image.image.height.toDouble());
        });
      }),
    );
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() => hover = true),
      onExit: (e) => setState(() => hover = false),
      child: SizedBox(
        width: min(300, width),
        height: min(250, height),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: AnimatedOpacity(
                opacity: hover ? 0.7 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: GestureDetector(
                  onTap: () {
                    push(ImagePreview(image: _getImage()));
                  },
                  child: Container(
                    width: 300,
                    height: 250,
                    decoration: BoxDecoration(
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
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 500),
                      padding: EdgeInsets.all(hover ? 8.0 : 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          _getImage(),
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: AnimatedOpacity(
                opacity: hover ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: AppUtils.buildTooltip(
                  text: "Save to Disk",
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.save_alt_rounded,
                      color: Colors.white,
                    ),
                    splashRadius: 30,
                    iconSize: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key, required this.image});

  final Uint8List image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Image.memory(
            image,
            fit: BoxFit.fitWidth,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              onPressed: () => pop(),
              icon: const Icon(
                Icons.close_fullscreen,
              ),
            ),
          ),
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
