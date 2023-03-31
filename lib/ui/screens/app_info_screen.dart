import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chat_desk/io/app_style.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:flutter/material.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentStyle.getBackground(),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 250),
                  Hero(
                    tag: 'icon',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/icon/app_icon_256.png",
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "chat desk",
                    style: TextStyle(
                      fontFamily: "Audiowide",
                      fontSize: 32,
                      color: currentStyle.getTextColor(),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "beta-release v0.8",
                    style: TextStyle(
                      fontFamily: "Sen",
                      fontSize: 20,
                      color: currentStyle.getTextColor(),
                    ),
                  ),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "written with ❤️ by",
                        style: TextStyle(
                          fontFamily: "Sen",
                          fontSize: 18,
                          color: currentStyle.getTextColor(),
                        ),
                      ),
                      Hero(
                        tag: 'buttons',
                        child: AnimatedTextKit(
                          animatedTexts: [
                            ColorizeAnimatedText(
                              "omegaui",
                              textStyle: TextStyle(
                                fontFamily: "Audiowide",
                                fontSize: 22,
                                color: currentStyle.getTextColor(),
                              ),
                              colors: [
                                Colors.pink,
                                Colors.grey,
                                Colors.blue,
                                Colors.white,
                              ],
                            ),
                          ],
                          isRepeatingAnimation: true,
                          repeatForever: true,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ))
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Container(

                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: AppUtils.buildTooltip(
                  text: "Close",
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: currentStyle.getTextColor(),
                    ),
                    iconSize: 24,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: MoveWindow(),
            )
          ],
        ),
      ),
    );
  }
}
