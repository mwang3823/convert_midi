import '../../../../base/base_view.dart';
import '../ui/insights_screen.dart';

class InsightsBloc extends BaseBloc<InsightsScreen> {
  final double accuracy     = 0.85;
  final int    notesHit     = 412;
  final int    streak       = 54;
  final int    avgLatencyMs = 12;
  final String trackTitle   = 'Für Elise';
  final String aiInsight    =
      'Try Tempo Trainer at 70% to master the syncopated bridge section.';
  final int    targetBpm    = 84;
  final String focusZone    = 'BRG';

  @override void onInit()    {}
  @override void onReady()   {}
  @override void onResumed() {}
  @override void onDispose() {}

  void onPracticeAgain() {}
  void onShareResults()  {}
  void onJukebox()       {}
}
