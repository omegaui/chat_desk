import 'package:chat_desk/core/io/app_manager.dart';
import 'package:flutter/material.dart';

abstract class AppStyle {
  static const light = "light-mode";
  static const dark = "dark-mode";

  Color getBackground();
  Color getTextColor();
}

class LightStyle extends AppStyle {
  @override
  Color getBackground() {
    return const Color(0xFFEEF3FA);
  }

  @override
  Color getTextColor() {
    return Colors.grey.shade800;
  }
}

class DarkStyle extends AppStyle {
  @override
  Color getBackground() {
    return Colors.grey.shade900;
  }

  @override
  Color getTextColor() {
    return Colors.grey.shade300;
  }
}

get currentStyle => AppStyleManager._style;

class AppStyleManager {
  static late AppStyle _style;

  static get currentStyle => _style;

  static void init() {
    _style = AppManager.getStyleMode() == AppStyle.light
        ? LightStyle()
        : DarkStyle();
  }

  static void switchStyle(String styleMode) {
    if (styleMode == AppStyle.light) {
      _style = LightStyle();
    } else if (styleMode == AppStyle.dark) {
      _style = DarkStyle();
    }
  }
}
