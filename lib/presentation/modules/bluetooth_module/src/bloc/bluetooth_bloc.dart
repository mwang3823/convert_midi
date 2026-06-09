import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import 'package:rxdart/rxdart.dart';
import '../../../../../common/constant.dart';
import '../../../../../common/globals.dart';
import '../../../../../data/local/shared_prefs/shared_prefs_key.dart';
import '../../../../../models/scanned_device.dart';
import '../../../../base/base_view.dart';
import '../ui/bluetooth_scanner_screen.dart';

class BluetoothBloc extends BaseBloc<BluetoothScannerScreen> {
  final scanResults     = BehaviorSubject<List<ScannedDevice>>.seeded([]);
  final isScanning      = BehaviorSubject<bool>.seeded(false);
  final isConnecting    = BehaviorSubject<bool>.seeded(false);
  final savedDevice     = BehaviorSubject<ScannedDevice?>.seeded(null);
  final connectedDevice = BehaviorSubject<ScannedDevice?>.seeded(null);
  final bluetoothOn     = BehaviorSubject<bool>.seeded(true);
  final permDenied      = BehaviorSubject<bool>.seeded(false);

  StreamSubscription? _scanStateSub;
  StreamSubscription? _scanResultsSub;
  StreamSubscription? _btStateSub;

  @override
  void onInit() {
    _scanStateSub  = FlutterBluePlus.isScanning.listen((s) => isScanning.set(s));
    _scanResultsSub = Globals.bluetoothService.scanResults.listen((d) => scanResults.set(d));
    _btStateSub    = Globals.bluetoothService.isBluetoothOn.listen((on) => bluetoothOn.set(on));
    _loadSavedDevice();
  }

  @override
  void onReady() => startScan();

  @override
  void onResumed() {}

  @override
  void onDispose() {
    _scanStateSub?.cancel();
    _scanResultsSub?.cancel();
    _btStateSub?.cancel();
    Globals.bluetoothService.stopScan();
    scanResults.close();
    isScanning.close();
    isConnecting.close();
    savedDevice.close();
    connectedDevice.close();
    bluetoothOn.close();
    permDenied.close();
  }

  void _loadSavedDevice() {
    final raw = Globals.prefs.getString(SharedPrefsKey.saved_bt_device);
    if (raw.isEmpty) return;
    try {
      savedDevice.set(ScannedDevice.fromJson(jsonDecode(raw) as Map<String, dynamic>));
    } catch (_) {}
  }

  void _saveDevice(ScannedDevice device) {
    Globals.prefs.setString(SharedPrefsKey.saved_bt_device, jsonEncode(device.toJson()));
    savedDevice.set(device);
  }

  void forgetDevice() {
    Globals.prefs.remove(SharedPrefsKey.saved_bt_device);
    savedDevice.set(null);
  }

  void startScan() {
    permDenied.set(false);
    Globals.bluetoothService.startScan().catchError((dynamic e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.contains('quyền') || msg.contains('permission')) {
        permDenied.set(true);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    });
  }

  void connect(ScannedDevice device) async {
    Globals.bluetoothService.stopScan();
    isConnecting.set(true);

    final success = await Globals.bluetoothService.connectToDevice(device);
    isConnecting.set(false);

    if (!mounted) return;

    if (success) {
      _saveDevice(device);
      connectedDevice.set(device);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã kết nối: ${device.name}')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kết nối thất bại.')),
        );
      }
    }
  }

  void connectSaved() {
    final device = savedDevice.value;
    if (device != null) connect(device);
  }

  void showManualConnectDialog() {
    final nameCtrl    = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey     = GlobalKey<FormState>();
    final mode        = Globals.bluetoothMode;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kết nối thủ công'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên thiết bị'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nhập tên thiết bị' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: addressCtrl,
                decoration: InputDecoration(
                  labelText: mode == BluetoothMode.ble
                      ? 'BLE Device ID'
                      : 'Địa chỉ MAC  (VD: AA:BB:CC:DD:EE:FF)',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nhập địa chỉ';
                  if (mode != BluetoothMode.ble) {
                    final mac = RegExp(r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$');
                    if (!mac.hasMatch(v.trim())) return 'Sai định dạng MAC (AA:BB:CC:DD:EE:FF)';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              connect(ScannedDevice(
                name: nameCtrl.text.trim(),
                id: addressCtrl.text.trim(),
                type: mode == BluetoothMode.ble ? DeviceType.ble : DeviceType.classic,
                raw: null,
              ));
            },
            child: const Text('Kết nối'),
          ),
        ],
      ),
    );
  }
}
