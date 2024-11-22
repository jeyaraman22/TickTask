import 'package:flutter/material.dart';
import 'package:tick_task/src/core/utils/app_colors.dart';

class PriorityToggle extends StatelessWidget {
  final int selectedPriority;
  final bool isEditing;
  final ValueChanged<int>? onPriorityChanged;

  const PriorityToggle({
    super.key,
    required this.selectedPriority,
    required this.isEditing,
    this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildPriorityChips(),
      ],
    );
  }

  Widget _buildPriorityChips() {
    return Wrap(
      spacing: 8.0,
      children: List.generate(4, (index) {
        // Priority is 1-4, but index is 0-3
        final priority = 4 - index;
        return _PriorityChip(
          priority: priority,
          isSelected: selectedPriority == priority,
          isEnabled: isEditing,
          onSelected: isEditing
              ? (bool selected) {
                  if (selected) {
                    onPriorityChanged?.call(priority);
                  }
                }
              : null,
        );
      }),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final int priority;
  final bool isSelected;
  final bool isEnabled;
  final Function(bool)? onSelected;

  const _PriorityChip({
    required this.priority,
    required this.isSelected,
    required this.isEnabled,
    this.onSelected,
  });

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 4:
        return AppColors.priorityHigh;
      case 3:
        return AppColors.priorityMediumHigh;
      case 2:
        return AppColors.priorityMedium;
      case 1:
        return AppColors.priorityLow;
      default:
        return AppColors.priorityLow;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 4:
        return 'P1';
      case 3:
        return 'P2';
      case 2:
        return 'P3';
      case 1:
        return 'P4';
      default:
        return 'P4';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(priority);

    return FilterChip(
      label: Text(
        _getPriorityLabel(priority),
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: isEnabled ? onSelected : null,
      backgroundColor: Colors.transparent,
      selectedColor: color,
      side: BorderSide(
        color: color,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
