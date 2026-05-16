import 'package:flutter/material.dart';
import '../data/local/shared_prefs/shared_prefs.dart';
import '../data/models/response/login_res_model.dart';
import '../libs/bluetooth_service.dart';
import 'config.dart';
import 'constant.dart';

class Globals {
  static late SharedPrefs     prefs;
  static late Config          config;
  static late Locale          locale;
  static late GlobalKey       myApp;
  static late String          applicationMode;
  static late BluetoothMode   bluetoothMode;
  static late BluetoothService bluetoothService;

  static LoginResModel? model;

  static bool get isLocaleInitialized {
    try {
      locale;
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool get isApplicationModeInitialized {
    try {
      applicationMode;
      return true;
    } catch (_) {
      return false;
    }
  }
}
