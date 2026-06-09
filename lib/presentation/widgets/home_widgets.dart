import 'package:flutter/material.dart';
import '../../common/assets.dart';
import '../../common/theme.dart';

// ─── Logo ─────────────────────────────────────────────────────────────────

class SynthKeyLogo extends StatelessWidget {
  const SynthKeyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(Assets.imgIconApp, width: 30, height: 30),
        const SizedBox(width: 8),
        Text(
          'MIDI-KEYS',
          style: AppTextStyle.bold(size: 15, color: AppColors.neonCyan),
        ),
      ],
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────

class AppBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool hasBorder;
  final VoidCallback? onTap;

  const AppBadge({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.hasBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: hasBorder
              ? Border.all(color: AppColors.outlineVariant, width: 0.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyle.mono(size: 10, color: AppColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Current Focus Card ───────────────────────────────────────────────────

class CurrentFocusCard extends StatelessWidget {
  final String? title;
  final String? composer;
  final double? masteryProgress;
  final VoidCallback? onPlay;
  final bool isSuggestion;

  const CurrentFocusCard({
    super.key,
    this.title,
    this.composer,
    this.masteryProgress,
    this.onPlay,
    this.isSuggestion = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 270,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.imgPiano),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.darken,
          ),
        ),
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.surfaceContainerHigh,
                    AppColors.surfaceContainerLow,
                    AppColors.surfaceContainerLowest,
                  ],
                ),
              ),
            ),
          ),
          const _HudCorner(top: 14, left: 14, isTopLeft: true),
          const _HudCorner(bottom: 14, right: 14, isTopLeft: false),
          Padding(
            padding: const EdgeInsets.all(20),
            child: (title == null || title!.isEmpty)
                ? Center(child: _buildEmptyState())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CurrentFocusBadge(isSuggestion: isSuggestion),
                      const SizedBox(height: 12),
                      Text(
                        title!,
                        style: AppTextStyle.headlineLg(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              composer ?? '',
                              style: AppTextStyle.bodySm(
                                color: AppColors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _MasteryProgress(pct: masteryProgress ?? 0.0),
                      const Spacer(),
                      Center(child: _PlayButton(onTap: onPlay!)),
                      const SizedBox(height: 4),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Image.asset(
          Assets.imgIconEmpty,
          width: 80,
          height: 80,
        ),
        const SizedBox(height: 16),
        Text(
          'Chưa có bài nhạc nào',
          style: AppTextStyle.headlineMd(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Text(
          'Hãy chọn hoặc import một file MIDI\nđể bắt đầu luyện tập.',
          textAlign: TextAlign.center,
          style: AppTextStyle.bodySm(color: AppColors.outline),
        ),
        const Spacer(),
      ],
    );
  }
}

class _CurrentFocusBadge extends StatelessWidget {
  final bool isSuggestion;

  const _CurrentFocusBadge({this.isSuggestion = false});

  @override
  Widget build(BuildContext context) {
    final color = isSuggestion ? AppColors.amber : AppColors.neonCyan;
    final label = isSuggestion ? 'SUGGESTION' : 'CURRENT FOCUS';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withAlpha(70), width: 0.5),
      ),
      child: Text(
        label,
        style: AppTextStyle.mono(size: 9, color: isSuggestion ? AppColors.amber : AppColors.primaryFixed),
      ),
    );
  }
}

class _MasteryProgress extends StatelessWidget {
  final double pct;
  const _MasteryProgress({required this.pct});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mastery Progress',
              style: AppTextStyle.labelSm(color: AppColors.onSurfaceVariant),
            ),
            Text(
              '${(pct * 100).toInt()}%',
              style: AppTextStyle.mono(size: 11, color: AppColors.neonCyan),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Stack(
            children: [
              Container(height: 4, color: AppColors.outlineVariant),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF9B51E0), AppColors.neonCyan],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PlayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: AppColors.neonCyan,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withAlpha(80),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: AppColors.onPrimary,
          size: 40,
        ),
      ),
    );
  }
}

// ─── Playlist Card ────────────────────────────────────────────────────────

class PlaylistCard extends StatelessWidget {
  final String name;
  final int sessions;
  final VoidCallback onTap;

  const PlaylistCard({
    super.key,
    required this.name,
    required this.sessions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 175,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                ),
                child: Center(
                  child: Opacity(
                    opacity: 0.8,
                    child: Image.asset(
                      Assets.imgIconApp,
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyle.bold(size: 14)),
                  const SizedBox(height: 3),
                  Text(
                    '$sessions SESSIONS',
                    style: AppTextStyle.mono(
                      size: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── MIDI File Item ───────────────────────────────────────────────────────

class MidiFileItem extends StatelessWidget {
  final String title;
  final String artist;
  final Color iconColor;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  const MidiFileItem({
    super.key,
    required this.title,
    required this.artist,
    required this.iconColor,
    required this.onTap,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(38),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(Icons.music_note_rounded, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyle.bold(size: 14)),
                  const SizedBox(height: 2),
                  Text(
                    artist.toUpperCase(),
                    style: AppTextStyle.mono(
                      size: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onMenu,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HUD Corner ───────────────────────────────────────────────────────────

class _HudCorner extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final bool isTopLeft;

  const _HudCorner({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.isTopLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: CustomPaint(
        size: const Size(18, 18),
        painter: _HudCornerPainter(isTopLeft: isTopLeft),
      ),
    );
  }
}

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
