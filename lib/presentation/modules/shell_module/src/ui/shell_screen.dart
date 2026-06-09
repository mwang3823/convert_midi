import 'package:flutter/material.dart';
import '../../../../../common/theme.dart';
import '../../../../base/base_view.dart';
import '../../../../widgets/dev_log_overlay.dart';
import '../../../bluetooth_module/src/ui/bluetooth_scanner_screen.dart';
import '../../../home_module/src/ui/home_screen.dart';
import '../../../insights_module/src/ui/insights_screen.dart';
import '../../../studio_module/src/ui/studio_screen.dart';
import '../bloc/shell_bloc.dart';

// ignore: must_be_immutable
class ShellScreen extends BaseView {
  // ignore: no_logic_in_create_state
  final ShellBloc _bloc = ShellBloc();
  final _studioScreen = StudioScreen();

  // Khởi tạo một lần để tránh widget._bloc mới (chưa mount) mỗi lần rebuild
  late final List<Widget> _tabs = [
    HomeScreen(
      onConnectTap: () => _bloc.onTabChanged(1),
      onNavigateToStudio: (playlist, index) {
        _studioScreen.bloc.loadPlaylist(playlist, index);
        _bloc.onTabChanged(2);
      },
      onNavigateToInsights: () => _bloc.onTabChanged(3),
    ),
    BluetoothScannerScreen(),
    _studioScreen,
    InsightsScreen(),
    _PlaceholderTab(label: 'Profile'),
  ];

  ShellScreen({super.key});

  @override
  // ignore: no_logic_in_create_state
  ShellBloc createState() => _bloc;

  @override
  Widget build(BuildContext context) {
    return DevLogOverlay(child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<int>(
          stream: _bloc.selectedTab.output,
          builder: (_, snap) {
            return IndexedStack(
              index: snap.data ?? 0,
              children: _tabs,
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    ));
  }

  Widget _buildBottomNav() {
    const tabs = [
      {'icon': Icons.home_rounded,      'label': 'Home'},
      {'icon': Icons.bluetooth,         'label': 'Connect'},
      {'icon': Icons.grid_view_rounded, 'label': 'Studio'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Insights'},
      {'icon': Icons.person_rounded,    'label': 'Profile'},
    ];

    return StreamBuilder<int>(
      stream: _bloc.selectedTab.output,
      builder: (_, snap) {
        final selected = snap.data ?? 0;
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final isActive = i == selected;
                  final icon    = tabs[i]['icon']  as IconData;
                  final label   = tabs[i]['label'] as String;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _bloc.onTabChanged(i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: isActive
                                ? BoxDecoration(
                                    color: AppColors.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                  )
                                : null,
                            child: Icon(
                              icon,
                              size: 22,
                              color: isActive ? AppColors.neonCyan : AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            label,
                            style: TextStyle(
                              fontFamily: AppFonts.geist,
                              fontSize: 10,
                              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                              color: isActive ? AppColors.neonCyan : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: AppTextStyle.headlineMd(color: AppColors.onSurfaceVariant)),
    );
  }
}
