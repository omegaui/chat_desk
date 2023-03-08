import 'package:chat_desk/core/io/message.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UrlChatControl extends StatefulWidget {
  const UrlChatControl({super.key, required this.message});

  final Message message;

  @override
  State<UrlChatControl> createState() => _UrlChatControlState();
}

class _UrlChatControlState extends State<UrlChatControl> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (e) => setState(() => hover = true),
        onExit: (e) => setState(() => hover = false),
        child: GestureDetector(
          onTap: () async {
            if (await canLaunchUrlString(widget.message.message)) {
              launchUrlString(widget.message.message);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: hover ? Colors.grey.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: AppUtils.buildTooltip(
                text: "Click to Open URl",
                child: Text(
                  widget.message.message,
                  style: const TextStyle(
                      fontFamily: "Sen",
                      fontSize: 15,
                      color: Colors.greenAccent),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
