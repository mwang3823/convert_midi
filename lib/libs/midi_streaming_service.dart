import 'dart:async';
import 'package:dart_midi_pro/dart_midi_pro.dart';
import 'package:flutter/services.dart';

import '../common/log_service.dart';

class MidiStreamingService {
  MidiFile? _midiFile;
  bool _isPlaying = false;

  Future<void> loadMidiFileFromAsset(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      _midiFile = MidiParser().parseMidiFromBuffer(bytes);
      LogService.instance.log(
          'Tải MIDI: $assetPath — ${_midiFile!.tracks.length} track(s), '
          'ticksPerBeat=${_midiFile!.header.ticksPerBeat}');
    } catch (e) {
      LogService.instance.log('Lỗi tải MIDI: $e');
      rethrow;
    }
  }

  void loadMidiFromBytes(List<int> bytes) {
    _midiFile = MidiParser().parseMidiFromBuffer(bytes);
    LogService.instance.log('Tải MIDI từ bytes thành công');
  }

  Future<void> playStream(Function(List<int>) writeCallback) async {
    if (_midiFile == null) {
      LogService.instance.log('playStream: chưa có file MIDI');
      return;
    }

    _isPlaying = true;

    final List<MidiEvent> eventsToPlay = [];
    for (var track in _midiFile!.tracks) {
      eventsToPlay.addAll(track);
    }

    int currentTempoUs = 500000; // 120 BPM
    final int ticksPerBeat = _midiFile!.header.ticksPerBeat ?? 480;
    int noteOnCount = 0;
    int noteOffCount = 0;

    LogService.instance.log(
        'Bắt đầu phát: ${eventsToPlay.length} sự kiện, ticksPerBeat=$ticksPerBeat');

    for (var event in eventsToPlay) {
      if (!_isPlaying) break;

      if (event.deltaTime > 0) {
        final double microsecondsPerTick = currentTempoUs / ticksPerBeat;
        final int delayMs =
            (event.deltaTime * microsecondsPerTick / 1000).round();
        if (delayMs > 0) {
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      }

      if (event is SetTempoEvent) {
        currentTempoUs = event.microsecondsPerBeat;
        final bpm = (60000000 / currentTempoUs).round();
        LogService.instance.log('Tempo: $bpm BPM ($currentTempoUs µs/beat)');
        continue;
      }

      if (event is NoteOnEvent) {
        final channel = event.channel & 0x0F;
        final statusByte = 0x90 | channel;
        final cmd = [statusByte, event.noteNumber, event.velocity];
        writeCallback(cmd);
        noteOnCount++;
        if (noteOnCount <= 5) {
          // Log 5 sự kiện đầu để xác nhận
          LogService.instance.log(
              'NoteOn ch=$channel note=${event.noteNumber} vel=${event.velocity}');
        } else if (noteOnCount == 6) {
          LogService.instance.log('... (không log tiếp NoteOn để tránh spam)');
        }
      } else if (event is NoteOffEvent) {
        final channel = event.channel & 0x0F;
        final statusByte = 0x80 | channel;
        final cmd = [statusByte, event.noteNumber, event.velocity];
        writeCallback(cmd);
        noteOffCount++;
      }
    }

    _isPlaying = false;
    LogService.instance.log(
        'Phát xong: $noteOnCount NoteOn, $noteOffCount NoteOff gửi đi');
  }

  void stop() {
    _isPlaying = false;
    LogService.instance.log('Dừng phát');
  }
}
