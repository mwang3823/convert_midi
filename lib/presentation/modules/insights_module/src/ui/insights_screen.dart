import 'package:flutter/material.dart';
import '../../../../../common/theme.dart';
import '../../../../base/base_view.dart';
import '../../../../widgets/home_widgets.dart';
import '../../../../widgets/insights_widgets.dart';
import '../bloc/insights_bloc.dart';

// ignore: must_be_immutable
class InsightsScreen extends BaseView {
  // ignore: no_logic_in_create_state
  final InsightsBloc _bloc = InsightsBloc();

  InsightsScreen({super.key});

  @override
  // ignore: no_logic_in_create_state
  InsightsBloc createState() => _bloc;

  // ─── Root ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                _buildAccuracySection(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),
                TimingErrorsCard(),
                const SizedBox(height: 16),
                AiInsightCard(
                  insightText: _bloc.aiInsight,
                  targetBpm: _bloc.targetBpm,
                  focusZone: _bloc.focusZone,
                ),
                const SizedBox(height: 24),
                PracticeAgainButton(onTap: _bloc.onPracticeAgain),
                const SizedBox(height: 20),
                _buildFooterActions(),
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
                    style: AppTextStyle.mono(size: 10, color: AppColors.onSurface)),
                Container(
                  width: 1,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: AppColors.outlineVariant,
                ),
                Text('CONNECTED',
                    style: AppTextStyle.mono(size: 10, color: AppColors.neonCyan)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Accuracy Ring Section ────────────────────────────────────────────────

  Widget _buildAccuracySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Center(
        child: AccuracyRing(accuracy: _bloc.accuracy, size: 200),
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StatItem(
          label: 'NOTES HIT',
          value: '${_bloc.notesHit}',
          valueColor: AppColors.neonCyan,
        ),
        StatItem(
          label: 'STREAK',
          value: '${_bloc.streak}',
          valueColor: AppColors.magenta,
        ),
        StatItem(
          label: 'AVG LATENCY',
          value: '${_bloc.avgLatencyMs}ms',
        ),
      ],
    );
  }

  // ─── Footer Actions ───────────────────────────────────────────────────────

  Widget _buildFooterActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _FooterAction(
          icon: Icons.share_outlined,
          label: 'SHARE RESULTS',
          onTap: _bloc.onShareResults,
        ),
        _FooterAction(
          icon: Icons.queue_music_outlined,
          label: 'JUKEBOX',
          onTap: _bloc.onJukebox,
        ),
      ],
    );
  }
}

// ─── Footer Action ────────────────────────────────────────────────────────

class _FooterAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FooterAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyle.labelMono(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
