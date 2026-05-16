import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import 'package:permission_handler/permission_handler.dart';

import '../common/constant.dart';
import '../common/globals.dart';
import '../common/log_service.dart';
import '../models/scanned_device.dart';

class BluetoothService {
  final BluetoothClassic _classic = BluetoothClassic();

  BluetoothDevice? _connectedBleDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  bool _classicConnected = false;
  String? _connectedDeviceName;

  final _scanController = StreamController<List<ScannedDevice>>.broadcast();
  final List<ScannedDevice> _devices = [];
  StreamSubscription? _bleScanSub;

  bool _classicStreamInitialized = false;
  bool _classicScanActive = false;

  Stream<List<ScannedDevice>> get scanResults => _scanController.stream;
  String? get connectedDeviceName => _connectedDeviceName;
  BluetoothDevice? get connectedDevice => _connectedBleDevice;

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final perms = <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ];
      if (await Permission.location.status.isDenied) {
        perms.add(Permission.location);
      }
      final statuses = await perms.request();
      return statuses.values.every((s) => s.isGranted || s.isLimited);
    } else if (Platform.isIOS) {
      return await Permission.bluetooth.request().isGranted;
    }
    return true;
  }

  void _initClassicStream() {
    if (_classicStreamInitialized) return;
    _classicStreamInitialized = true;

    _classic.onDeviceDiscovered().listen((device) {
      if (!_classicScanActive) return;
      final name = device.name ?? '';
      if (name.isEmpty) return;
      final scanned = ScannedDevice(
        name: name,
        id: device.address,
        type: DeviceType.classic,
        raw: device,
      );
      _devices.removeWhere(
          (d) => d.type == DeviceType.classic && d.id == scanned.id);
      _devices.add(scanned);
      _scanController.add(List.from(_devices));
    });
  }

  Future<void> startScan() async {
    final mode = Globals.bluetoothMode;

    _devices.clear();
    _scanController.add([]);

    final hasPerms = await _requestPermissions();
    if (!hasPerms) throw Exception('Ứng dụng chưa được cấp quyền Bluetooth.');

    if (mode == BluetoothMode.ble || mode == BluetoothMode.both) {
      await FlutterBluePlus.stopScan();
      await _bleScanSub?.cancel();
      _bleScanSub = FlutterBluePlus.scanResults.listen((results) {
        final bleDevices = results
            .where((r) => r.device.platformName.isNotEmpty)
            .map((r) => ScannedDevice(
                  name: r.device.platformName,
                  id: r.device.remoteId.str,
                  type: DeviceType.ble,
                  raw: r.device,
                ))
            .toList();
        _devices.removeWhere((d) => d.type == DeviceType.ble);
        _devices.addAll(bleDevices);
        _scanController.add(List.from(_devices));
      });
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: false,
        androidScanMode: AndroidScanMode.lowLatency,
      );
    }

    if (Platform.isAndroid &&
        (mode == BluetoothMode.classic || mode == BluetoothMode.both)) {
      try {
        final paired = await _classic.getPairedDevices();
        for (final device in paired) {
          final name = device.name ?? '';
          if (name.isEmpty) continue;
          _devices.add(ScannedDevice(
            name: name,
            id: device.address,
            type: DeviceType.classic,
            raw: device,
          ));
        }
        if (_devices.isNotEmpty) _scanController.add(List.from(_devices));
      } catch (_) {}

      _initClassicStream();
      _classicScanActive = true;
      try {
        await _classic.startScan();
      } catch (_) {}
    }
  }

  Future<void> stopScan() async {
    _classicScanActive = false;
    await FlutterBluePlus.stopScan();
    await _bleScanSub?.cancel();
    _bleScanSub = null;
    if (Platform.isAndroid) {
      try {
        await _classic.stopScan();
      } catch (_) {}
    }
  }

  Future<bool> connectToDevice(ScannedDevice device) async {
    try {
      if (device.type == DeviceType.ble) {
        final bleDevice = device.raw as BluetoothDevice? ??
            BluetoothDevice(remoteId: DeviceIdentifier(device.id));
        return await _connectBle(bleDevice, device.name);
      } else {
        return await _connectClassic(device.id, device.name);
      }
    } catch (e) {
      LogService.instance.log('Lỗi kết nối: $e');
      return false;
    }
  }

  // BLE-MIDI service UUID (chuẩn BLE-MIDI 1.0)
  static const _midiServiceUuid = '03b80e5a-ede8-4b33-a751-6ce34ec4c700';
  // BLE-MIDI I/O characteristic UUID
  static const _midiCharUuid = '7772e5db-3868-4112-a1a9-f2669d106bf3';

  Future<bool> _connectBle(BluetoothDevice device, String name) async {
    LogService.instance.log('BLE: đang kết nối $name (${device.remoteId})');
    await device.connect(license: License.free, autoConnect: false);
    _connectedBleDevice = device;

    final services = await device.discoverServices();
    LogService.instance.log('BLE: phát hiện ${services.length} service');

    for (final service in services) {
      final svcUuid = service.uuid.str128.toLowerCase();
      final isMidiService = svcUuid == _midiServiceUuid;
      LogService.instance.log(
          'Service: $svcUuid${isMidiService ? " [BLE-MIDI]" : ""}');
      for (final char in service.characteristics) {
        final props = char.properties;
        LogService.instance.log(
            '  Char: ${char.uuid.str128.toLowerCase()} '
            'write=${props.write} writeNoResp=${props.writeWithoutResponse} '
            'notify=${props.notify} read=${props.read}');
      }
    }

    // Ưu tiên tìm đúng BLE-MIDI service + characteristic
    for (final service in services) {
      if (service.uuid.str128.toLowerCase() == _midiServiceUuid) {
        for (final char in service.characteristics) {
          if (char.uuid.str128.toLowerCase() == _midiCharUuid) {
            _writeCharacteristic = char;
            LogService.instance.log('BLE-MIDI char tìm thấy (đúng UUID)');
            break;
          }
        }
      }
      if (_writeCharacteristic != null) break;
    }

    // Fallback: tìm theo UUID characteristic không cần service
    if (_writeCharacteristic == null) {
      for (final service in services) {
        for (final char in service.characteristics) {
          if (char.uuid.str128.toLowerCase() == _midiCharUuid) {
            _writeCharacteristic = char;
            LogService.instance.log('BLE-MIDI char tìm thấy (fallback UUID)');
            break;
          }
        }
        if (_writeCharacteristic != null) break;
      }
    }

    // Fallback cuối: lấy characteristic đầu tiên có write
    if (_writeCharacteristic == null) {
      for (final service in services) {
        for (final char in service.characteristics) {
          if (char.properties.write || char.properties.writeWithoutResponse) {
            _writeCharacteristic = char;
            LogService.instance.log(
                'BLE: dùng char write đầu tiên: ${char.uuid.str128.toLowerCase()}');
            break;
          }
        }
        if (_writeCharacteristic != null) break;
      }
    }

    if (_writeCharacteristic == null) {
      LogService.instance.log('BLE: không tìm thấy characteristic write, ngắt kết nối');
      await disconnect();
      return false;
    }

    _connectedDeviceName = name;
    LogService.instance.log('BLE: kết nối thành công với $name');
    return true;
  }

  Future<bool> _connectClassic(String address, String name) async {
    LogService.instance.log('Classic BT: kết nối $name ($address)');
    await _classic.connect(address, '00001101-0000-1000-8000-00805f9b34fb');
    _classicConnected = true;
    _connectedDeviceName = name;
    LogService.instance.log('Classic BT: kết nối thành công');
    return true;
  }

  Future<void> disconnect() async {
    if (_connectedBleDevice != null) {
      await _connectedBleDevice!.disconnect();
      _connectedBleDevice = null;
      _writeCharacteristic = null;
    }
    if (_classicConnected) {
      try {
        await _classic.disconnect();
      } catch (_) {}
      _classicConnected = false;
    }
    _connectedDeviceName = null;
  }

  /// Đóng gói MIDI bytes theo chuẩn BLE-MIDI 1.0:
  /// [Header(0x80|ts_high6)] [Timestamp(0x80|ts_low7)] [MIDI bytes...]
  List<int> _wrapBleMidi(List<int> midiBytes) {
    final tsMs = DateTime.now().millisecondsSinceEpoch & 0x1FFF; // 13-bit
    final header = 0x80 | ((tsMs >> 7) & 0x3F);
    final timestamp = 0x80 | (tsMs & 0x7F);
    return [header, timestamp, ...midiBytes];
  }

  Future<void> sendRawData(List<int> data) async {
    if (_writeCharacteristic != null) {
      final packet = _wrapBleMidi(data);
      final noResponse =
          _writeCharacteristic!.properties.writeWithoutResponse;
      try {
        await _writeCharacteristic!.write(packet, withoutResponse: noResponse);
        LogService.instance.log(
            'BLE gửi: ${packet.map((b) => '0x${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join(' ')}');
      } catch (e) {
        LogService.instance.log('BLE gửi lỗi: $e');
      }
    } else if (_classicConnected) {
      try {
        await _classic.writeBytes(Uint8List.fromList(data));
        LogService.instance.log('Classic gửi: $data');
      } catch (e) {
        LogService.instance.log('Classic gửi lỗi: $e');
      }
    } else {
      LogService.instance.log('CẢNH BÁO: sendRawData gọi nhưng không có kết nối');
    }
  }

  Stream<BluetoothConnectionState>? get connectionState =>
      _connectedBleDevice?.connectionState;
}
