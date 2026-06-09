import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../common/theme.dart';
import '../../models/scanned_device.dart';

// ─── Radar ────────────────────────────────────────────────────────────────────

class RadarWidget extends StatefulWidget {
  final bool isScanning;
  final bool isConnected;

  const RadarWidget({
    super.key,
    this.isScanning = false,
    this.isConnected = false,
  });

  @override
  State<RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<RadarWidget> with TickerProviderStateMixin {
  late final AnimationController _sweepCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _sweepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _syncAnimations();
  }

  @override
  void didUpdateWidget(RadarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isScanning != widget.isScanning) _syncAnimations();
  }

  void _syncAnimations() {
    if (widget.isScanning) {
      _sweepCtrl.repeat();
      _pulseCtrl.repeat();
    } else {
      _sweepCtrl.stop();
      _pulseCtrl.stop();
    }
  }

  @override
  void dispose() {
    _sweepCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
          ),
          // Middle ring
          Container(
            width: 172,
            height: 172,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.outlineVariant, width: 0.5),
            ),
          ),
          // Pulse rings
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  _PulseRing(progress: _pulseCtrl.value, delay: 0.0),
                  _PulseRing(progress: _pulseCtrl.value, delay: 0.5),
                ],
              );
            },
          ),
          // Sweep line
          AnimatedBuilder(
            animation: _sweepCtrl,
            builder: (_, _x) => widget.isScanning
                ? CustomPaint(
                    size: const Size(172, 172),
                    painter: _SweepPainter(_sweepCtrl.value),
                  )
                : const SizedBox.shrink(),
          ),
          // Center icon
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: widget.isConnected ? AppColors.emerald : AppColors.neonCyan,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(
              widget.isConnected ? Icons.check_rounded : Icons.bluetooth_searching,
              color: AppColors.onPrimary,
              size: 44,
            ),
          ),
          // Glow dots
          const Positioned(right: 44, top: 70,    child: _GlowDot(color: AppColors.emerald)),
          const Positioned(left: 44,  bottom: 70, child: _GlowDot(color: AppColors.emerald)),
        ],
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  final double progress;
  final double delay;

  const _PulseRing({required this.progress, required this.delay});

  @override
  Widget build(BuildContext context) {
    final t = ((progress + delay) % 1.0);
    final scale = 0.6 + t * 0.8;
    final opacity = (1.0 - t).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity * 0.35,
      child: Container(
        width: 172 * scale,
        height: 172 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl * scale),
          border: Border.all(color: AppColors.neonCyan, width: 1.5),
        ),
      ),
    );
  }
}

class _SweepPainter extends CustomPainter {
  final double progress;
  _SweepPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final angle = progress * 2 * math.pi - math.pi / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: angle - 1.2,
        endAngle: angle,
        colors: [
          AppColors.neonCyan.withAlpha(0),
          AppColors.neonCyan.withAlpha(120),
        ],
        transform: GradientRotation(angle - 1.2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        angle - 1.2,
        1.2,
        false,
      )
      ..close();

    canvas.save();
    final rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(AppRadius.xl),
    );
    canvas.clipRRect(rRect);
    canvas.drawPath(path, paint);
    canvas.restore();

    // Sweep line tip
    final tipPaint = Paint()
      ..color = AppColors.neonCyan.withAlpha(180)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(center, center + Offset(math.cos(angle) * radius, math.sin(angle) * radius), tipPaint);
  }

  @override
  bool shouldRepaint(_SweepPainter old) => old.progress != progress;
}

class _GlowDot extends StatelessWidget {
  final Color color;
  const _GlowDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withAlpha(160), blurRadius: 10, spreadRadius: 2)],
      ),
    );
  }
}

// ─── Scanning Card ────────────────────────────────────────────────────────────

class ScanningCard extends StatefulWidget {
  final bool isScanning;
  final bool isConnected;

  const ScanningCard({
    super.key,
    required this.isScanning,
    required this.isConnected,
  });

  @override
  State<ScanningCard> createState() => _ScanningCardState();
}

