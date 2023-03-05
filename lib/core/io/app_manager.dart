import 'package:shared_preferences/shared_preferences.dart';

class AppManager {
  static late SharedPreferences preferences;

  static Future<void> initAppData() async {
    preferences = await SharedPreferences.getInstance();
  }

  static String getUsername() {
    return preferences.getString('username') ?? 'guest_user';
  }

  static String getDescription() {
    return preferences.getString('description') ??
        'Hey! Just checking this out.';
  }

  static String? getAvatar() {
    return preferences.getString('avatar');
  }
}
