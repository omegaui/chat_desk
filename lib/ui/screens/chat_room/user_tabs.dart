import 'dart:convert';
import 'dart:io';

import 'package:chat_desk/core/client/client.dart';
import 'package:chat_desk/core/io/app_manager.dart';
import 'package:chat_desk/core/io/logger.dart';
import 'package:chat_desk/io/server_handler.dart';
import 'package:chat_desk/ui/screens/chat_room/chat_area.dart';
import 'package:chat_desk/ui/screens/chat_room/chat_room.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:flutter/material.dart';

Map<String, MemoryImage> avatarCache = {};
Map<String, GlobalKey<ChatAreaState>> chatKeys = {};

class UserTabs extends StatefulWidget {
  const UserTabs({super.key});

  @override
  State<UserTabs> createState() => UserTabsState();
}

class UserTabsState extends State<UserTabs> {
  List<dynamic> users = [];

  @override
  void initState() {
    avatarCache.putIfAbsent(
        AppManager.getUsername(),
        () => MemoryImage(
            File(AppManager.getAvatar() as String).readAsBytesSync()));
    refreshUserTabs();
    super.initState();
  }

  void rebuild(List<dynamic> users) => setState(() {
        this.users = users;
        for (dynamic user in users) {
          var imageBytes = base64Url.decode(user['avatar']);
          avatarCache.putIfAbsent(user['id'], () => MemoryImage(imageBytes));
        }
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 132,
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            UserTab(
              userData: jsonDecode(thisClient.toString()),
              internal: true,
            ),
            ...(users.map((e) {
              return UserTab(
                userData: e,
              );
            }).toList())
          ],
        ),
      ),
    );
  }
}

class UserTab extends StatefulWidget {
  const UserTab({super.key, this.userData, this.internal = false});

  final dynamic userData;
  final bool internal;

  @override
  State<UserTab> createState() => UserTabState();
}

class UserTabState extends State<UserTab> {
  bool hover = false;
  bool _blink = false;
  late Client client;
  late ChatArea chatArea;
  GlobalKey<ChatAreaState> chatAreaKey = GlobalKey();

  void blink(bool value) {
    setState(() {
      _blink = value;
    });
  }

  @override
  void initState() {
    super.initState();
    if (!widget.internal) {
      chatArea = ChatArea(
        key: chatAreaKey,
        client: client = Client.fromJson(widget.userData),
      );
      chatKeys.update(widget.userData['id'], (value) => chatAreaKey,
          ifAbsent: () => chatAreaKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    String description = widget.userData['description'];
    bool shortedDescription = false;
    if (description.length > 25) {
      description = "${description.substring(0, 25)} ...";
      shortedDescription = true;
    }
    return GestureDetector(
      onTap: () {
        if (!(widget.internal)) {
          chatWith(chatArea);
          thisClient.notifyChange(jsonEncode({
            "type": "client-side-change",
            "code": chatSwitched,
            "with-id": client.id
          }));
        }
      },
      child: MouseRegion(
        onEnter: (e) => setState(() => hover = !(widget.internal)),
        onExit: (e) => setState(() => hover = false),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(hover ? 18.0 : 0.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A)
                  .withOpacity((widget.internal) ? 0.0 : (hover ? 0.9 : 0.2)),
              borderRadius: BorderRadius.circular(hover ? 30 : 0),
              border: hover
                  ? Border.all(
                      color:
                          AppUtils.getColorForUsername(widget.userData['id']),
                      width: 4)
                  : null,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image(
                    image: avatarCache[widget.userData["id"]] as MemoryImage,
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.userData['id'],
                          style: const TextStyle(
                              fontFamily: "Sen",
                              color: Colors.white,
                              fontSize: 16),
                        ),
                        Text(
                          (widget.internal) ? " (you)" : "",
                          style: const TextStyle(
                              fontFamily: "Itim",
                              color: Colors.white,
                              fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        if (_blink) const BlinkPoint()
                      ],
                    ),
                    AppUtils.buildTooltip(
                      text: shortedDescription
                          ? widget.userData['description']
                          : "",
                      child: Text(
                        description,
                        style: TextStyle(
                            fontFamily: "Sen",
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.62)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BlinkPoint extends StatefulWidget {
  const BlinkPoint({super.key});

  @override
  State<BlinkPoint> createState() => _BlinkPointState();
}

class _BlinkPointState extends State<BlinkPoint>
    with SingleTickerProviderStateMixin<BlinkPoint> {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
        upperBound: 0.8,
        lowerBound: 0.0);
    controller.forward();
    controller.addListener(() {
      if (controller.isCompleted) {
        controller.reverse();
      } else if (controller.isDismissed) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: (context, child) => SizedBox(
        width: 20,
        height: 20,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 28 * controller.value,
                height: 28 * controller.value,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(controller.value),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
      animation: controller,
    );
  }
}
