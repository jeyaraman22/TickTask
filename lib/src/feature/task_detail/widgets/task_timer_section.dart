import 'package:flutter/material.dart';
import 'package:tick_task/src/core/utils/app_colors.dart';
import 'package:tick_task/l10n/helper/localization_helper.dart';
import 'package:tick_task/l10n/helper/translation_keys.dart';

class TaskTimerSection extends StatelessWidget {
  final bool isRunning;
  final DateTime? startTime;
  final String elapsedTime;
  final VoidCallback onStart;
  final VoidCallback onPause;

  const TaskTimerSection({
    super.key,
    required this.isRunning,
    this.startTime,
    required this.elapsedTime,
    required this.onStart,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.get(AppTranslationStrings.timeTracker),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              _buildTimerButton(context),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            elapsedTime,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                ),
          ),
          if (startTime != null) ...[
            const SizedBox(height: 8),
            Text(
              '${context.l10n.get(AppTranslationStrings.startedAt)}: ${_formatTime(startTime!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimerButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: isRunning ? onPause : onStart,
      icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
      label: Text(
        isRunning
            ? context.l10n.get(AppTranslationStrings.pause)
            : context.l10n.get(AppTranslationStrings.start),
      ),
      style: FilledButton.styleFrom(
        backgroundColor:
            isRunning ? AppColors.pauseButton : AppColors.startButton,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
