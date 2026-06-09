import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../common/assets.dart';
import '../../../../../common/globals.dart';
import '../../../../../common/theme.dart';
import '../../../../base/base_view.dart';
import '../ui/home_screen.dart';
import '../ui/playlist_detail_screen.dart';

class HomeBloc extends BaseBloc<HomeScreen> {
  String currentFocusTitle = '';
  String currentFocusComposer = '';
  double masteryProgress = 0.0;
  bool hasCurrentFocus = false;
  bool isSuggestion = false;

  late final List<Map<String, dynamic>> playlists =
      Assets.categorizedPlaylists.map((cat) {
    return {
      'name': cat['name'],
      'sessions': (cat['files'] as List).length,
    };
  }).toList();

  List<Map<String, String>> midiFiles = [];

  bool get isConnected =>
      Globals.bluetoothService.connectedDeviceName != null;
  StreamSubscription? _btSub;

  @override
  void onInit() {
    _btSub = Globals.bluetoothService.connectedNameStream.listen((_) {
      if (mounted) setState(() {});
    });
    _loadImportedMidiFiles().then((_) => _loadCurrentFocus());
  }

  // ─── Current Focus ────────────────────────────────────────────────────────

  Future<void> _loadCurrentFocus() async {
    final title = Globals.prefs.getString('current_focus_title');
    final composer = Globals.prefs.getString('current_focus_composer');
    final progress = Globals.prefs.getDouble('current_focus_progress');

    if (title.isNotEmpty) {
      currentFocusTitle = title;
      currentFocusComposer = composer;
      masteryProgress = progress;
      hasCurrentFocus = true;
      isSuggestion = false;
    } else {
      hasCurrentFocus = true;
      isSuggestion = true;
      if (midiFiles.isNotEmpty) {
        final random = Random();
        final item = midiFiles[random.nextInt(midiFiles.length)];
        currentFocusTitle = item['title']!;
        currentFocusComposer = item['artist']!;
        masteryProgress = 0.0;
      } else {
        hasCurrentFocus = false;
        currentFocusTitle = '';
        currentFocusComposer = '';
        masteryProgress = 0.0;
      }
    }
    if (mounted) setState(() {});
  }

  void _setCurrentFocus(String title, String composer, String path) {
    Globals.prefs.setString('current_focus_title', title);
    Globals.prefs.setString('current_focus_composer', composer);
    Globals.prefs.setString('current_focus_path', path);
    currentFocusTitle = title;
    currentFocusComposer = composer;
    hasCurrentFocus = true;
    isSuggestion = false;
    if (mounted) setState(() {});
  }

  // ─── Imported MIDI Files ──────────────────────────────────────────────────

