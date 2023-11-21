import 'package:flutter/material.dart';
import 'package:nordvpn_client/services/settings.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool recommendationsToggle = false;
  bool notificationsToggle = true;

  void setRecommendationSetting(bool value) {
    SettingsService.setRecommendationSetting(value);
    setState(() {
      recommendationsToggle = value;
    });
  }

  void setNotificationSetting(bool value) {
    SettingsService.setNotificationSetting(value);
    setState(() {
      notificationsToggle = value;
    });
  }

  @override
  void initState() {
    super.initState();
    SettingsService.getRecommendationSetting().then((value) {
      setState(() {
        recommendationsToggle = value;
      });
    });

    SettingsService.getNotificationSetting().then((value) {
      setState(() {
        notificationsToggle = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color(0xff3E5FFF),
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(tiles: [
            SettingsTile.switchTile(
              onToggle: setRecommendationSetting,
              title: const Text('Location recommendations'),
              initialValue: recommendationsToggle,
              description:
                  const Text('Use your location for initial recommendations'),
            ),
            SettingsTile.switchTile(
              title: const Text('Enable notifications'),
              description: const Text('Enable or disable push notifications'),
              initialValue: notificationsToggle,
              onToggle: setNotificationSetting,
            )
          ])
        ],
      ),
    );
  }
}
