import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';

import '../../../../../common/globals.dart';
import '../../../../../common/log_service.dart';
import '../../../../../libs/midi_streaming_service.dart';
import '../../../../base/base_view.dart';
import '../ui/studio_screen.dart';

class StudioBloc extends BaseBloc<StudioScreen> {
  final isPlaying  = BehaviorSubject<bool>.seeded(false);
  final tempo      = BehaviorSubject<double>.seeded(1.0);
  final progress   = BehaviorSubject<double>.seeded(0.0);
  final elapsedMs  = BehaviorSubject<double>.seeded(0.0);
  final activeNotes = BehaviorSubject<Set<int>>.seeded({});
  final waitActive = BehaviorSubject<bool>.seeded(false);
  final loopActive = BehaviorSubject<bool>.seeded(false);
  final handsMode  = BehaviorSubject<int>.seeded(0);

  final _midi = MidiStreamingService();

  String trackTitle    = '';
  String trackComposer = '';
  String trackPath     = '';

  List<Map<String, String>> _playlist = [];
  int _playlistIndex = 0;

  double _elapsedMs = 0.0;
  int _totalDurationMs = 0;

  Timer? _progressTimer;
  Set<int> _activeNotes = {};

  StreamSubscription? _btSub;

  List<NoteScheduleItem> get noteSchedule => _midi.noteSchedule;

  String get totalTime => _formatDuration(Duration(milliseconds: _totalDurationMs));
  String get currentTime => _formatDuration(Duration(milliseconds: _elapsedMs.round()));

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  int get playlistIndex => _playlistIndex;
  int get playlistLength => _playlist.length;
  bool get hasNext => _playlist.length > 1 && _playlistIndex < _playlist.length - 1;
  bool get hasPrev => _playlist.length > 1 && _playlistIndex > 0;

  bool get isConnected => Globals.bluetoothService.connectedDeviceName != null;

  @override
  void onInit() {
    _btSub = Globals.bluetoothService.connectedNameStream.listen((_) {
      if (mounted) setState(() {});
    });
    _restoreFromPrefs();
  }

  void _restoreFromPrefs() {
    final title    = Globals.prefs.getString('current_focus_title');
    final composer = Globals.prefs.getString('current_focus_composer');
    final path     = Globals.prefs.getString('current_focus_path');
    if (title.isNotEmpty && path.isNotEmpty) {
      _playlist = [{'title': title, 'composer': composer, 'path': path}];
      _playlistIndex = 0;
      _applyCurrentTrack(notify: false);
    }
  }

  void loadPlaylist(List<Map<String, String>> songs, int startIndex) {
    _stop();
    _playlist = List.of(songs);
    _playlistIndex = startIndex.clamp(0, songs.length - 1);
    _applyCurrentTrack();
  }

  Future<void> _applyCurrentTrack({bool notify = true}) async {
    if (_playlist.isEmpty) return;
    final song    = _playlist[_playlistIndex];
    trackTitle    = song['title']    ?? '';
    trackComposer = song['composer'] ?? '';
    trackPath     = song['path']     ?? '';

    try {
      final path = trackPath;
      if (path.startsWith('assets/')) {
        await _midi.loadMidiFileFromAsset(path);
      } else if (File(path).existsSync()) {
        await _midi.loadMidiFileFromPath(path);
      }
    } catch (_) {}

    _totalDurationMs = _midi.totalDurationMs;
    _elapsedMs = 0;
    progress.set(0.0);
    elapsedMs.set(0.0);
    isPlaying.set(false);
    _activeNotes = {};
    activeNotes.set({});

    if (notify && mounted) setState(() {});
  }

  Future<void> onPlayPause() async {
    if (isPlaying.value) {
      _pause();
    } else {
      await _play();
    }
  }

  int _sentCount = 0;