  Future<void> _loadImportedMidiFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir
          .listSync()
          .where((f) =>
              f.path.endsWith('.mid') || f.path.endsWith('.midi'));
      for (final f in files) {
        final name = f.path.split('/').last.split('.').first;
        if (!midiFiles.any((m) => m['title'] == name)) {
          midiFiles.add({
            'title': name,
            'artist': 'Unknown Artist',
            'path': f.path,
          });
        }
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  void onReady() {}

  @override
  void onResumed() {
    _loadCurrentFocus();
  }

  @override
  void onDispose() {
    _btSub?.cancel();
  }

  // ─── Play Current Focus ───────────────────────────────────────────────────

  void onPlayCurrentFocus() {
    if (!mounted) return;
    final title    = Globals.prefs.getString('current_focus_title');
    final composer = Globals.prefs.getString('current_focus_composer');
    final path     = Globals.prefs.getString('current_focus_path');
    if (path.isEmpty) return;
    widget.onNavigateToStudio?.call(
      [{'title': title, 'composer': composer, 'path': path}],
      0,
    );
  }

  // ─── View All Playlists ───────────────────────────────────────────────────

  void onViewAllPlaylists() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            _buildSheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  Text('All Playlists', style: AppTextStyle.headlineMd()),
                  const Spacer(),
                  Text('${playlists.length} PLAYLISTS',
                      style: AppTextStyle.mono(
                          size: 10, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: playlists.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    onPlaylistTap(i);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withAlpha(20),
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(Icons.queue_music_rounded,
                              color: AppColors.neonCyan, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(playlists[i]['name'] as String,
                                  style: AppTextStyle.bold(size: 14)),
                              const SizedBox(height: 2),
                              Text(
                                  '${playlists[i]['sessions']} SESSIONS',
                                  style: AppTextStyle.mono(
                                      size: 10,
                                      color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.onSurfaceVariant, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Playlist Tap ─────────────────────────────────────────────────────────

  void onPlaylistTap(int index) {
    final cat = Assets.categorizedPlaylists[index];
    final songs = (cat['files'] as List)
        .map<Map<String, String>>((f) => {
              'title': f['title'] as String,
              'path': f['path'] as String,
            })
        .toList();

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistDetailScreen(
          playlistName: cat['name'] as String,
          songs: songs,
          onPlaySong: (song) {
            _setCurrentFocus(song['title']!, '', song['path']!);
            widget.onNavigateToStudio?.call(
              [{'title': song['title']!, 'composer': '', 'path': song['path']!}],
              0,
            );
          },
          onPlayAll: (allSongs) {
            if (allSongs.isEmpty) return;
            _setCurrentFocus(allSongs[0]['title']!, '', allSongs[0]['path']!);
            widget.onNavigateToStudio?.call(
              allSongs
                  .map((s) => {
                        'title': s['title']!,
                        'composer': '',
                        'path': s['path']!,
                      })
                  .toList(),
              0,
            );
          },
        ),
      ),
    );
  }

  // ─── Import New File ──────────────────────────────────────────────────────

  Future<void> onImportNewFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mid', 'midi'],
        withData: true,
      );
      if (result == null) return;

      final picked = result.files.single;
      final dir = await getApplicationDocumentsDirectory();
      final newPath = '${dir.path}/${picked.name}';

      if (picked.path != null) {
        await File(picked.path!).copy(newPath);
      } else if (picked.bytes != null) {
        await File(newPath).writeAsBytes(picked.bytes!);
      } else {
        return;
      }

      final name = picked.name
          .replaceAll(RegExp(r'\.(mid|midi)$', caseSensitive: false), '');
      if (!midiFiles.any((m) => m['title'] == name)) {
        midiFiles.add({
          'title': name,
          'artist': 'Unknown Artist',
          'path': newPath,
        });
        if (mounted) setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import thất bại: $e'),
            backgroundColor: AppColors.errorContainer,
          ),
        );
      }
    }
  }

  // ─── MIDI File Actions ────────────────────────────────────────────────────

  void onMidiFileTap(int index) {
    if (!mounted) return;
    final file = midiFiles[index];
    _setCurrentFocus(file['title']!, file['artist']!, file['path']!);
    widget.onNavigateToStudio?.call(
      [{'title': file['title']!, 'composer': file['artist']!, 'path': file['path']!}],
      0,
    );
  }

  void onMidiFileMenu(int index) {
    if (!mounted) return;
    final file = midiFiles[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.music_note_rounded,
                      color: AppColors.neonCyan, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(file['title']!,
                        style: AppTextStyle.bold(size: 15)),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.outlineVariant, height: 1),
            _buildMenuTile(
              ctx: sheetCtx,
              icon: Icons.star_outline_rounded,
              label: 'Set as Current Focus',
              onTap: () {
                Navigator.pop(sheetCtx);
                _setCurrentFocus(
                    file['title']!, file['artist']!, file['path']!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('"${file['title']}" đã được chọn làm bài hiện tại'),
                    backgroundColor: AppColors.surfaceContainerHigh,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            _buildMenuTile(
              ctx: sheetCtx,
              icon: Icons.delete_outline_rounded,
              label: 'Xoá file',
              color: AppColors.error,
              onTap: () {
                Navigator.pop(sheetCtx);
                _confirmDelete(index);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int index) {
    final file = midiFiles[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Xoá file?', style: AppTextStyle.bold(size: 16)),
        content: Text(
          'Xoá "${file['title']}" khỏi thư viện?',
          style: AppTextStyle.bodySm(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('HUỶ',
                style: AppTextStyle.mono(
                    size: 11, color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await File(file['path']!).delete();
              } catch (_) {}
              midiFiles.removeAt(index);
              if (mounted) setState(() {});
            },
            child: Text('XOÁ',
                style:
                    AppTextStyle.mono(size: 11, color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // ─── Streak / Connected ───────────────────────────────────────────────────

  void onStreakTap() {
    if (!mounted) return;
    widget.onNavigateToInsights?.call();
  }

  void onConnectedTap() {
    if (!mounted) return;
    if (isConnected) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Text('Thiết bị đã kết nối',
              style: AppTextStyle.bold(size: 16)),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bluetooth_connected,
                  color: AppColors.tertiaryFixed, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  Globals.bluetoothService.connectedDeviceName ?? 'Unknown',
                  style: AppTextStyle.bodyMd(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('ĐÓNG',
                  style: AppTextStyle.mono(
                      size: 11, color: AppColors.onSurfaceVariant)),
            ),
          ],
        ),
      );
    } else {
      widget.onConnectTap?.call();
    }
  }

  // ─── Shared UI Helpers ────────────────────────────────────────────────────

  Widget _buildSheetHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.outlineVariant,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext ctx,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.onSurface,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(label, style: AppTextStyle.bodyMd(color: color)),
          ],
        ),
      ),
    );
  }
}
