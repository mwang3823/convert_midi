import 'package:flutter/material.dart';
import '../../../../../common/assets.dart';
import '../../../../../common/theme.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistName;
  final List<Map<String, String>> songs;
  final void Function(Map<String, String> song) onPlaySong;
  final void Function(List<Map<String, String>> songs)? onPlayAll;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistName,
    required this.songs,
    required this.onPlaySong,
    this.onPlayAll,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(context),
            _buildHeroHeader(context),
            const SizedBox(height: 16),
            Expanded(child: _buildSongList(context)),
          ],
        ),
      ),
    );
  }

  // ─── Top Bar ─────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.onSurface, size: 18),
            ),
          ),
          const SizedBox(width: 2),
          Text('PLAYLIST',
              style: AppTextStyle.mono(size: 11, color: AppColors.neonCyan)),
        ],
      ),
    );
  }

  // ─── Hero Header ─────────────────────────────────────────────────────────

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      height: 164,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(Assets.imgPiano),
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(
            Color(0xA6000000),
            BlendMode.darken,
          ),
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.surfaceContainerHigh,
                  AppColors.surfaceContainerLowest,
                ],
              ),
            ),
          ),
          // HUD corner decorations
          _buildHudCorner(top: 10, left: 10, isTopLeft: true),
          _buildHudCorner(bottom: 10, right: 10, isTopLeft: false),
          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withAlpha(30),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                        color: AppColors.neonCyan.withAlpha(70), width: 0.5),
                  ),
                  child: Text('PRACTICE PLAYLIST',
                      style: AppTextStyle.mono(
                          size: 9, color: AppColors.primaryFixed)),
                ),
                const SizedBox(height: 10),
                Text(playlistName, style: AppTextStyle.headlineMd()),
                const SizedBox(height: 4),
                Text('${songs.length} SESSIONS',
                    style: AppTextStyle.mono(
                        size: 10, color: AppColors.onSurfaceVariant)),
                const Spacer(),
                GestureDetector(
                  onTap: songs.isEmpty
                      ? null
                      : () {
                          Navigator.pop(context);
                          if (onPlayAll != null) {
                            onPlayAll!(songs);
                          } else {
                            onPlaySong(songs.first);
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded,
                            color: AppColors.onPrimary, size: 18),
                        const SizedBox(width: 6),
                        Text('PLAY ALL',
                            style: AppTextStyle.mono(
                                size: 11, color: AppColors.onPrimary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Song List ────────────────────────────────────────────────────────────

  Widget _buildSongList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      itemCount: songs.length,
      itemBuilder: (_, i) => _SongRow(
        index: i + 1,
        title: songs[i]['title']!,
        onPlay: () {
          Navigator.pop(context);
          onPlaySong(songs[i]);
        },
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _buildHudCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTopLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: CustomPaint(
        size: const Size(16, 16),
        painter: _HudCornerPainter(isTopLeft: isTopLeft),
      ),
    );
  }
}

// ─── Song Row ─────────────────────────────────────────────────────────────

class _SongRow extends StatelessWidget {
  final int index;
  final String title;
  final VoidCallback onPlay;

  const _SongRow({
    required this.index,
    required this.title,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPlay,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                index.toString().padLeft(2, '0'),
                style: AppTextStyle.mono(
                    size: 12, color: AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: AppTextStyle.bold(size: 14)),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withAlpha(25),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                    color: AppColors.neonCyan.withAlpha(80), width: 0.5),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: AppColors.neonCyan, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HUD Corner Painter ───────────────────────────────────────────────────

class _HudCornerPainter extends CustomPainter {
  final bool isTopLeft;
  const _HudCornerPainter({required this.isTopLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.outline
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final w = size.width;
    final h = size.height;
    if (isTopLeft) {
      canvas.drawLine(Offset.zero, Offset(w, 0), paint);
      canvas.drawLine(Offset.zero, Offset(0, h), paint);
    } else {
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
    }
  }

  @override
  bool shouldRepaint(_HudCornerPainter old) => false;
}
