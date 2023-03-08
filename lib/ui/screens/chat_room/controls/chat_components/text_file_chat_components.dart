import 'dart:io';

import 'package:chat_desk/core/io/message.dart';
import 'package:chat_desk/ui/screens/chat_room/controls/chat_components/lottie_button.dart';
import 'package:chat_desk/ui/screens/chat_room/user_tabs.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TextFileChatComponent extends StatefulWidget {
  const TextFileChatComponent({super.key, required this.message});

  final Message message;

  @override
  State<TextFileChatComponent> createState() => _TextFileChatComponentState();
}

class _TextFileChatComponentState extends State<TextFileChatComponent> {
  bool hover = false;

  void downloadFile() {
    var path =
        "${AppUtils.getUserDownloadsDirectory()}${Platform.pathSeparator}${widget.message.message['name']}";
    var file = File(path);
    if (!file.existsSync()) {
      file.writeAsStringSync(widget.message.message['data'], flush: true);
      notify("Saved to ~/Downloads", Colors.greenAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() => hover = true),
      onExit: (e) => setState(() => hover = false),
      child: GestureDetector(
        onTap: () {
          if (File(widget.message.message['path']).existsSync()) {
            launchUrlString("file://${widget.message.message['path']}");
          } else {
            downloadFile();
            launchUrlString(
                "file://${AppUtils.getUserDownloadsDirectory()}${Platform.pathSeparator}${widget.message.message['name']}");
          }
        },
        child: AppUtils.buildTooltip(
          text: "Click to Open File in Desktop",
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 300,
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(9, 9),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(-9, -9),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) =>
                      LinearGradient(colors: [Colors.blue, Colors.red.shade400])
                          .createShader(bounds),
                  child: const Icon(
                    Icons.file_copy_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 160,
                      height: 30,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30)),
                      ),
                      alignment: Alignment.center,
                      child: AppUtils.buildTooltip(
                        text: widget.message.message['name'],
                        child: Text(
                          widget.message.message['name'],
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: "Itim",
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Text(
                        AppUtils.getFileSizeString(
                            bytes: widget.message.message['size']),
                        style: const TextStyle(
                            fontFamily: "Sen",
                            color: Colors.white,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
                Expanded(
                    child: Align(
                  alignment: Alignment.centerRight,
                  child: AppUtils.buildTooltip(
                    text: "Download",
                    child: LottieButton(
                      onPressed: downloadFile,
                      lottieAnimationPath:
                          "assets/lottie-animations/download.json",
                    ),
                  ),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
