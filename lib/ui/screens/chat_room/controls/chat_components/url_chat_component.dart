import 'package:any_link_preview/any_link_preview.dart';
import 'package:chat_desk/core/io/message.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UrlChatComponent extends StatefulWidget {
  const UrlChatComponent({super.key, required this.message});

  final Message message;

  @override
  State<UrlChatComponent> createState() => _UrlChatComponentState();
}

class _UrlChatComponentState extends State<UrlChatComponent> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    if (true) {
      return Container(
        width: 400,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: AnyLinkPreview(
          link: widget.message.message,
          backgroundColor: Colors.grey.shade900,
          boxShadow: const [],
          bodyStyle: TextStyle(
            fontFamily: "Sen",
            color: Colors.grey.shade400,
          ),
          titleStyle: const TextStyle(
            fontFamily: "Itim",
            color: Colors.white,
            fontSize: 16,
          ),
          errorWidget: MouseRegion(
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
                  color:
                      hover ? Colors.grey.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: AppUtils.buildTooltip(
                    text: "Click to Open URl",
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.preview,
                          color: Colors.red.withOpacity(0.7),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message.message,
                            style: const TextStyle(
                                fontFamily: "Sen",
                                fontSize: 15,
                                color: Colors.greenAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          placeholderWidget: MouseRegion(
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
                  color:
                      hover ? Colors.grey.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: AppUtils.buildTooltip(
                    text: "Click to Open URl",
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator()),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message.message,
                            style: const TextStyle(
                                fontFamily: "Sen",
                                fontSize: 15,
                                color: Colors.greenAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
