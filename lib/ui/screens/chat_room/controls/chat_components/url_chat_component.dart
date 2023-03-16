import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_desk/core/io/message.dart';
import 'package:chat_desk/io/app_style.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:flutter/material.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:url_launcher/url_launcher_string.dart';

Map<String, dynamic> retrievedUrls = {};
Map<String, ImageProvider<Object>> retrievedUrlsImageCache = {};

class UrlChatComponent extends StatefulWidget {
  const UrlChatComponent({super.key, required this.message});

  final Message message;

  @override
  State<UrlChatComponent> createState() => _UrlChatComponentState();
}

class _UrlChatComponentState extends State<UrlChatComponent> {
  bool hover = false;

  Future<dynamic> _getMetaData() async {
    if (retrievedUrls.containsKey(widget.message.message)) {
      return retrievedUrls[widget.message.message];
    }
    dynamic map = await MetadataFetch.extract(widget.message.message);
    retrievedUrls.putIfAbsent(widget.message.message, () => map);
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () async {
          if (await canLaunchUrlString(widget.message.message)) {
            launchUrlString(widget.message.message);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: FutureBuilder(
                future: _getMetaData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: UrlCard(
                          key: const ValueKey("url-card"),
                          url: widget.message.message,
                          dataMap: snapshot.data!.toMap()),
                    );
                  }
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (e) => setState(() => hover = true),
                    onExit: (e) => setState(() => hover = false),
                    child: AnimatedContainer(
                      key: const ValueKey("text-card"),
                      width: snapshot.hasError ? null : 400,
                      height: snapshot.hasError ? null : 300,
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: hover
                            ? Colors.grey.withOpacity(
                                currentStyleMode == AppStyle.dark ? 0.1 : 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AppUtils.buildTooltip(
                        text: "Click to Open URl",
                        child: AnimatedTextKit(
                          animatedTexts: [
                            ColorizeAnimatedText(
                              widget.message.message,
                              colors: [
                                Colors.greenAccent,
                                Colors.cyan,
                                Colors.pinkAccent,
                              ],
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Sen",
                                  fontSize: 15,
                                  color: currentStyleMode == AppStyle.dark
                                      ? Colors.greenAccent
                                      : Colors.greenAccent.shade700),
                            ),
                          ],
                          repeatForever: !snapshot.hasError,
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}

class UrlCard extends StatelessWidget {
  const UrlCard({super.key, required this.dataMap, required this.url});

  final Map<String, String?> dataMap;
  final String url;

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? image;
    if (retrievedUrlsImageCache.containsKey(url)) {
      image = retrievedUrlsImageCache[url];
    } else {
      image = NetworkImage(dataMap['image']!);
      retrievedUrlsImageCache.putIfAbsent(url, () => image!);
    }
    return Container(
      width: 400,
      height: 300,
      decoration: BoxDecoration(
        color: currentStyle.getBackground(),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            child: Center(
              child: Image(
                image: image!,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              dataMap['title']!,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: "Sen",
                  color: currentStyle.getTextColor().withOpacity(0.8)),
            ),
          ),
          Flexible(
            child: AppUtils.buildTooltip(
              text: dataMap['description'] ?? "No Description",
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  dataMap['description'] ?? dataMap['url']!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Sen",
                      color: currentStyle.getTextColor()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
