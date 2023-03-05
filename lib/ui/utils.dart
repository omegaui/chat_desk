import 'package:flutter/material.dart';

class AppUtils {
  static late BuildContext context;

  static Tooltip buildTooltip(
      {String? text, Widget? child, EdgeInsets? margin}) {
    return Tooltip(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(6, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(-6, -6),
          ),
        ],
      ),
      message: text,
      textAlign: TextAlign.center,
      textStyle:
          const TextStyle(fontFamily: "Sen", fontSize: 14, color: Colors.white),
      preferBelow: true,
      padding: const EdgeInsets.all(10),
      margin: margin,
      child: child,
    );
  }

  static Color getColorForUsername(String username) {
    if (!username.startsWith('_') && !username.startsWith('\$')) {
      int codeUnit = username.codeUnitAt(0);
      if (codeUnit >= 48 && codeUnit <= 57) {
        return Colors.teal;
      } else {
        return Colors.blueAccent;
      }
    }
    return Colors.pinkAccent;
  }
}
