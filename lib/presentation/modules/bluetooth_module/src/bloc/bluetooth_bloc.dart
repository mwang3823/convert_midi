import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import 'package:rxdart/rxdart.dart';
import '../../../../../common/constant.dart';
import '../../../../../common/globals.dart';
import '../../../../../models/scanned_device.dart';
import '../../../../base/base_view.dart';
import '../../../../widgets/custom_navigator.dart';
import '../../../player_module/src/ui/player_screen.dart';
import '../ui/bluetooth_scanner_screen.dart';

class BluetoothBloc extends BaseBloc<BluetoothScannerScreen> {
  final scanResults  = BehaviorSubject<List<ScannedDevice>>.seeded([]);
  final isScanning   = BehaviorSubject<bool>.seeded(false);
  final isConnecting = BehaviorSubject<bool>.seeded(false);

  StreamSubscription? _scanStateSub;
  StreamSubscription? _scanResultsSub;

  @override
  void onInit() {
    _scanStateSub = FlutterBluePlus.isScanning.listen((s) => isScanning.set(s));
    _scanResultsSub = Globals.bluetoothService.scanResults
        .listen((d) => scanResults.set(d));
  }

  @override
  void onReady() => startScan();

  @override
  void onResumed() {}

  @override
  void onDispose() {
    _scanStateSub?.cancel();
    _scanResultsSub?.cancel();
    Globals.bluetoothService.stopScan();
    scanResults.close();
    isScanning.close();
    isConnecting.close();
  }

  void startScan() {
    Globals.bluetoothService.startScan().catchError((dynamic e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kết nối thành công!')),
      );
      CustomNavigator.push(context, PlayerScreen());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kết nối thất bại.')),
      );
    }
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
                    if (!mac.hasMatch(v.trim())) {
                      return 'Sai định dạng MAC (AA:BB:CC:DD:EE:FF)';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              final device = ScannedDevice(
                name: nameCtrl.text.trim(),
                id: addressCtrl.text.trim(),
                type: mode == BluetoothMode.ble
                    ? DeviceType.ble
                    : DeviceType.classic,
                raw: null,
              );
              connect(device);
            },
            child: const Text('Kết nối'),
          ),
        ],
      ),
    );
  }
}
