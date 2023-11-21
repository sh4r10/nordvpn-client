import 'dart:io';

import 'package:nordvpn_client/services/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static Future<bool> getRecommendationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('recommendationSetting') ?? false;
  }

  static Future<bool> setRecommendationSetting(bool value) async {
    return await StorageService.setBool('recommendationSetting', value);
  }

  static Future<bool> getNotificationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificationSetting') ?? true;
  }

  static Future<bool> setNotificationSetting(bool value) async {
    bool success;
    if (value) {
      ProcessResult result =
          await Process.run('nordvpn', ['set', 'notify', 'enabled']);
      success = result.exitCode == 0;
    } else {
      ProcessResult result =
          await Process.run('nordvpn', ['set', 'notify', 'disabled']);
      success = result.exitCode == 0;
    }
    if (success) {
      return await StorageService.setBool('notificationSetting', value);
    }
    return false;
  }
}
