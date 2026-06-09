import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;

import '../models/scanned_device.dart';
import 'bluetooth_service.dart';

class MockBluetoothService extends BluetoothService {
  final _scanController = StreamController<List<ScannedDevice>>.broadcast();
  final _nameController = StreamController<String?>.broadcast();
  String? _connectedName;
  bool _isConnected = false;

  @override
  Stream<List<ScannedDevice>> get scanResults => _scanController.stream;

  @override
  Stream<String?> get connectedNameStream => _nameController.stream;

  @override
  String? get connectedDeviceName => _connectedName;

  @override
  BluetoothDevice? get connectedDevice => null;

  @override
  Future<void> startScan() async {
    _scanController.add([]);
    await Future.delayed(const Duration(seconds: 1));
    _scanController.add([
      ScannedDevice(
        name: 'Virtual MIDI Keyboard',
        id: 'mock_virtual_device_01',
        type: DeviceType.ble,
        raw: null,
      )
    ]);
  }

  @override
  Future<void> stopScan() async {
    // No-op for mock
  }

  @override
  Future<bool> connectToDevice(ScannedDevice device) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _connectedName = device.name;
    _isConnected = true;
    _nameController.add(_connectedName);
    return true;
  }

  @override
  Future<void> disconnect() async {
    _connectedName = null;
    _isConnected = false;
    _nameController.add(null);
  }

  @override
  Future<void> sendRawData(List<int> data) async {
    print('MockBluetoothService sending: $data');
  }

  @override
  Stream<BluetoothConnectionState>? get connectionState => Stream.value(
      _isConnected ? BluetoothConnectionState.connected : BluetoothConnectionState.disconnected);

  @override
  Stream<bool> get isBluetoothOn => Stream.value(true);
}
