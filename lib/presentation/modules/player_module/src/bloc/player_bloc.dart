import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../common/assets.dart';
import '../../../../../common/globals.dart';
import '../../../../../common/log_service.dart';
import '../../../../../libs/midi_streaming_service.dart';
import '../../../../base/base_view.dart';
import '../ui/player_screen.dart';

class PlayerBloc extends BaseBloc<PlayerScreen> {
  final _midiService  = MidiStreamingService();
  StreamSubscription<List<String>>? _logSub;

  final isPlaying      = BehaviorSubject<bool>.seeded(false);
  final showLog        = BehaviorSubject<bool>.seeded(true);
  final loadedFilePath = BehaviorSubject<String?>.seeded(null);
  final logs           = BehaviorSubject<List<String>>.seeded([]);

  final logScrollController = ScrollController();

  @override
  void onInit() {
    logs.set(List.from(LogService.instance.logs));
    _logSub = LogService.instance.stream.listen((newLogs) {
      logs.set(newLogs);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (logScrollController.hasClients) {
          logScrollController
              .jumpTo(logScrollController.position.maxScrollExtent);
        }
      });
    });
  }

  @override
  void onReady() {}

  @override
  void onResumed() {}

  @override
  void onDispose() {
    _logSub?.cancel();
    logScrollController.dispose();
    _midiService.stop();
    Globals.bluetoothService.disconnect();
    isPlaying.close();
    showLog.close();
    loadedFilePath.close();
    logs.close();
  }

  Future<void> loadAndPlay(String path) async {
    if (isPlaying.value) {
      _midiService.stop();
      isPlaying.set(false);
    }
    loadedFilePath.set(path);
    try {
      await _midiService.loadMidiFileFromAsset(path);
      togglePlay();
    } catch (e) {
      LogService.instance.log('Lỗi tải file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi tải file MIDI')),
        );
      }
    }
  }

  void togglePlay() {
    if (isPlaying.value) {
      _midiService.stop();
      isPlaying.set(false);
    } else {
      if (loadedFilePath.value == null) return;
      isPlaying.set(true);
      _midiService.playStream((List<int> cmd) {
        Globals.bluetoothService.sendRawData(cmd);
      }).then((_) {
        if (!isPlaying.isClosed) isPlaying.set(false);
      });
    }
  }

  void copyLog() async {
    final messenger = ScaffoldMessenger.of(context);
    final content   = await LogService.instance.readLogFile();
    await Clipboard.setData(ClipboardData(text: content));
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Đã copy log vào clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void clearLog() async {
    await LogService.instance.clearFile();
    logs.set([]);
  }

  List<Map<String, String>> get midiFiles => Assets.midiFiles;
}
