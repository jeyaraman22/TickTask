import 'package:flutter/material.dart';
import 'package:tick_task/l10n/helper/localization_helper.dart';
import 'package:tick_task/l10n/helper/translation_keys.dart';
import '../../../data/model/task_response.dart';
import 'priority_toggle.dart';

class TaskDetailsSection extends StatefulWidget {
  final TodoistTaskResponseData task;
  final bool isReadOnly;
  final Function(String?, String?, int?, DateTime?) onTaskUpdate;

  const TaskDetailsSection({
    super.key,
    required this.task,
    required this.isReadOnly,
    required this.onTaskUpdate,
  });

  @override
  State<TaskDetailsSection> createState() => _TaskDetailsSectionState();
}

class _TaskDetailsSectionState extends State<TaskDetailsSection> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _selectedPriority;
  late DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.task.content);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _selectedPriority = widget.task.priority ?? 0;
    _selectedDueDate = DateTime.tryParse(widget.task.due?.date ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTitle(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 16),
            PriorityToggle(
              selectedPriority: _selectedPriority,
              isEditing: _isEditing,
              onPriorityChanged: (priority) {
                setState(() => _selectedPriority = priority);
              },
            ),
            const SizedBox(height: 16),
            _buildDueDate(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.l10n.get(AppTranslationStrings.taskDetails),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: Icon(_isEditing ? Icons.save : Icons.edit),
          onPressed: _toggleEdit,
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return TextFormField(
      controller: _titleController,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: context.l10n.get(AppTranslationStrings.title),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDescription() {
    return TextFormField(
      controller: _descriptionController,
      enabled: _isEditing,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: context.l10n.get(AppTranslationStrings.description),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDueDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${context.l10n.get(AppTranslationStrings.dueDate)}: ${_selectedDueDate?.toString().split(' ')[0] ?? 'Not set'}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (_isEditing)
          TextButton(
            onPressed: _selectDueDate,
            child: Text(context.l10n.get(AppTranslationStrings.changeDate)),
          ),
      ],
    );
  }

  void _toggleEdit() {
    if (_isEditing) {
      widget.onTaskUpdate(
        _titleController.text,
        _descriptionController.text,
        _selectedPriority,
        _selectedDueDate,
      );
    }
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final initialDate =
        _selectedDueDate != null && _selectedDueDate!.isAfter(now)
            ? _selectedDueDate!
            : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
