import 'package:flutter/material.dart';
import '../../../../../models/scanned_device.dart';
import '../../../../base/base_view.dart';
import '../bloc/bluetooth_bloc.dart';

// ignore: must_be_immutable
class BluetoothScannerScreen extends BaseView {
  // ignore: no_logic_in_create_state
  final BluetoothBloc _bloc = BluetoothBloc();

  BluetoothScannerScreen({super.key});

  @override
  // ignore: no_logic_in_create_state
  BluetoothBloc createState() => _bloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm thiết bị MIDI'),
        actions: [
          StreamBuilder<bool>(
            stream: _bloc.isScanning.output,
            builder: (_, snap) {
              final scanning = snap.data ?? false;
              return scanning
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _bloc.startScan,
                    );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Nhập địa chỉ thủ công',
            onPressed: _bloc.showManualConnectDialog,
          ),
        ],
      ),
      body: StreamBuilder<bool>(
        stream: _bloc.isConnecting.output,
        builder: (_, connectSnap) {
          final connecting = connectSnap.data ?? false;
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.amber.shade50,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const Text(
                      'Thiết bị đã pair hiện ngay. Thiết bị mới: bật '
                      '"Visible/Discoverable" trên thiết bị kia. Không tìm thấy? '
                      'Dùng nút ✏️ để nhập địa chỉ thủ công.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<ScannedDevice>>(
                      stream: _bloc.scanResults.output,
                      initialData: const [],
                      builder: (_, snap) {
                        final results = snap.data ?? [];
                        if (results.isEmpty) {
                          return const Center(
                            child: Text(
                                'Chưa tìm thấy thiết bị nào. Bấm refresh để quét.'),
                          );
                        }
                        return ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (_, index) {
                            final device = results[index];
                            return ListTile(
                              leading: Icon(device.type == DeviceType.ble
                                  ? Icons.bluetooth
                                  : Icons.bluetooth_audio),
                              title: Text(device.name),
                              subtitle: Text(
                                '${device.id}  •  '
                                '${device.type == DeviceType.ble ? 'BLE' : 'Classic'}',
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _bloc.connect(device),
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
              if (connecting)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }
}
