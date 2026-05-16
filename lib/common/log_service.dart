import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class LogService {
  static final LogService _instance = LogService._();
  LogService._();
  static LogService get instance => _instance;

  final List<String> _logs = [];
  final _controller = StreamController<List<String>>.broadcast();
  File? _logFile;

  List<String> get logs => List.unmodifiable(_logs);
  Stream<List<String>> get stream => _controller.stream;

  Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/midi_debug.log');
      final header =
          '\n\n=== SESSION ${DateTime.now().toIso8601String()} ===\n';
      await _logFile!.writeAsString(header, mode: FileMode.append);
    } catch (e) {
      debugPrint('LogService init error: $e');
    }
  }

  void log(String message) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final entry = '[$time] $message';
    _logs.add(entry);
    if (_logs.length > 300) _logs.removeAt(0);
    _controller.add(List.from(_logs));
    debugPrint('[APP] $entry');
    _logFile?.writeAsString('$entry\n', mode: FileMode.append).ignore();
  }

  Future<String> readLogFile() async {
    try {
      if (_logFile != null && await _logFile!.exists()) {
        return await _logFile!.readAsString();
      }
    } catch (_) {}
    return _logs.join('\n');
  }

  Future<void> clearFile() async {
    _logs.clear();
    _controller.add([]);
    try {
      await _logFile?.writeAsString('=== CLEARED ${DateTime.now().toIso8601String()} ===\n');
    } catch (_) {}
  }
}
