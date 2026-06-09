import 'package:flutter/material.dart';
import '../../common/theme.dart';
import '../../../libs/midi_streaming_service.dart';

// ─── Falling Notes View ───────────────────────────────────────────────────

class FallingNotesView extends StatelessWidget {
  final Stream<double>? elapsedStream;
  final List<NoteScheduleItem> schedule;
  final bool showLeft;
  final bool showRight;

  const FallingNotesView({
    super.key,
    this.elapsedStream,
    this.schedule = const [],
    this.showLeft = true,
    this.showRight = true,
  });

  @override
  Widget build(BuildContext context) {
    if (elapsedStream == null || schedule.isEmpty) {
      return SizedBox.expand(
        child: CustomPaint(
          painter: _FallingNotesPainter(showLeft: showLeft, showRight: showRight),
        ),
      );
    }
    return StreamBuilder<double>(
      stream: elapsedStream,
      builder: (_, snap) {
        return SizedBox.expand(
          child: CustomPaint(
            painter: _ScheduledNotesPainter(
              elapsed: snap.data ?? 0.0,
              schedule: schedule,
              showLeft: showLeft,
              showRight: showRight,
            ),
          ),
        );
      },
    );
  }
}

class _FallingNotesPainter extends CustomPainter {
  final bool showLeft;
  final bool showRight;

  const _FallingNotesPainter({required this.showLeft, required this.showRight});

  // [xFrac, yFrac, hFrac, wFrac, isLeft]
  static const _notes = [
    [0.135, 0.035, 0.185, 0.085, true],
    [0.265, 0.230, 0.140, 0.085, true],
    [0.265, 0.530, 0.115, 0.085, true],
    [0.135, 0.660, 0.100, 0.085, true],
    [0.735, 0.040, 0.265, 0.085, false],
    [0.615, 0.270, 0.115, 0.080, false],
    [0.845, 0.365, 0.385, 0.085, false],
    [0.735, 0.675, 0.048, 0.080, false],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    for (final n in _notes) {
      final isLeft = n[4] as bool;
      if (isLeft && !showLeft) continue;
      if (!isLeft && !showRight) continue;
      _drawNote(canvas, size, n[0] as double, n[1] as double,
          n[2] as double, n[3] as double, isLeft);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonCyan.withAlpha(12)
      ..strokeWidth = 0.5;
    // Horizontal lines (beat markers)
    for (double y = 0; y < size.height; y += size.height / 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines (key lanes)
    final laneW = size.width / 13;
    for (double x = 0; x <= size.width; x += laneW) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawNote(Canvas canvas, Size size, double xFrac, double yFrac,
      double hFrac, double wFrac, bool isLeft) {
    final color = isLeft ? AppColors.neonCyan : AppColors.magenta;
    final w = size.width * wFrac;
    final h = size.height * hFrac;
    final x = size.width * xFrac - w / 2;
    final y = size.height * yFrac;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      const Radius.circular(10),
    );

    // Outer glow
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color.withAlpha(55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Gradient fill (lighter top → solid bottom)
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withAlpha(170), color],
        ).createShader(Rect.fromLTWH(x, y, w, h)),
    );
  }

  @override
  bool shouldRepaint(_FallingNotesPainter old) =>
      old.showLeft != showLeft || old.showRight != showRight;
}

class _ScheduledNotesPainter extends CustomPainter {
  final double elapsed;
  final List<NoteScheduleItem> schedule;
  final bool showLeft;
  final bool showRight;

  const _ScheduledNotesPainter({
    required this.elapsed,
    required this.schedule,
    required this.showLeft,
    required this.showRight,
  });

  static const double _lookaheadMs = 2000.0;

  static const _sharps = {1, 3, 6, 8, 10};

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.surfaceContainerLowest,
    );

    // Grid
    final gridPaint = Paint()
      ..color = AppColors.neonCyan.withAlpha(12)
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += size.height / 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final laneW = size.width / 13;
    for (double x = 0; x <= size.width; x += laneW) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Notes
    for (final item in schedule) {
      if (!showLeft && item.isLeft) continue;
      if (!showRight && !item.isLeft) continue;

      final timeUntilStart = item.absTimeMs - elapsed;
      final timeUntilEnd = item.absTimeMs + item.durationMs - elapsed;

      if (timeUntilEnd < 0) continue;
      if (timeUntilStart > _lookaheadMs) continue;

      final yBottom =
          (1.0 - (timeUntilStart / _lookaheadMs).clamp(0.0, 1.0)) * size.height;
      final yTop =
          (1.0 - (timeUntilEnd / _lookaheadMs).clamp(0.0, 1.0)) * size.height;

      if (yTop >= yBottom) continue;

      final xFrac = (item.noteNumber - 36).clamp(0, 48) / 48.0;
      final isSh = _sharps.contains(item.noteNumber % 12);
      final noteW = size.width * (isSh ? 0.035 : 0.055);
      final x = xFrac * size.width - noteW / 2;

      final color = item.isLeft ? AppColors.neonCyan : AppColors.magenta;
      final isActive = timeUntilStart <= 0 && timeUntilEnd > 0;

      final rect = Rect.fromLTWH(x, yTop, noteW, yBottom - yTop);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

      // Glow if active
      if (isActive) {
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = color.withAlpha(60)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }

      // Gradient fill
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withAlpha(160), color],
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(_ScheduledNotesPainter old) =>
      old.elapsed != elapsed ||
      old.showLeft != showLeft ||
      old.showRight != showRight;
}

