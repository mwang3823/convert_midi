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

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'type': type.name,
      };

  factory ScannedDevice.fromJson(Map<String, dynamic> json) => ScannedDevice(
        name: json['name'] as String,
        id: json['id'] as String,
        type: DeviceType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => DeviceType.ble,
        ),
        raw: null,
      );
}
