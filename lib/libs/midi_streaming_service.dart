import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dart_midi_pro/dart_midi_pro.dart';
import 'package:flutter/services.dart';

import '../common/log_service.dart';

class NoteScheduleItem {
  final double absTimeMs;
  final double durationMs;
  final int noteNumber;
  final bool isLeft;

  const NoteScheduleItem({
    required this.absTimeMs,
    required this.durationMs,
    required this.noteNumber,
    required this.isLeft,
  });
}

class _TimedEvent {
  final double absTimeMs;
  final MidiEvent event;

  const _TimedEvent(this.absTimeMs, this.event);
}

class MidiStreamingService {
  MidiFile? _midiFile;
  List<_TimedEvent>? _timedEvents;
  List<NoteScheduleItem>? _noteSchedule;
  bool _isPlaying = false;
  int _totalDurationMs = 0;

  int get totalDurationMs => _totalDurationMs;
  List<NoteScheduleItem> get noteSchedule => _noteSchedule ?? [];
  bool get isPlaying => _isPlaying;

  Future<void> loadMidiFileFromAsset(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      _midiFile = MidiParser().parseMidiFromBuffer(bytes);
      _preprocess();
      LogService.instance.log(
          'Tải MIDI từ asset: $assetPath — ${_midiFile!.tracks.length} track(s), '
          'ticksPerBeat=${_midiFile!.header.ticksPerBeat}');
    } catch (e) {
      LogService.instance.log('Lỗi tải MIDI từ asset: $e');
      rethrow;
    }
  }

  Future<void> loadMidiFileFromPath(String absolutePath) async {
    try {
      final List<int> bytes = await File(absolutePath).readAsBytes();
      _midiFile = MidiParser().parseMidiFromBuffer(bytes);
      _preprocess();
      LogService.instance.log(
          'Tải MIDI từ path: $absolutePath — ${_midiFile!.tracks.length} track(s), '
          'ticksPerBeat=${_midiFile!.header.ticksPerBeat}');
    } catch (e) {
      LogService.instance.log('Lỗi tải MIDI từ path: $e');
      rethrow;
    }
  }

  void loadMidiFromBytes(List<int> bytes) {
    _midiFile = MidiParser().parseMidiFromBuffer(bytes);
    _preprocess();
    LogService.instance.log('Tải MIDI từ bytes thành công');
  }

  void _preprocess() {
    if (_midiFile == null) return;

    final int ticksPerBeat = _midiFile!.header.ticksPerBeat ?? 480;

    // Build global tempo map (absolute ticks → tempoUs) from ALL tracks.
    // In type-1 MIDI, set_tempo lives in track 0; other tracks inherit it.
    final List<(int, int)> tempoMap = []; // (absTick, tempoUs)
    for (final track in _midiFile!.tracks) {
      int tick = 0;
      for (final event in track) {
        tick += event.deltaTime;
        if (event is SetTempoEvent) {
          tempoMap.add((tick, event.microsecondsPerBeat));
        }
      }
    }
    tempoMap.sort((a, b) => a.$1.compareTo(b.$1));

    // Convert absolute ticks → milliseconds using the shared tempo map.
    double _ticksToMs(int absTick) {
      double ms = 0.0;
      int prevTick = 0;
      int prevTempo = 500000;
      for (final (tmTick, tmUs) in tempoMap) {
        if (tmTick >= absTick) break;
        ms += (min(tmTick, absTick) - prevTick) * (prevTempo / ticksPerBeat / 1000.0);
        prevTick = tmTick;
        prevTempo = tmUs;
      }
      ms += (absTick - prevTick) * (prevTempo / ticksPerBeat / 1000.0);
      return ms;
    }

    final List<_TimedEvent> events = [];
    double maxMs = 0.0;

    for (final track in _midiFile!.tracks) {
      int absTick = 0;
      for (final event in track) {
        absTick += event.deltaTime;
        final double ms = _ticksToMs(absTick);
        events.add(_TimedEvent(ms, event));
        if (ms > maxMs) maxMs = ms;
      }
    }

    events.sort((a, b) => a.absTimeMs.compareTo(b.absTimeMs));
    _timedEvents = events;
    _totalDurationMs = maxMs.round();
    _noteSchedule = _computeNoteSchedule();
  }

  List<NoteScheduleItem> _computeNoteSchedule() {
    final List<NoteScheduleItem> schedule = [];
    final Map<(int, int), double> noteOnTimes = {}; // (channel, note) → absTimeMs

    for (final te in _timedEvents ?? []) {
      if (te.event is NoteOnEvent) {
        final e = te.event as NoteOnEvent;
        final key = (e.channel, e.noteNumber);
        if (e.velocity > 0) {
          noteOnTimes[key] = te.absTimeMs;
        } else {
          final onTime = noteOnTimes.remove(key);
          if (onTime != null) {
            schedule.add(NoteScheduleItem(
              absTimeMs: onTime,
              durationMs: te.absTimeMs - onTime,
              noteNumber: e.noteNumber,
              isLeft: e.noteNumber < 60,
            ));
          }
        }
      } else if (te.event is NoteOffEvent) {
        final e = te.event as NoteOffEvent;
        final key = (e.channel, e.noteNumber);
        final onTime = noteOnTimes.remove(key);
        if (onTime != null) {
          schedule.add(NoteScheduleItem(
            absTimeMs: onTime,
            durationMs: te.absTimeMs - onTime,
            noteNumber: e.noteNumber,
            isLeft: e.noteNumber < 60,
          ));
        }
      }
    }

    return schedule;
  }

  Future<void> playStreamFrom(
    int startMs,
    Function(List<int>) writeCallback, {
    double tempoMultiplier = 1.0,
    void Function(int noteNumber, bool isOn)? onNoteEvent,
    void Function()? onFinished,
  }) async {
    if (_midiFile == null || _timedEvents == null) {
      LogService.instance.log('playStreamFrom: chưa có file MIDI');
      return;
    }

    _isPlaying = true;
    final playStart = DateTime.now();

    for (final te in _timedEvents!) {
      if (!_isPlaying) break;
      if (te.absTimeMs < startMs) continue;

      final int targetRealMs =
          ((te.absTimeMs - startMs) / tempoMultiplier).round();
      final int elapsed =
          DateTime.now().difference(playStart).inMilliseconds;
      final int delay = max(0, targetRealMs - elapsed);

      if (delay > 0) {
        await Future.delayed(Duration(milliseconds: delay));
      }

      if (!_isPlaying) break;

      if (te.event is NoteOnEvent) {
        final e = te.event as NoteOnEvent;
        if (e.velocity > 0) {
          writeCallback([0x90, e.noteNumber, e.velocity]);
          onNoteEvent?.call(e.noteNumber, true);
        } else {
          writeCallback([0x80, e.noteNumber, e.velocity]);
          onNoteEvent?.call(e.noteNumber, false);
        }
      } else if (te.event is NoteOffEvent) {
        final e = te.event as NoteOffEvent;
        writeCallback([0x80, e.noteNumber, e.velocity]);
        onNoteEvent?.call(e.noteNumber, false);
      }
    }

    if (_isPlaying) {
      _isPlaying = false;
      onFinished?.call();
    }
  }

  void stop() {
    _isPlaying = false;
    LogService.instance.log('Dừng phát');
  }

  // Backward-compat alias used by legacy player screens
  Future<void> playStream(Function(List<int>) writeCallback) =>
      playStreamFrom(0, writeCallback);
}
