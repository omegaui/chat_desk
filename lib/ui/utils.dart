import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class AppUtils {
  static late BuildContext context;

  static String getUserHome() {
    Map<String, String> envVars = Platform.environment;
    if (Platform.isMacOS || Platform.isLinux) {
      return envVars['HOME']!;
    }
    return envVars['UserProfile']!;
  }

  static String getUserDownloadsDirectory() {
    return "${getUserHome()}${Platform.pathSeparator}Downloads";
  }

  static String getFileSizeString({required int bytes, int decimals = 1}) {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    if (bytes == 0) return '0${suffixes[0]}';
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

  static bool isBinary(String path) {
    final file = File(path);
    RandomAccessFile raf = file.openSync(mode: FileMode.read);
    Uint8List data = raf.readSync(124);
    for (final b in data) {
      if (b >= 0x00 && b <= 0x08) {
        raf.close();
        return true;
      }
    }
    raf.close();
    return false;
  }

  static dynamic generateFileMetadata(String path) {
    var file = File(path);
    return {
      "path": path,
      "name": path.substring(path.lastIndexOf(Platform.pathSeparator) + 1),
      "size": file.lengthSync(),
      "data": File(path).readAsStringSync()
    };
  }

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
