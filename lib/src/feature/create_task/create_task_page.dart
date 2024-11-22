import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tick_task/src/core/di/dependency.dart';
import 'package:tick_task/src/core/utils/common_utils.dart';
import 'package:tick_task/l10n/helper/localization_helper.dart';
import 'package:tick_task/l10n/helper/translation_keys.dart';
import 'package:tick_task/src/data/model/custom_task_data.dart';
import 'package:tick_task/src/widgets/loading_overlay.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tick_task/src/feature/create_task/bloc/create_task_bloc.dart';

import '../task_detail/widgets/priority_toggle.dart';
import 'package:tick_task/src/core/utils/app_colors.dart';

// Enum to define different task categories
enum TaskCategory { todo, inProgress, done }

// Main page for creating new tasks
class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  CreateTaskPageState createState() => CreateTaskPageState();
}

class CreateTaskPageState extends State<CreateTaskPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _labelController = TextEditingController();

  // Task properties
  DateTime _dueDate = DateTime.now();
  TaskCategory _selectedCategory = TaskCategory.todo;
  int _selectedPriority = 1;
  bool _isLoading = false;

  // Build priority selection toggle widget
  Widget _buildPriorityToggle() {
    return PriorityToggle(
      selectedPriority: _selectedPriority,
      isEditing: true,
      onPriorityChanged: (priority) {
        setState(() => _selectedPriority = priority);
      },
    );
  }

  // Handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Create new task object from form data
      final newTask = TaskItem(
        _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        priority: _selectedPriority,
        labels: _labelController.text.isNotEmpty
            ? _labelController.text.split(',').map((e) => e.trim()).toList()
            : null,
        dueDate: _dueDate,
      );
      // Clear focus and submit task
      FocusScope.of(context).requestFocus(FocusNode());
      context.read<CreateTaskBloc>().add(
            SubmitTaskEvent(newTask, _selectedCategory),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: SL.getIt<CreateTaskBloc>(),
      // Listen for state changes to show success/error messages
      child: BlocListener<CreateTaskBloc, CreateTaskState>(
        listener: (context, state) {
          if (state is CreateTaskSuccess) {
            // Show success message and navigate back
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task created successfully!')),
            );
            GoRouter.of(context).pop();
          } else if (state is CreateTaskError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create task: ${state.error}')),
            );
          }
        },
        // Main form UI
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.backgroundColor,
              appBar: AppBar(
                title: Text(
                    context.l10n.get(AppTranslationStrings.createNewTask),
                    style: TextStyle(color: Colors.white.withOpacity(0.5))),
                backgroundColor: AppColors.backgroundColor,
                elevation: 0,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText:
                              '${context.l10n.get(AppTranslationStrings.title)} *',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF6C63FF)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _descriptionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF6C63FF)),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      _buildPriorityToggle(),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _labelController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText:
                              '${context.l10n.get(AppTranslationStrings.labels)} (Optional)',
                          hintText: context.l10n
                              .get(AppTranslationStrings.labelsHint),
                          hintStyle: const TextStyle(color: Colors.white30),
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF6C63FF)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDatePicker(context),
                      const SizedBox(height: 24),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Create Task'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading) const LoadingOverlay(),
          ],
        ),
      ),
    );
  }

  // Build date picker widget
  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.get(AppTranslationStrings.dueDate),
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: TextEditingController(
              text: CommonUtils.formatDate(_dueDate),
            ),
            readOnly: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: context.l10n.get(AppTranslationStrings.date),
              labelStyle: const TextStyle(color: Colors.white70),
              suffixIcon:
                  const Icon(Icons.calendar_today, color: Colors.white70),
              border: InputBorder.none,
            ),
            onTap: () async {
              final now = DateTime.now();
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _dueDate.isBefore(now) ? now : _dueDate,
                firstDate: now,
                lastDate: DateTime(now.year + 5),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: const Color(0xFF6C63FF),
                            onPrimary: Colors.white,
                            surface: AppColors.backgroundColor,
                            onSurface: const Color(0xFF6C63FF),
                          ),
                      dialogBackgroundColor: AppColors.backgroundColor,
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                setState(() => _dueDate = pickedDate);
              }
            },
          ),
        ),
      ],
    );
  }
}
