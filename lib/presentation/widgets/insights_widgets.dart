import 'dart:math';
import 'package:flutter/material.dart';
import '../../common/theme.dart';

// ─── Accuracy Ring ────────────────────────────────────────────────────────

class AccuracyRing extends StatelessWidget {
  final double accuracy; // 0.0 – 1.0
  final double size;

  const AccuracyRing({super.key, required this.accuracy, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final pct = (accuracy * 100).toInt();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(progress: accuracy),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pct%',
                style: AppTextStyle.displayLg(color: AppColors.onSurface),
              ),
              Text(
                'ACCURACY',
                style: AppTextStyle.labelMono(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.outlineVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    // Glow layer
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = AppColors.neonCyan.withAlpha(45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round,
    );

    // Main arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = AppColors.neonCyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── Stat Item ────────────────────────────────────────────────────────────

class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = AppColors.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.labelMono(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.jetBrainsMono,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: valueColor,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

// ─── Piano Heatmap ────────────────────────────────────────────────────────

class PianoHeatmap extends StatelessWidget {
  const PianoHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: CustomPaint(painter: _PianoHeatmapPainter()),
    );
  }
}

class _PianoHeatmapPainter extends CustomPainter {
  // [barStatus: 0=none, 1=late/magenta, 2=perfect/green, barHeightFactor]
  static const _timing = [
    [0, 0.00], // C
    [0, 0.00], // D
    [2, 0.48], // E — perfect
    [0, 0.00], // F
    [1, 0.74], // G — late, tall
    [1, 0.44], // A — late
    [1, 0.62], // B — late
    [1, 0.34], // C — late, short
  ];
  // Black keys appear after white key index:
  static const _blackAfter = {0, 1, 3, 4, 5};

  @override
  void paint(Canvas canvas, Size size) {
    const wkCount = 8;
    final wkW = size.width / wkCount;
    final bkW = wkW * 0.62;
    final bkH = size.height * 0.56;

    final wkPaint  = Paint()..color = const Color(0xFF1C2626);
    final bkPaint  = Paint()..color = const Color(0xFF080F10);
    final sepPaint = Paint()
      ..color = AppColors.outlineVariant.withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // 1. White keys
    for (int i = 0; i < wkCount; i++) {
      final x = i * wkW;
      canvas.drawRect(Rect.fromLTWH(x, 0, wkW, size.height), wkPaint);
      canvas.drawRect(Rect.fromLTWH(x, 0, wkW, size.height), sepPaint);
    }

    // 2. Timing bars
    for (int i = 0; i < _timing.length; i++) {
      final status = _timing[i][0] as int;
      final hFactor = _timing[i][1] as double;
      if (status == 0) continue;
      final color = status == 1 ? AppColors.magenta : AppColors.emerald;
      final barH  = size.height * hFactor;
      canvas.drawRect(
        Rect.fromLTWH(i * wkW + 2, size.height - barH, wkW - 4, barH),
        Paint()..color = color,
      );
    }

    // 3. Black keys on top
    for (int i = 0; i < wkCount - 1; i++) {
      if (_blackAfter.contains(i)) {
        final x = (i + 1) * wkW - bkW / 2;
        canvas.drawRect(Rect.fromLTWH(x, 0, bkW, bkH), bkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Timing Errors Card ───────────────────────────────────────────────────

class TimingErrorsCard extends StatelessWidget {
  const TimingErrorsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TIMING\nERRORS',
                        style: AppTextStyle.bold(size: 18, color: AppColors.onSurface)),
                    const SizedBox(height: 2),
                    Text('C3 - C5 RANGE\nANALYSIS',
                        style: AppTextStyle.labelMono(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Row(
                children: [
                  _Legend(color: AppColors.magenta, label: 'Late'),
                  const SizedBox(width: 12),
                  _Legend(color: AppColors.emerald,  label: 'Perfect'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PianoHeatmap(),
          const SizedBox(height: 14),
          _buildWarningNote(),
        ],
      ),
    );
  }

  Widget _buildWarningNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3,
          height: 52,
          color: AppColors.magenta,
          margin: const EdgeInsets.only(right: 10),
        ),
        const Icon(Icons.warning_amber_rounded, color: AppColors.magenta, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Consistent 40ms late strike detected on middle C octave. '
            'This may be due to posture or wrist tension.',
            style: AppTextStyle.bodySm(color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyle.labelMono(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

// ─── AI Insight Card ──────────────────────────────────────────────────────

class AiInsightCard extends StatelessWidget {
  final String insightText;
  final int targetBpm;
  final String focusZone;

  const AiInsightCard({
    super.key,
    required this.insightText,
    required this.targetBpm,
    required this.focusZone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(Icons.psychology_outlined,
                    color: AppColors.neonCyan, size: 20),
              ),
              const SizedBox(width: 10),
              Text('AI INSIGHT',
                  style: AppTextStyle.bold(size: 16, color: AppColors.neonCyan)),
            ],
          ),
          const SizedBox(height: 12),
          Text(insightText,
              style: AppTextStyle.bodyMd(color: AppColors.onSurface)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _MetricBox(label: 'TARGET BPM', value: '$targetBpm')),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricBox(
                  label: 'FOCUS ZONE',
                  value: focusZone,
                  valueColor: AppColors.magenta,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MetricBox({
    required this.label,
    required this.value,
    this.valueColor = AppColors.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.labelMono(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.spaceGrotesk,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Practice Again Button ────────────────────────────────────────────────

class PracticeAgainButton extends StatelessWidget {
  final VoidCallback onTap;

  const PracticeAgainButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.neonCyan,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withAlpha(70),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PRACTICE AGAIN',
              style: AppTextStyle.bold(size: 15, color: AppColors.onPrimary),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.replay_rounded, color: AppColors.onPrimary, size: 20),
          ],
        ),
      ),
    );
  }
}
