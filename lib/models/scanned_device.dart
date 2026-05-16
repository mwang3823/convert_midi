enum DeviceType { ble, classic }

class ScannedDevice {
  final String name;
  final String id;
  final DeviceType type;
  final dynamic raw;

  const ScannedDevice({
    required this.name,
    required this.id,
    required this.type,
    required this.raw,
  });
}
