import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import '../libs/bluetooth_service.dart';
import '../models/scanned_device.dart';
import '../common/config_service.dart';
import 'player_screen.dart';

class BluetoothScannerScreen extends StatefulWidget {
  final BluetoothService bluetoothService;

  const BluetoothScannerScreen({super.key, required this.bluetoothService});

  @override
  State<BluetoothScannerScreen> createState() => _BluetoothScannerScreenState();
}

class _BluetoothScannerScreenState extends State<BluetoothScannerScreen> {
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.isScanning.listen((state) {
      if (mounted) setState(() => _isScanning = state);
    });
  }

  void _startScan() {
    setState(() => _isScanning = true);
    widget.bluetoothService.startScan().catchError((e) {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    });
  }

  void _connect(ScannedDevice device) async {
    widget.bluetoothService.stopScan();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await widget.bluetoothService.connectToDevice(device);

    if (mounted) Navigator.pop(context);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kết nối thành công!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PlayerScreen(bluetoothService: widget.bluetoothService),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kết nối thất bại.')),
      );
    }
  }

  void _showManualConnectDialog() {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final mode = ConfigService.mode;

    showDialog(
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
                    final mac = RegExp(
                        r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$');
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
              _connect(device);
            },
            child: const Text('Kết nối'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm thiết bị MIDI'),
        actions: [
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.refresh), onPressed: _startScan),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Nhập địa chỉ thủ công',
            onPressed: _showManualConnectDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.amber.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              'Thiết bị đã pair hiện ngay. Thiết bị mới: bật "Visible/Discoverable" trên thiết bị kia. Không tìm thấy? Dùng nút ✏️ để nhập địa chỉ thủ công.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ScannedDevice>>(
              stream: widget.bluetoothService.scanResults,
              initialData: const [],
              builder: (context, snapshot) {
                final results = snapshot.data ?? [];
                if (results.isEmpty) {
                  return const Center(
                      child: Text(
                          'Chưa tìm thấy thiết bị nào. Bấm refresh để quét.'));
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final device = results[index];
                    return ListTile(
                      leading: Icon(device.type == DeviceType.ble
                          ? Icons.bluetooth
                          : Icons.bluetooth_audio),
                      title: Text(device.name),
                      subtitle: Text(
                        '${device.id}  •  ${device.type == DeviceType.ble ? 'BLE' : 'Classic'}',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _connect(device),
                        child: const Text('Kết nối'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