class _ScanningCardState extends State<ScanningCard> with TickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final AnimationController _dotCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _sync();
  }

  @override
  void didUpdateWidget(ScanningCard old) {
    super.didUpdateWidget(old);
    if (old.isScanning != widget.isScanning) _sync();
  }

  void _sync() {
    if (widget.isScanning) {
      _glowCtrl.repeat(reverse: true);
      _dotCtrl.repeat();
    } else {
      _glowCtrl.animateTo(0, duration: const Duration(milliseconds: 500));
      _dotCtrl.stop();
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  String _dots() {
    final step = (_dotCtrl.value * 4).floor();
    return '.' * (step >= 3 ? 0 : step + 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowCtrl, _dotCtrl]),
      builder: (_, _x) {
        final glow = _glowCtrl.value;
        final borderAlpha = (60 + glow * 130).round();
        final glowAlpha   = (glow * 28).round();

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: widget.isScanning
                  ? AppColors.neonCyan.withAlpha(borderAlpha)
                  : AppColors.outlineVariant,
              width: widget.isScanning ? 1.0 + glow * 0.5 : 0.5,
            ),
            boxShadow: widget.isScanning
                ? [
                    BoxShadow(
                      color: AppColors.neonCyan.withAlpha(glowAlpha),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
          child: Column(
            children: [
              RadarWidget(isScanning: widget.isScanning, isConnected: widget.isConnected),
              const SizedBox(height: 28),
              Opacity(
                opacity: widget.isScanning ? (0.70 + glow * 0.30) : 1.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      widget.isConnected
                          ? 'DEVICE CONNECTED'
                          : widget.isScanning
                              ? 'SCANNING FOR MIDI'
                              : 'SCAN COMPLETE',
                      style: AppTextStyle.headlineMd(
                        color: widget.isConnected ? AppColors.emerald : AppColors.neonCyan,
                      ),
                    ),
                    if (widget.isScanning && !widget.isConnected)
                      Text(
                        _dots(),
                        style: AppTextStyle.headlineMd(color: AppColors.neonCyan),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ACTIVE PROTOCOL: BLE-MIDI 2.0',
                style: AppTextStyle.labelMono(
                  color: widget.isScanning
                      ? Color.lerp(AppColors.onSurfaceVariant, AppColors.neonCyan, glow * 0.4)!
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Animated Banner Slot ─────────────────────────────────────────────────────

class AnimatedBannerSlot extends StatelessWidget {
  final bool visible;
  final Widget child;

  const AnimatedBannerSlot({super.key, required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      firstCurve: Curves.easeOut,
      secondCurve: Curves.easeIn,
      sizeCurve: Curves.easeInOut,
      crossFadeState: visible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: child,
      secondChild: const SizedBox.shrink(),
    );
  }
}

// ─── Saved Device Card ────────────────────────────────────────────────────────

class SavedDeviceCard extends StatelessWidget {
  final ScannedDevice device;
  final VoidCallback onReconnect;
  final VoidCallback onForget;

  const SavedDeviceCard({
    super.key,
    required this.device,
    required this.onReconnect,
    required this.onForget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.emerald.withAlpha(80), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('SAVED DEVICE', style: AppTextStyle.bold(size: 18)),
              const Spacer(),
              GestureDetector(
                onTap: onForget,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 16, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.emerald.withAlpha(60), width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withAlpha(30),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    device.type == DeviceType.ble ? Icons.piano : Icons.keyboard,
                    color: AppColors.emerald,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device.name, style: AppTextStyle.bold(size: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text('ID: ${device.id}',
                          style: AppTextStyle.mono(size: 9, color: AppColors.onSurfaceVariant),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onReconnect,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.emerald, width: 1.5),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Text('RECONNECT', style: AppTextStyle.labelMono(color: AppColors.emerald)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Device Item ──────────────────────────────────────────────────────────────

class DeviceItem extends StatelessWidget {
  final ScannedDevice device;
  final VoidCallback onConnect;
  final bool isSaved;
  final bool isConnected;

  const DeviceItem({
    super.key,
    required this.device,
    required this.onConnect,
    this.isSaved = false,
    this.isConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isConnected
            ? AppColors.emerald.withAlpha(15)
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isConnected
              ? AppColors.emerald.withAlpha(100)
              : AppColors.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              device.type == DeviceType.ble ? Icons.piano : Icons.keyboard,
              color: isConnected ? AppColors.emerald : AppColors.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(device.name,
                          style: AppTextStyle.bold(size: 15),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    if (isSaved) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withAlpha(30),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.amber.withAlpha(100)),
                        ),
                        child: Text('SAVED',
                            style: AppTextStyle.mono(size: 8, color: AppColors.amber)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text('ID: ${device.id}',
                    style: AppTextStyle.mono(size: 9, color: AppColors.onSurfaceVariant),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: isConnected ? null : onConnect,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isConnected ? AppColors.emerald.withAlpha(30) : Colors.transparent,
                border: Border.all(
                  color: isConnected ? AppColors.emerald : AppColors.neonCyan,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Text(
                isConnected ? 'CONNECTED' : 'CONNECT',
                style: AppTextStyle.labelMono(
                    color: isConnected ? AppColors.emerald : AppColors.neonCyan),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Banner ────────────────────────────────────────────────────────────

class StatusBanner extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final Color color;

  const StatusBanner({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.color = AppColors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: AppTextStyle.bodySm(color: color)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 1),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Text(actionLabel, style: AppTextStyle.labelMono(color: color)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Refresh FAB ──────────────────────────────────────────────────────────────

class RefreshFab extends StatelessWidget {
  final bool isScanning;
  final VoidCallback onRefresh;

  const RefreshFab({super.key, required this.isScanning, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isScanning ? null : onRefresh,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.neonCyan,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(color: AppColors.neonCyan.withAlpha(90), blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: isScanning
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
              )
            : const Icon(Icons.refresh_rounded, color: AppColors.onPrimary, size: 28),
      ),
    );
  }
}
