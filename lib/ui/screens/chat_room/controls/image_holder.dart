import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:chat_desk/core/io/message.dart';
import 'package:chat_desk/ui/screens/chat_room/controls/image_preview.dart';
import 'package:chat_desk/ui/screens/chat_room/user_tabs.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Map<String, Uint8List> imageCache = {};

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
          width = max(96, image.image.width.toDouble());
          height = max(96, image.image.height.toDouble());
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: min(300, width),
        height: min(250, height),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImagePreview(
                              message: widget.message,
                              imageBytes: _getImage())));
                },
                child: Container(
                  width: 480,
                  height: 270,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(10),
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
            Align(
              alignment: Alignment.center,
              child: AnimatedOpacity(
                opacity: hover ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: AppUtils.buildTooltip(
                  text: "Save to Disk",
                  child: IconButton(
                    onPressed: () async {
                      String? result = await FilePicker.platform.saveFile(
                          type: FileType.image,
                          dialogTitle: "Select a directory",
                          fileName: "img_${widget.message.time}.png");
                      if (result != null) {
                        File(result).writeAsBytesSync(_getImage(), flush: true);
                        notify("Image Saved", Colors.greenAccent);
                      }
                    },
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
