import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chat_desk/core/io/app_manager.dart';
import 'package:chat_desk/ui/screens/chat_room/chat_room.dart';
import 'package:chat_desk/ui/screens/home_screen.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:chat_desk/ui/window_decoration/title_bar.dart';
import 'package:flutter/material.dart';

GlobalKey<ContentPaneState> contentPaneKey = GlobalKey();
GlobalKey<ChatRoomState> chatRoomKey = GlobalKey();

var chatRoom = ChatRoom(key: chatRoomKey);

bool inChatRoom() {
  return contentPaneKey.currentState?.content == chatRoom;
}

void push(Widget? screen) {
  contentPaneKey.currentState?.changeTo(screen);
}

void pop() {
  contentPaneKey.currentState?.pop();
}

void main() async {
  await AppManager.initAppData();

  runApp(const App());

  doWhenWindowReady(() {
    appWindow.minSize = const Size(800, 650);
    appWindow.maxSize = const Size(800, 650);
    appWindow.size = const Size(800, 650);
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    AppUtils.context = context;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.grey.shade900,
          body: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TitleBar(),
                    Expanded(
                      child: ContentPane(
                        key: contentPaneKey,
                        content: const HomeScreen(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentPane extends StatefulWidget {
  const ContentPane({super.key, this.content});

  final Widget? content;

  @override
  State<ContentPane> createState() => ContentPaneState();
}

class ContentPaneState extends State<ContentPane> {
  Widget? content;
  List<Widget> contents = [];

  @override
  void initState() {
    if (widget.content != null) {
      content = widget.content;
      contents.add(content as Widget);
    }
    super.initState();
  }

  void changeTo(Widget? newContent) {
    setState(() {
      if (content != null) {
        contents.add(content as Widget);
      }
      content = newContent;
    });
  }

  void pop() {
    if (contents.length >= 2) {
      setState(() {
        content = contents.elementAt(contents.length - 2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: content,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}