  Future<void> _play() async {
    if (trackPath.isEmpty) return;

    final deviceName = Globals.bluetoothService.connectedDeviceName;
    LogService.instance.log(
      'Phát: "$trackTitle" | BLE: ${deviceName ?? "chưa kết nối"} | '
      'Notes: ${_midi.noteSchedule.length} | Tempo: ${tempo.value}x | '
      'Từ: ${_formatDuration(Duration(milliseconds: _elapsedMs.round()))}',
    );

    isPlaying.set(true);
    _startProgressTimer();
    _sentCount = 0;

    final int startMs = _elapsedMs.round();
    final double tempoMult = tempo.value;
    final int handsVal = handsMode.value;

    await _midi.playStreamFrom(
      startMs,
      (cmd) => _sendBle(cmd, handsVal, cmd[1]),
      tempoMultiplier: tempoMult,
      onNoteEvent: (noteNumber, isOn) {
        if (isOn) {
          _activeNotes = {..._activeNotes, noteNumber};
        } else {
          _activeNotes = {..._activeNotes}..remove(noteNumber);
        }
        activeNotes.set(_activeNotes);
      },
      onFinished: _onTrackFinished,
    );
  }

  void _pause() {
    _midi.stop();
    _stopProgressTimer();
    isPlaying.set(false);
    _activeNotes = {};
    activeNotes.set({});
    LogService.instance.log('Tạm dừng. Đã gửi $_sentCount gói BLE.');
    Globals.bluetoothService.allNotesOff();
  }

  void _stop() {
    _midi.stop();
    _stopProgressTimer();
    isPlaying.set(false);
    _elapsedMs = 0;
    progress.set(0.0);
    elapsedMs.set(0.0);
    _activeNotes = {};
    activeNotes.set({});
    Globals.bluetoothService.allNotesOff();
  }

  void _onTrackFinished() {
    _stopProgressTimer();
    isPlaying.set(false);
    _activeNotes = {};
    activeNotes.set({});
    _saveMastery();

    if (!mounted) return;

    if (loopActive.value) {
      _elapsedMs = 0;
      _play();
    } else if (hasNext) {
      onNext();
    }
  }

  void _sendBle(List<int> cmd, int handsVal, int noteNumber) {
    if (handsVal == 1 && noteNumber >= 60) return;
    if (handsVal == 2 && noteNumber < 60) return;
    Globals.bluetoothService.sendRawData(cmd);
    _sentCount++;
    if (_sentCount == 1 || _sentCount % 20 == 0) {
      LogService.instance.log('Gói BLE #$_sentCount: ${cmd.map((b) => '0x${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join(' ')}');
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _elapsedMs += 50.0 * tempo.value;
      if (_totalDurationMs > 0) {
        progress.set((_elapsedMs / _totalDurationMs).clamp(0.0, 1.0));
      }
      elapsedMs.set(_elapsedMs);
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  void _saveMastery() {
    final current = Globals.prefs.getDouble('current_focus_progress');
    final updated = (current + 0.1).clamp(0.0, 1.0);
    Globals.prefs.setDouble('current_focus_progress', updated);
  }

  void onPrevious() {
    if (!hasPrev) return;
    _stop();
    _playlistIndex--;
    _applyCurrentTrack();
  }

  void onNext() {
    if (!hasNext) return;
    _stop();
    _playlistIndex++;
    _applyCurrentTrack();
  }

  void onTempoTap() {
    const tempos = [0.5, 0.75, 1.0, 1.25, 1.5];
    final current = tempo.value;
    final idx = tempos.indexWhere((t) => (t - current).abs() < 0.01);
    final nextIdx = (idx + 1) % tempos.length;
    final wasPlaying = isPlaying.value;
    if (wasPlaying) _pause();
    tempo.set(tempos[nextIdx]);
    if (wasPlaying) _play();
  }

  void onWaitToggle() {
    waitActive.set(!waitActive.value);
  }

  void onLoopToggle() {
    loopActive.set(!loopActive.value);
  }

  void onHandsToggle() {
    handsMode.set((handsMode.value + 1) % 3);
  }

  void onProgressChanged(double v) {
    if (_totalDurationMs <= 0) return;
    final wasPlaying = isPlaying.value;
    if (wasPlaying) _pause();
    _elapsedMs = (v * _totalDurationMs).clamp(0.0, _totalDurationMs.toDouble());
    progress.set(v);
    elapsedMs.set(_elapsedMs);
    if (wasPlaying) _play();
  }

  void onEndSession() {
    _stop();
  }

  @override
  void onReady() {}

  @override
  void onResumed() {
    _restoreFromPrefs();
  }

  @override
  void onDispose() {
    _midi.stop();
    _stopProgressTimer();
    _btSub?.cancel();
    isPlaying.close();
    tempo.close();
    progress.close();
    elapsedMs.close();
    activeNotes.close();
    waitActive.close();
    loopActive.close();
    handsMode.close();
  }
}
