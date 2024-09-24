import 'package:flutter/material.dart';
import 'package:flutter_mute/flutter_mute.dart';
import 'package:quick_settings/quick_settings.dart';

@pragma("vm:entry-point")
Tile onTileClicked(Tile tile) {
  final oldStatus = tile.tileStatus;
  if (oldStatus == TileStatus.active) {
    tile.label = "Alarm OFF";
    tile.tileStatus = TileStatus.inactive;
    tile.subtitle = "6:30 AM";
    tile.drawableName = "alarm_off";
  } else {
    tile.label = "Alarm ON";
    tile.tileStatus = TileStatus.active;
    tile.subtitle = "6:30 AM";
    tile.drawableName = "alarm_check";
  }
  return tile;
}

Tile onTileAdded(Tile tile) {
  tile.label = "Alarm ON";
  tile.tileStatus = TileStatus.active;
  tile.subtitle = "6:30 AM";
  tile.drawableName = "alarm_check";
  return tile;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  QuickSettings.setup(
    onTileAdded: onTileAdded,
    onTileClicked: onTileClicked,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool? permitted;
  void checkPermission() async {
    bool isAccessGranted = await FlutterMute.isNotificationPolicyAccessGranted;

    if (!isAccessGranted) {
      await FlutterMute.openNotificationPolicySettings();
    } else {
      permitted = true;
      return;
    }
    isAccessGranted = await FlutterMute.isNotificationPolicyAccessGranted;
    permitted = isAccessGranted ? true : false;
  }

  @override
  void initState() {
    checkPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
              onPressed: () {
                QuickSettings.addTileToQuickSettings(
                  label: "Alarm Toggle",
                  drawableName: "alarm",
                );
              },
              child: const Text("ADD")),
        ),
      ),
    );
  }

  void switchRingerMode() async {
    RingerMode ringerMode = await FlutterMute.getRingerMode();
    if (ringerMode == RingerMode.Normal) {
      await FlutterMute.setRingerMode(RingerMode.Vibrate);
    } else {
      await FlutterMute.setRingerMode(RingerMode.Normal);
    }
  }
}
