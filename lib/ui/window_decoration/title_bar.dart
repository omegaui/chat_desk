import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chat_desk/io/app_style.dart';
import 'package:chat_desk/io/server_handler.dart';
import 'package:chat_desk/main.dart';
import 'package:chat_desk/ui/screens/app_info_screen.dart';
import 'package:chat_desk/ui/screens/home_screen.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const AppInfoScreen())),
                    child: Hero(
                      tag: 'icon',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const Image(
                          image: AssetImage('assets/icon/app_icon_64.png'),
                          width: 36,
                          height: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Welcome to Chat Desk",
                    style: TextStyle(
                        fontFamily: "Sen",
                        fontSize: 18,
                        color: currentStyle.getTextColor()),
                  ),
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Hero(
                        tag: 'buttons',
                        child: WindowButtons(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(height: 40, child: MoveWindow()),
          ),
        ],
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        AppUtils.buildTooltip(
          text: "Navigate to ChatRoom",
          child: WindowButton(
            color: Colors.blueAccent,
            onPressed: () {
              if (!inChatRoom() && connectedToServer) {
                push(chatRoom);
              }
            },
          ),
        ),
        AppUtils.buildTooltip(
          text: "Minimize",
          child: WindowButton(
            color: Colors.yellow,
            onPressed: () => appWindow.minimize(),
          ),
        ),
        AppUtils.buildTooltip(
          text: "Maximize/Restore",
          child: WindowButton(
            color: Colors.green,
            onPressed: () => appWindow.maximizeOrRestore(),
          ),
        ),
        AppUtils.buildTooltip(
          text: "Quit",
          child: WindowButton(
            color: Colors.red,
            onPressed: () {
              serverHandler?.requestClose();
              appWindow.close();
            },
          ),
        ),
      ],
    );
  }
}

class WindowButton extends StatefulWidget {
  const WindowButton({super.key, required this.color, required this.onPressed});

  final Color color;
  final VoidCallback onPressed;

  @override
  State<WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<WindowButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() => hover = true),
      onExit: (e) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: hover ? widget.color.withOpacity(0.5) : widget.color,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: hover ? 5 : 0,
              height: hover ? 5 : 0,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ),
    );
  }
}
