import 'dart:convert';
import 'package:flutter/services.dart';

enum BluetoothMode { ble, classic, both }

class ConfigService {
  static BluetoothMode _mode = BluetoothMode.ble;
  static BluetoothMode get mode => _mode;

  static Future<void> load() async {
    try {
      final raw = await rootBundle.loadString('assets/json/config.json');
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _mode = _parse(map['bluetooth_mode'] as String? ?? 'ble');
    } catch (_) {
      _mode = BluetoothMode.ble;
    }
  }

  static BluetoothMode _parse(String value) => switch (value) {
        'classic' => BluetoothMode.classic,
        'both' => BluetoothMode.both,
        _ => BluetoothMode.ble,
      };
}