// ─── Piano Keyboard ───────────────────────────────────────────────────────

class PianoKeyboardWidget extends StatelessWidget {
  final double height;
  final Stream<Set<int>>? activeNotesStream;

  const PianoKeyboardWidget({
    super.key,
    this.height = 90,
    this.activeNotesStream,
  });

  @override
  Widget build(BuildContext context) {
    if (activeNotesStream == null) {
      return SizedBox(
        height: height,
        child: CustomPaint(
          painter: _PianoPainter(
            activeLeft: const {48, 50},
            activeRight: const {67, 65, 69},
          ),
        ),
      );
    }
    return StreamBuilder<Set<int>>(
      stream: activeNotesStream!,
      builder: (_, snap) {
        final active = snap.data ?? {};
        final left = active.where((n) => n < 60).toSet();
        final right = active.where((n) => n >= 60).toSet();
        return SizedBox(
          height: height,
          child: CustomPaint(
            size: Size(double.infinity, height),
            painter: _PianoPainter(activeLeft: left, activeRight: right),
          ),
        );
      },
    );
  }
}

class _PianoPainter extends CustomPainter {
  final Set<int> activeLeft;
  final Set<int> activeRight;

  const _PianoPainter({required this.activeLeft, required this.activeRight});

  // Semitone offsets of white keys within one octave
  static const _whiteOffsets = [0, 2, 4, 5, 7, 9, 11];
  // Semitone offsets where a black key follows white key at same index
  static const _blackAfterWk = {0, 1, 3, 4, 5};

  static const _octaveStart = 3; // C3
  static const _octaveCount = 2; // C3–C5 = 2 octaves

