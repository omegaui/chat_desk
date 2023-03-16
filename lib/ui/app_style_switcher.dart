import 'package:chat_desk/io/app_manager.dart';
import 'package:chat_desk/io/app_style.dart';
import 'package:chat_desk/ui/utils.dart';
import 'package:flutter/material.dart';

class AppStyleSwitcher extends StatelessWidget {
  const AppStyleSwitcher({super.key});

  Icon _getIcon() {
    if (currentStyleMode == AppStyle.dark) {
      return const Icon(
        Icons.nights_stay_rounded,
        color: Colors.deepPurple,
      );
    }
    return Icon(
      Icons.sunny,
      color: Colors.yellow.shade900,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppUtils.buildTooltip(
      text: "Requires App Restart",
      child: IconButton(
        onPressed: () async {
          AppStyleManager.switchStyle(currentStyleMode == AppStyle.light
              ? AppStyle.dark
              : AppStyle.light);
          await AppManager.preferences
              .setString("style-mode", currentStyleMode);
        },
        icon: _getIcon(),
        iconSize: 48,
        splashRadius: 35,
        highlightColor: Colors.grey.withOpacity(0.1),
        splashColor: Colors.white.withOpacity(0.1),
      ),
    );
  }
}
