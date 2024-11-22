import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tick_task/l10n/helper/localization_helper.dart';
import 'package:tick_task/l10n/helper/translation_keys.dart';

class TimeSpentWidget extends StatefulWidget {
  final Duration duration;
  final bool isRunning;
  final VoidCallback? onStartStop;
  final bool readOnly;
  final String? taskId;

  const TimeSpentWidget({
    super.key,
    required this.duration,
    required this.isRunning,
    this.onStartStop,
    this.readOnly = false,
    this.taskId,
  });

  @override
  State<TimeSpentWidget> createState() => _TimeSpentWidgetState();
}

class _TimeSpentWidgetState extends State<TimeSpentWidget> {
  Timer? _updateTimer;
  Duration _currentDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.duration;
    _setupTimer();
  }

  @override
  void didUpdateWidget(TimeSpentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRunning != widget.isRunning ||
        oldWidget.duration != widget.duration) {
      _currentDuration = widget.duration;
      _setupTimer();
    }
  }

  void _setupTimer() {
    _updateTimer?.cancel();
    if (widget.isRunning) {
      _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _currentDuration += const Duration(seconds: 1);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.get(AppTranslationStrings.timeSpent),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _formatDuration(_currentDuration),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 16),
                // if (!widget.readOnly && widget.onStartStop != null)
                //   IconButton(
                //     icon:
                //         Icon(widget.isRunning ? Icons.pause : Icons.play_arrow),
                //     onPressed: widget.onStartStop,
                //   ),
                if (widget.readOnly && widget.isRunning)
                  const Icon(
                    Icons.timer,
                    size: 16,
                    color: Colors.green,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
