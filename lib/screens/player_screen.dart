import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/log_service.dart';
import '../libs/bluetooth_service.dart';
import '../libs/midi_streaming_service.dart';
import '../common/assets.dart';

class PlayerScreen extends StatefulWidget {
  final BluetoothService bluetoothService;

  const PlayerScreen({super.key, required this.bluetoothService});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final MidiStreamingService _midiService = MidiStreamingService();
  final ScrollController _logScrollController = ScrollController();
  bool _isPlaying = false;
  String? _loadedFilePath;
  List<String> _logs = [];
  bool _showLog = true;
  StreamSubscription<List<String>>? _logSub;

  @override
  void initState() {
    super.initState();
    _logs = List.from(LogService.instance.logs);
    _logSub = LogService.instance.stream.listen((logs) {
      if (mounted) {
        setState(() => _logs = logs);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_logScrollController.hasClients) {
            _logScrollController
                .jumpTo(_logScrollController.position.maxScrollExtent);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _logSub?.cancel();
    _logScrollController.dispose();
    _midiService.stop();
    widget.bluetoothService.disconnect();
    super.dispose();
  }

  Future<void> _loadAndPlay(String path) async {
    if (_isPlaying) {
      _midiService.stop();
      setState(() => _isPlaying = false);
    }

    setState(() => _loadedFilePath = path);

    try {
      await _midiService.loadMidiFileFromAsset(path);
      _togglePlay();
    } catch (e) {
      LogService.instance.log('Lỗi tải file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi tải file MIDI')),
        );
      }
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      _midiService.stop();
      setState(() => _isPlaying = false);
    } else {
      if (_loadedFilePath == null) return;
      setState(() => _isPlaying = true);
      _midiService.playStream((List<int> rawMidiCommand) {
        widget.bluetoothService.sendRawData(rawMidiCommand);
      }).then((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phát MIDI Stream'),
        actions: [
          IconButton(
            icon: Icon(_showLog ? Icons.terminal : Icons.terminal_outlined),
            tooltip: 'Hiện/ẩn log',
            onPressed: () => setState(() => _showLog = !_showLog),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy log vào clipboard',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final content = await LogService.instance.readLogFile();
              await Clipboard.setData(ClipboardData(text: content));
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Đã copy log vào clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Xoá log',
            onPressed: () async {
              await LogService.instance.clearFile();
              setState(() => _logs = []);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.bluetooth_connected, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.bluetoothService.connectedDeviceName ?? 'Unknown',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (_loadedFilePath != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _loadedFilePath!.split('/').last,
                      style: const TextStyle(color: Colors.blue),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _togglePlay,
                    icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(_isPlaying ? 'Dừng' : 'Phát lại'),
                  ),
                ],
              ),
            ),
            const Divider(height: 12),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Chọn bài nhạc:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          Expanded(
            flex: _showLog ? 2 : 1,
            child: ListView.builder(
              itemCount: Assets.midiFiles.length,
              itemBuilder: (context, index) {
                final item = Assets.midiFiles[index];
                final isSelected = item['path'] == _loadedFilePath;
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.music_note),
                  title: Text(item['name']!),
                  trailing: isSelected && _isPlaying
                      ? const Icon(Icons.graphic_eq, color: Colors.blue)
                      : null,
                  selected: isSelected,
                  onTap: () => _loadAndPlay(item['path']!),
                );
              },
            ),
          ),
          if (_showLog) ...[
            const Divider(height: 1),
            Container(
              color: Colors.black,
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.terminal, color: Colors.green, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'LOG (${_logs.length})',
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.black,
                child: ListView.builder(
                  controller: _logScrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    Color color = Colors.white70;
                    if (log.contains('lỗi') ||
                        log.contains('Lỗi') ||
                        log.contains('ERROR') ||
                        log.contains('CẢNH BÁO')) {
                      color = Colors.redAccent;
                    } else if (log.contains('BLE-MIDI') ||
                        log.contains('kết nối thành công') ||
                        log.contains('Tải MIDI')) {
                      color = Colors.greenAccent;
                    } else if (log.contains('BLE gửi:')) {
                      color = Colors.cyanAccent;
                    }
                    return Text(
                      log,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontFamily: 'monospace'),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
