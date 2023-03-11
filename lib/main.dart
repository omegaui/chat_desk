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
  contentPaneKey.currentState?.changeTo(const HomeScreen());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppManager.initAppData();

  runApp(const App());

  doWhenWindowReady(() {
    appWindow.minSize = const Size(1200, 900);
    appWindow.size = const Size(1200, 900);
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    AppUtils.context = context;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
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

  @override
  void initState() {
    if (widget.content != null) {
      content = widget.content;
    }
    super.initState();
  }

  void changeTo(Widget? newContent) {
    setState(() {
      content = newContent;
    });
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
