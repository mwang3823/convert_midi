import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local/shared_prefs/shared_prefs.dart';
import '../data/local/shared_prefs/shared_prefs_key.dart';
import 'assets.dart';
import 'constant.dart';
import 'globals.dart';
import 'utilities.dart';

class Config {
  static Future<void> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    Globals.prefs = SharedPrefs(prefs);

    final raw = await rootBundle.loadString(Assets.jsonConfig);
    final json = Utilities.stringToJson(raw);

    Globals.applicationMode = json['environment'] as String? ?? 'PRODUCT';
    Globals.bluetoothMode   = Constant.parseBluetoothMode(
        json['bluetooth_mode'] as String? ?? 'ble');
    Globals.config = Config.fromJson(
        (json[Globals.applicationMode] as Map<String, dynamic>?) ?? {});

    if ((Globals.config.langDefault ?? '').isNotEmpty) {
      Constant.langDefault = Globals.config.langDefault!;
    }
    final lang = Globals.prefs.getString(
      SharedPrefsKey.language,
      value: Constant.langDefault,
    );
    Globals.locale = Locale(lang);
  }

  String? server;
  String? langDefault;
  bool?   enableLang;
  String? releaseDate;
  String? appName;

  Config({this.server, this.langDefault, this.enableLang, this.releaseDate, this.appName});

  Config.fromJson(Map<String, dynamic> json) {
    server = json['server'] as String?;
    if (server != null && server!.isNotEmpty && !server!.endsWith('/')) {
      server = '$server/';
    }
    langDefault = json['langDefault'] as String?;
    enableLang  = json['enableLang']  as bool?   ?? false;
    releaseDate = json['releaseDate'] as String?;
    appName     = json['appName']     as String?;
  }
}
