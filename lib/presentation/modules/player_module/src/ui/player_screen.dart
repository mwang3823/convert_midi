import 'package:flutter/material.dart';
import '../../../../../common/globals.dart';
import '../../../../base/base_view.dart';
import '../bloc/player_bloc.dart';

// ignore: must_be_immutable
class PlayerScreen extends BaseView {
  // ignore: no_logic_in_create_state
  final PlayerBloc _bloc = PlayerBloc();

  PlayerScreen({super.key});

  @override
  // ignore: no_logic_in_create_state
  PlayerBloc createState() => _bloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phát MIDI Stream'),
        actions: [
          StreamBuilder<bool>(
            stream: _bloc.showLog.output,
            builder: (_, snap) {
              final show = snap.data ?? true;
              return IconButton(
                icon: Icon(show ? Icons.terminal : Icons.terminal_outlined),
                tooltip: 'Hiện/ẩn log',
                onPressed: () => _bloc.showLog.set(!show),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy log',
            onPressed: _bloc.copyLog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Xoá log',
            onPressed: _bloc.clearLog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Connected device name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.bluetooth_connected, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Globals.bluetoothService.connectedDeviceName ?? 'Unknown',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Current track row (conditional)
          StreamBuilder<String?>(
            stream: _bloc.loadedFilePath.output,
            builder: (_, pathSnap) {
              final path = pathSnap.data;
              if (path == null) return const SizedBox.shrink();
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            path.split('/').last,
                            style: const TextStyle(color: Colors.blue),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StreamBuilder<bool>(
                          stream: _bloc.isPlaying.output,
                          builder: (_, playSnap) {
                            final playing = playSnap.data ?? false;
                            return ElevatedButton.icon(
                              onPressed: _bloc.togglePlay,
                              icon: Icon(
                                  playing ? Icons.stop : Icons.play_arrow),
                              label: Text(playing ? 'Dừng' : 'Phát lại'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 12),
                ],
              );
            },
          ),
          // Track list header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Chọn bài nhạc:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          // Track list + log section (flex-adjustable)
          Expanded(
            child: StreamBuilder<bool>(
              stream: _bloc.showLog.output,
              builder: (_, showSnap) {
                final showLog = showSnap.data ?? true;
                return Column(
                  children: [
                    Expanded(
                      flex: showLog ? 2 : 1,
                      child: StreamBuilder<String?>(
                        stream: _bloc.loadedFilePath.output,
                        builder: (_, pathSnap2) {
                          final currentPath = pathSnap2.data;
                          return StreamBuilder<bool>(
                            stream: _bloc.isPlaying.output,
                            builder: (_, ps) {
                              final isPlay = ps.data ?? false;
                              return ListView.builder(
                                itemCount: _bloc.midiFiles.length,
                                itemBuilder: (_, index) {
                                  final item       = _bloc.midiFiles[index];
                                  final isSelected =
                                      item['path'] == currentPath;
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.music_note),
                                    title: Text(item['name']!),
                                    trailing: isSelected && isPlay
                                        ? const Icon(Icons.graphic_eq,
                                            color: Colors.blue)
                                        : null,
                                    selected: isSelected,
                                    onTap: () =>
                                        _bloc.loadAndPlay(item['path']!),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (showLog) ...[
                      const Divider(height: 1),
                      Container(
                        color: Colors.black,
                        height: 28,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        child: StreamBuilder<List<String>>(
                          stream: _bloc.logs.output,
                          builder: (_, ls) => Row(
                            children: [
                              const Icon(Icons.terminal,
                                  color: Colors.green, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'LOG (${ls.data?.length ?? 0})',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          color: Colors.black,
                          child: StreamBuilder<List<String>>(
                            stream: _bloc.logs.output,
                            builder: (_, snap) {
                              final logList = snap.data ?? [];
                              return ListView.builder(
                                controller: _bloc.logScrollController,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                itemCount: logList.length,
                                itemBuilder: (_, index) {
                                  final log = logList[index];
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
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
