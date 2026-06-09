import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../../../../common/theme.dart';
import '../../../../../models/scanned_device.dart';
import '../../../../base/base_view.dart';
import '../../../../widgets/connect_widgets.dart';
import '../../../../widgets/home_widgets.dart';
import '../bloc/bluetooth_bloc.dart';

// ignore: must_be_immutable
class BluetoothScannerScreen extends BaseView {
  // ignore: no_logic_in_create_state
  final BluetoothBloc _bloc = BluetoothBloc();

  BluetoothScannerScreen({super.key});

  @override
  // ignore: no_logic_in_create_state
  BluetoothBloc createState() => _bloc;

  // ─── Root ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    _buildBanners(),
                    _buildScanningCard(),
                    const SizedBox(height: 16),
                    _buildSavedDeviceCard(),
                    _buildFoundDevicesCard(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: StreamBuilder<bool>(
            stream: _bloc.isScanning.output,
            builder: (_, snap) => RefreshFab(
              isScanning: snap.data ?? false,
              onRefresh: _bloc.startScan,
            ),
          ),
        ),
        StreamBuilder<bool>(
          stream: _bloc.isConnecting.output,
          builder: (_, snap) {
            if (snap.data != true) return const SizedBox.shrink();
            return Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.neonCyan),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─── Top Bar ─────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SynthKeyLogo(),
          const Spacer(),
          StreamBuilder<ScannedDevice?>(
            stream: _bloc.connectedDevice.output,
            builder: (_, snap) {
              final connected = snap.data != null;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('7D STREAK',
                        style: AppTextStyle.mono(size: 10, color: AppColors.onSurface)),
                    Container(
                      width: 1,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: AppColors.outlineVariant,
                    ),
                    if (connected)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: const BoxDecoration(
                          color: AppColors.emerald,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      connected ? 'CONNECTED' : 'DISCONNECTED',
                      style: AppTextStyle.mono(
                        size: 10,
                        color: connected ? AppColors.neonCyan : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Banners ──────────────────────────────────────────────────────────────

  Widget _buildBanners() {
    return Column(
      children: [
        StreamBuilder<bool>(
          stream: _bloc.bluetoothOn.output,
          builder: (_, snap) => AnimatedBannerSlot(
            visible: !(snap.data ?? true),
            child: StatusBanner(
              message: 'Bluetooth đang tắt',
              actionLabel: 'BẬT',
              color: AppColors.amber,
              onAction: () async {
                try {
                  await FlutterBluePlus.turnOn();
                } catch (_) {
                  ph.openAppSettings();
                }
              },
            ),
          ),
        ),
        StreamBuilder<bool>(
          stream: _bloc.permDenied.output,
          builder: (_, snap) => AnimatedBannerSlot(
            visible: snap.data == true,
            child: StatusBanner(
              message: 'Thiếu quyền Bluetooth',
              actionLabel: 'CÀI ĐẶT',
              color: AppColors.amber,
              onAction: () => ph.openAppSettings(),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Scanning Card ────────────────────────────────────────────────────────

  Widget _buildScanningCard() {
    return StreamBuilder<bool>(
      stream: _bloc.isScanning.output,
      builder: (_, scanSnap) {
        final scanning = scanSnap.data ?? false;
        return StreamBuilder<ScannedDevice?>(
          stream: _bloc.connectedDevice.output,
          builder: (_, connSnap) => ScanningCard(
            isScanning: scanning,
            isConnected: connSnap.data != null,
          ),
        );
      },
    );
  }

  // ─── Saved Device ─────────────────────────────────────────────────────────

  Widget _buildSavedDeviceCard() {
    return StreamBuilder<ScannedDevice?>(
      stream: _bloc.savedDevice.output,
      builder: (_, snap) {
        final device = snap.data;
        if (device == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SavedDeviceCard(
            device: device,
            onReconnect: _bloc.connectSaved,
            onForget: _bloc.forgetDevice,
          ),
        );
      },
    );
  }

  // ─── Found Devices ────────────────────────────────────────────────────────

  Widget _buildFoundDevicesCard() {
    return StreamBuilder<List<ScannedDevice>>(
      stream: _bloc.scanResults.output,
      initialData: const [],
      builder: (_, resultsSnap) {
        final results = resultsSnap.data ?? [];
        return StreamBuilder<ScannedDevice?>(
          stream: _bloc.savedDevice.output,
          builder: (_, savedSnap) {
            final saved = savedSnap.data;
            return StreamBuilder<ScannedDevice?>(
              stream: _bloc.connectedDevice.output,
              builder: (_, connSnap) {
                final connected = connSnap.data;
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.outlineVariant, width: 0.5),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('FOUND DEVICES', style: AppTextStyle.bold(size: 18)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.emerald, width: 1.5),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              '${results.length} DETECTED',
                              style: AppTextStyle.labelMono(color: AppColors.emerald),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (results.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No devices found.\nTap refresh to scan.',
                              style: AppTextStyle.bodySm(color: AppColors.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ...results.map((d) => DeviceItem(
                              device: d,
                              onConnect: () => _bloc.connect(d),
                              isSaved: saved?.id == d.id,
                              isConnected: connected?.id == d.id,
                            )),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

