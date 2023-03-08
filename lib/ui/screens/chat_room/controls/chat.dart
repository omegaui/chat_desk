import 'package:chat_desk/core/io/message.dart';
import 'package:chat_desk/io/server_handler.dart';
import 'package:chat_desk/ui/screens/chat_room/controls/chat_controls/url_chat_control.dart';
import 'package:chat_desk/ui/screens/chat_room/controls/image_holder.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart' as text_validator;

class Chat extends StatelessWidget {
  Chat({super.key, required this.message});

  final Message message;
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    bool isURL =
        message.type == 'text' && text_validator.isURL(message.message);
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
        if (message.type == 'text' && !isURL)
          Flexible(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                message.message,
                style: const TextStyle(
                    fontFamily: "Sen", fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        if (message.type == 'text' && isURL) UrlChatControl(message: message),
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
