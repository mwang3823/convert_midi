import 'package:flutter/material.dart';
import '../../../../../common/globals.dart';
import '../../../../../common/theme.dart';
import '../../../../base/base_view.dart';
import '../../../../widgets/home_widgets.dart';
import '../../../../widgets/studio_widgets.dart';
import '../bloc/studio_bloc.dart';

// ignore: must_be_immutable
class StudioScreen extends BaseView {
  // ignore: no_logic_in_create_state
  final StudioBloc _bloc = StudioBloc();

  StudioScreen({super.key});

  StudioBloc get bloc => _bloc;

  @override
  // ignore: no_logic_in_create_state
  StudioBloc createState() => _bloc;

  // ─── Root ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        _buildTrackHeader(),
        _buildControlBar(),
        Expanded(child: _buildNotesArea()),
        _buildPiano(),
      ],
    );
  }

  // ─── Top Bar ─────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    final connected = _bloc.isConnected;
    final deviceName = Globals.bluetoothService.connectedDeviceName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          const SynthKeyLogo(),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('7D STREAK',
                    style: AppTextStyle.mono(
                        size: 10, color: AppColors.onSurface)),
                Container(
                  width: 1,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: AppColors.outlineVariant,
                ),
                Icon(
                  connected
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  size: 12,
                  color: connected
                      ? AppColors.tertiaryFixed
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  connected
                      ? (deviceName ?? 'CONNECTED')
                      : 'DISCONNECTED',
                  style: AppTextStyle.mono(
                      size: 10,
                      color: connected
                          ? AppColors.tertiaryFixed
                          : AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Track Header ─────────────────────────────────────────────────────────

  Widget _buildTrackHeader() {
    if (_bloc.trackTitle.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      decoration: const BoxDecoration(
        border: Border(
            bottom:
                BorderSide(color: AppColors.outlineVariant, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _bloc.trackTitle,
                  style: AppTextStyle.bold(size: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_bloc.trackComposer.isNotEmpty)
                  Text(
                    _bloc.trackComposer.toUpperCase(),
                    style: AppTextStyle.mono(
                        size: 10, color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Playlist position indicator
          if (_bloc.playlistLength > 1)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '${_bloc.playlistIndex + 1} / ${_bloc.playlistLength}',
                style: AppTextStyle.mono(
                    size: 10, color: AppColors.onSurfaceVariant),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── Control Bar ─────────────────────────────────────────────────────────

  Widget _buildControlBar() {
    return StreamBuilder<bool>(
      stream: _bloc.isPlaying.output,
      builder: (_, isPlayingSnap) {
        return StreamBuilder<double>(
          stream: _bloc.tempo.output,
          builder: (_, tempoSnap) {
            return StreamBuilder<double>(
              stream: _bloc.progress.output,
              builder: (_, progressSnap) {
                return TrackControlBar(
                  isPlaying: isPlayingSnap.data ?? false,
                  tempo: tempoSnap.data ?? 1.0,
                  progress: progressSnap.data ?? 0.0,
                  currentTime: _bloc.currentTime,
                  totalTime: _bloc.totalTime,
                  onPrevious: _bloc.onPrevious,
                  onPlayPause: _bloc.onPlayPause,
                  onNext: _bloc.onNext,
                  onTempoTap: _bloc.onTempoTap,
                  onProgressChanged: _bloc.onProgressChanged,
                );
              },
            );
          },
        );
      },
    );
  }

  // ─── Notes Area ──────────────────────────────────────────────────────────

  Widget _buildNotesArea() {
    return StreamBuilder<int>(
      stream: _bloc.handsMode.output,
      builder: (_, snap) {
        final mode = snap.data ?? 0;
        return Stack(
          children: [
            Container(color: AppColors.surfaceContainerLowest),
            FallingNotesView(
              elapsedStream: _bloc.elapsedMs.output,
              schedule: _bloc.noteSchedule,
              showLeft: mode != 2,
              showRight: mode != 1,
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(child: _buildDock()),
            ),
          ],
        );
      },
    );
  }

  // ─── Floating Dock ───────────────────────────────────────────────────────

  Widget _buildDock() {
    return StreamBuilder<bool>(
      stream: _bloc.waitActive.output,
      builder: (_, waitSnap) {
        return StreamBuilder<bool>(
          stream: _bloc.loopActive.output,
          builder: (_, loopSnap) {
            return StreamBuilder<int>(
              stream: _bloc.handsMode.output,
              builder: (_, handsSnap) {
                return FloatingDock(
                  waitActive: waitSnap.data ?? false,
                  loopActive: loopSnap.data ?? false,
                  handsMode: handsSnap.data ?? 0,
                  onWait: _bloc.onWaitToggle,
                  onLoop: _bloc.onLoopToggle,
                  onHands: _bloc.onHandsToggle,
                );
              },
            );
          },
        );
      },
    );
  }

  // ─── Piano ───────────────────────────────────────────────────────────────

  Widget _buildPiano() {
    return PianoKeyboardWidget(
      height: 90,
      activeNotesStream: _bloc.activeNotes.output,
    );
  }
}
