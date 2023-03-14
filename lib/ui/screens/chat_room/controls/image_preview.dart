import 'dart:typed_data';

import 'package:chat_desk/core/io/message.dart';
import 'package:chat_desk/io/app_style.dart';
import 'package:chat_desk/ui/window_decoration/title_bar.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview(
      {super.key, required this.imageBytes, required this.message});

  final Message message;
  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentStyle.getBackground(),
      body: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: InteractiveViewer(
                    child: Image.memory(imageBytes),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_fullscreen,
                      color: currentStyle.getTextColor(),
                    ),
                    splashRadius: 30,
                    iconSize: 32,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
