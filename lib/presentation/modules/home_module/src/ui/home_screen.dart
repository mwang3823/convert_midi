import 'package:flutter/material.dart';
import '../../../../../common/assets.dart';
import '../../../../../common/theme.dart';
import '../../../../base/base_view.dart';
import '../../../../widgets/home_widgets.dart';
import '../bloc/home_bloc.dart';

// ignore: must_be_immutable
class HomeScreen extends BaseView {
  // ignore: no_logic_in_create_state
  final HomeBloc _bloc = HomeBloc();
  final VoidCallback? onConnectTap;
  final void Function(List<Map<String, String>> playlist, int startIndex)? onNavigateToStudio;
  final VoidCallback? onNavigateToInsights;

  HomeScreen({
    super.key,
    this.onConnectTap,
    this.onNavigateToStudio,
    this.onNavigateToInsights,
  });

  @override
  // ignore: no_logic_in_create_state
  HomeBloc createState() => _bloc;

  // ─── Root ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                CurrentFocusCard(
                  title: _bloc.currentFocusTitle,
                  composer: _bloc.currentFocusComposer,
                  masteryProgress: _bloc.masteryProgress,
                  onPlay: _bloc.onPlayCurrentFocus,
                  isSuggestion: _bloc.isSuggestion,
                ),
                const SizedBox(height: 28),
                _buildPlaylistsSection(),
                const SizedBox(height: 8),
                _buildMidiSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
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
          AppBadge(
            icon: Icons.local_fire_department,
            iconColor: AppColors.magenta,
            label: '7D STREAK',
            onTap: _bloc.onStreakTap,
          ),
          const SizedBox(width: 8),
          AppBadge(
            icon: _bloc.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            iconColor: _bloc.isConnected ? AppColors.tertiaryFixed : AppColors.onSurfaceVariant,
            label: _bloc.isConnected ? 'CONNECTED' : 'DISCONNECTED',
            hasBorder: true,
            onTap: onConnectTap ?? _bloc.onConnectedTap,
          ),
        ],
      ),
    );
  }

  // ─── Practice Playlists ───────────────────────────────────────────────────

  Widget _buildPlaylistsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Practice Playlists', style: AppTextStyle.headlineMd()),
              GestureDetector(
                onTap: _bloc.onViewAllPlaylists,
                child: Text('VIEW ALL', style: AppTextStyle.mono(size: 11, color: AppColors.neonCyan)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _bloc.playlists.length,
            itemBuilder: (_, i) => PlaylistCard(
              name: _bloc.playlists[i]['name'] as String,
              sessions: _bloc.playlists[i]['sessions'] as int,
              onTap: () => _bloc.onPlaylistTap(i),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Imported MIDI Files ──────────────────────────────────────────────────

  Widget _buildMidiSection() {
    const iconColors = [
      AppColors.neonCyan,
      AppColors.magenta,
      AppColors.emerald,
      AppColors.amber,
      AppColors.tertiaryFixed,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Imported MIDI Files', style: AppTextStyle.headlineMd()),
              GestureDetector(
                onTap: _bloc.onImportNewFile,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.upload_file_outlined, size: 13, color: AppColors.onSurface),
                      const SizedBox(width: 5),
                      Text('IMPORT NEW', style: AppTextStyle.mono(size: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_bloc.midiFiles.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            child: Center(
              child: Column(
                children: [
                  Image.asset(Assets.imgIconEmpty, width: 64, height: 64),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có file MIDI nào được import.',
                    style: AppTextStyle.bodySm(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(
            _bloc.midiFiles.length,
            (i) => MidiFileItem(
              title: _bloc.midiFiles[i]['title']!,
              artist: _bloc.midiFiles[i]['artist']!,
              iconColor: iconColors[i % iconColors.length],
              onTap: () => _bloc.onMidiFileTap(i),
              onMenu: () => _bloc.onMidiFileMenu(i),
            ),
          ),
      ],
    );
  }
}