  @override
  void paint(Canvas canvas, Size size) {
    final totalWhite = 7 * _octaveCount + 1; // 15
    final wkW = size.width / totalWhite;
    final bkW = wkW * 0.62;
    final bkH = size.height * 0.62;

    final bgPaint   = Paint()..color = const Color(0xFF1C2424);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final wkPaint   = Paint()..color = const Color(0xFFD6E0E0);
    final divPaint  = Paint()
      ..color = const Color(0xFF849495)
      ..strokeWidth = 0.8;
    final bkPaint   = Paint()..color = const Color(0xFF0A0E10);

    int wIdx = 0;
    // Draw white keys
    for (int oct = 0; oct < _octaveCount; oct++) {
      for (final offset in _whiteOffsets) {
        final midi = (_octaveStart + oct) * 12 + offset;
        final x = wIdx * wkW;
        canvas.drawRect(Rect.fromLTWH(x, 0, wkW, size.height), wkPaint);
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), divPaint);
        _drawKeyGlow(canvas, x, wkW, size.height, midi);
        wIdx++;
      }
    }
    // Last C
    final lastMidi = (_octaveStart + _octaveCount) * 12;
    final lastX = wIdx * wkW;
    canvas.drawRect(Rect.fromLTWH(lastX, 0, wkW, size.height), wkPaint);
    _drawKeyGlow(canvas, lastX, wkW, size.height, lastMidi);

    // Draw black keys
    wIdx = 0;
    for (int oct = 0; oct < _octaveCount; oct++) {
      for (int wi = 0; wi < 7; wi++) {
        if (_blackAfterWk.contains(wi)) {
          final x = (wIdx + 1) * wkW - bkW / 2;
          canvas.drawRect(Rect.fromLTWH(x, 0, bkW, bkH), bkPaint);
        }
        wIdx++;
      }
    }
  }

  void _drawKeyGlow(
      Canvas canvas, double x, double wkW, double keyH, int midi) {
    final glowH = keyH * 0.28;
    if (activeLeft.contains(midi)) {
      canvas.drawRect(
        Rect.fromLTWH(x + 2, 0, wkW - 4, glowH),
        Paint()
          ..color = AppColors.neonCyan.withAlpha(200)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
    if (activeRight.contains(midi)) {
      canvas.drawRect(
        Rect.fromLTWH(x + 2, 0, wkW - 4, glowH),
        Paint()
          ..color = AppColors.magenta.withAlpha(200)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(_PianoPainter old) =>
      old.activeLeft != activeLeft || old.activeRight != activeRight;
}

// ─── Gradient Progress Bar ────────────────────────────────────────────────

class GradientProgressBar extends StatelessWidget {
  final double progress; // 0.0–1.0
  final String currentTime;
  final String totalTime;
  final ValueChanged<double>? onChanged;

  const GradientProgressBar({
    super.key,
    required this.progress,
    required this.currentTime,
    required this.totalTime,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (ctx, constraints) {
            return GestureDetector(
              onHorizontalDragUpdate: (d) {
                final box = ctx.findRenderObject() as RenderBox;
                final localX = box.globalToLocal(d.globalPosition).dx;
                onChanged?.call((localX / box.size.width).clamp(0.0, 1.0));
              },
              child: SizedBox(
                height: 20,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 20),
                  painter: _ProgressPainter(progress: progress),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(currentTime,
                style: AppTextStyle.labelMono(color: AppColors.onSurfaceVariant)),
            Text(totalTime,
                style: AppTextStyle.labelMono(color: AppColors.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  const _ProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const trackH = 3.0;
    final trackY = (size.height - trackH) / 2;
    final radius = const Radius.circular(2);

    // Track background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, trackY, size.width, trackH), radius),
      Paint()..color = AppColors.outlineVariant,
    );

    // Filled portion
    if (progress > 0) {
      final fillW = size.width * progress;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, trackY, fillW, trackH), radius),
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF9B51E0), AppColors.neonCyan],
          ).createShader(Rect.fromLTWH(0, trackY, fillW, trackH)),
      );

      // Thumb
      final thumbX = fillW.clamp(6.0, size.width - 6.0);
      canvas.drawCircle(
        Offset(thumbX, size.height / 2),
        5,
        Paint()..color = AppColors.neonCyan,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressPainter old) => old.progress != progress;
}

// ─── Floating Dock ────────────────────────────────────────────────────────

class FloatingDock extends StatelessWidget {
  final bool waitActive;
  final bool loopActive;
  final int handsMode; // 0=both, 1=left, 2=right
  final VoidCallback onWait;
  final VoidCallback onLoop;
  final VoidCallback onHands;

  const FloatingDock({
    super.key,
    required this.waitActive,
    required this.loopActive,
    required this.handsMode,
    required this.onWait,
    required this.onLoop,
    required this.onHands,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withAlpha(235),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DockButton(
            icon: Icons.hourglass_empty_rounded,
            label: 'WAIT',
            isActive: waitActive,
            onTap: onWait,
          ),
          const SizedBox(width: 28),
          _DockButton(
            icon: Icons.loop_rounded,
            label: 'LOOP',
            isActive: loopActive,
            onTap: onLoop,
          ),
          const SizedBox(width: 28),
          _DockButton(
            icon: Icons.pan_tool_outlined,
            label: 'HANDS',
            isActive: handsMode > 0,
            onTap: onHands,
          ),
        ],
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DockButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.neonCyan : AppColors.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyle.labelMono(color: color)),
        ],
      ),
    );
  }
}

// ─── Tempo Chip ───────────────────────────────────────────────────────────

class TempoChip extends StatelessWidget {
  final double tempo;
  final VoidCallback onTap;

  const TempoChip({super.key, required this.tempo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${tempo.toStringAsFixed(2)}x',
              style: AppTextStyle.mono(size: 13, color: AppColors.neonCyan),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.sync, color: AppColors.onSurfaceVariant, size: 13),
          ],
        ),
      ),
    );
  }
}

// ─── Track Control Bar ────────────────────────────────────────────────────

class TrackControlBar extends StatelessWidget {
  final bool isPlaying;
  final double tempo;
  final double progress;
  final String currentTime;
  final String totalTime;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onTempoTap;
  final ValueChanged<double> onProgressChanged;

  const TrackControlBar({
    super.key,
    required this.isPlaying,
    required this.tempo,
    required this.progress,
    required this.currentTime,
    required this.totalTime,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
    required this.onTempoTap,
    required this.onProgressChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Track controls
              _TrackButton(icon: Icons.skip_previous_rounded, onTap: onPrevious),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppColors.onPrimary,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _TrackButton(icon: Icons.skip_next_rounded, onTap: onNext),
              const Spacer(),
              // Tempo
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('TEMPO',
                      style: AppTextStyle.labelMono(
                          color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  TempoChip(tempo: tempo, onTap: onTempoTap),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          GradientProgressBar(
            progress: progress,
            currentTime: currentTime,
            totalTime: totalTime,
            onChanged: onProgressChanged,
          ),
        ],
      ),
    );
  }
}

class _TrackButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TrackButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: AppColors.onSurface, size: 28),
      ),
    );
  }
}
