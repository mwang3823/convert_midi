import 'package:flutter/material.dart';
import '../../common/log_service.dart';
import '../../common/theme.dart';

class DevLogOverlay extends StatefulWidget {
  final Widget child;
  const DevLogOverlay({super.key, required this.child});

  @override
  State<DevLogOverlay> createState() => _DevLogOverlayState();
}

class _DevLogOverlayState extends State<DevLogOverlay> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          right: 10,
          top: MediaQuery.of(context).padding.top + 56,
          child: GestureDetector(
            onTap: () => setState(() => _visible = !_visible),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _visible
                    ? AppColors.surfaceContainerHighest
                    : AppColors.surfaceContainerHigh.withValues(alpha: 0.80),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _visible ? AppColors.neonCyan : AppColors.outlineVariant,
                  width: _visible ? 1.5 : 0.5,
                ),
              ),
              child: Icon(
                Icons.terminal_rounded,
                size: 14,
                color:
                    _visible ? AppColors.neonCyan : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
        if (_visible)
          Positioned(
            right: 8,
            left: 8,
            top: MediaQuery.of(context).padding.top + 92,
            bottom: 72 + MediaQuery.of(context).padding.bottom,
            child: _LogPanel(onClose: () => setState(() => _visible = false)),
          ),
      ],
    );
  }
}

class _LogPanel extends StatefulWidget {
  final VoidCallback onClose;
  const _LogPanel({required this.onClose});

  @override
  State<_LogPanel> createState() => _LogPanelState();
}

class _LogPanelState extends State<_LogPanel> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xF0080F10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, thickness: 0.5, color: AppColors.outlineVariant),
            Expanded(child: _buildLogList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.neonCyan,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text('DEBUG LOG',
              style: AppTextStyle.mono(size: 10, color: AppColors.neonCyan)),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              await LogService.instance.clearFile();
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text('CLEAR',
                  style: AppTextStyle.mono(
                      size: 9, color: AppColors.onSurfaceVariant)),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: widget.onClose,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child:
                  Icon(Icons.close, size: 14, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    return StreamBuilder<List<String>>(
      stream: LogService.instance.stream,
      initialData: LogService.instance.logs,
      builder: (context, snap) {
        final logs = snap.data ?? [];
        if (logs.isEmpty) {
          return Center(
            child: Text('No logs yet.',
                style: AppTextStyle.mono(
                    size: 10, color: AppColors.onSurfaceVariant)),
          );
        }
        return ListView.builder(
          controller: _scroll,
          reverse: true,
          padding: const EdgeInsets.all(8),
          itemCount: logs.length,
          itemBuilder: (_, i) {
            final line = logs[logs.length - 1 - i];
            final isError = line.contains('lỗi') ||
                line.contains('Lỗi') ||
                line.contains('CẢNH BÁO') ||
                line.contains('thất bại');
            return Text(
              line,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9.5,
                color: isError
                    ? AppColors.amber
                    : const Color(0xFFBBCCCC),
                height: 1.45,
              ),
            );
          },
        );
      },
    );
  }
}
