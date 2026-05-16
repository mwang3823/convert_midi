class Constant {
  static String langDefault = 'vi';

  static BluetoothMode parseBluetoothMode(String value) => switch (value) {
        'classic' => BluetoothMode.classic,
        'both' => BluetoothMode.both,
        _ => BluetoothMode.ble,
      };
}

enum BluetoothMode { ble, classic, both }
