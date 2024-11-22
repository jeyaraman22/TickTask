import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tick_task/l10n/helper/localization_helper.dart';
import 'package:tick_task/l10n/helper/translation_keys.dart';
import 'package:tick_task/src/core/di/dependency.dart';
import 'package:tick_task/src/services/completed_tasks_storage.dart';

import '../../data/model/task_response.dart';
import 'bloc/completed_task_bloc.dart';

// Main page widget for displaying completed tasks
// Provides BLoC dependency and initiates task fetching
class CompletedTaskPage extends StatelessWidget {
  const CompletedTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // Initialize and fetch tasks immediately
      value: SL.getIt<CompletedTaskBloc>()..add(FetchCompletedTasks()),
      child: const CompletedTaskView(),
    );
  }
}

// Main view widget that handles the UI representation of completed tasks
class CompletedTaskView extends StatelessWidget {
  const CompletedTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.get(AppTranslationStrings.completedTasks)),
      ),
      // BlocBuilder handles different states of task loading
      body: BlocBuilder<CompletedTaskBloc, CompletedTaskState>(
        builder: (context, state) {
          // Loading state - show spinner
          if (state is CompletedTaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state - show error message and retry button
          if (state is CompletedTaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<CompletedTaskBloc>()
                        .add(FetchCompletedTasks()),
                    child: Text(context.l10n.get(AppTranslationStrings.retry)),
                  ),
                ],
              ),
            );
          }

          // Loaded state - show tasks or empty state
          if (state is CompletedTaskLoaded) {
            // Show empty state message if no tasks
            if (state.tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.get(AppTranslationStrings.noCompletedTasks),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n
                          .get(AppTranslationStrings.completedTasksHint),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Show list of completed tasks
            return ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return _CompletedTaskCard(task: task);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

// Card widget to display individual completed task details
// Shows task content, description, completion time, and due date
class _CompletedTaskCard extends StatelessWidget {
  const _CompletedTaskCard({required this.task});
  final TodoistTaskResponseData task;

  @override
  Widget build(BuildContext context) {
    final completedTasksStorage = SL.get<CompletedTasksStorage>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task title with completion icon
            Row(
              children: [
                const Icon(Icons.task_alt, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.content ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Optional description section
            if (task.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              // Description
              Text(
                task.description ?? '',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],

            // Task metadata section (time spent and due date)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Time spent information
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 18, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      FutureBuilder<Duration?>(
                        // Fetch and display task completion duration
                        future: completedTasksStorage
                            .getTaskCompletionTime(task.id ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final duration = snapshot.data!;
                            final hours = duration.inHours;
                            final minutes = (duration.inMinutes % 60);
                            final seconds = (duration.inSeconds % 60);
                            return Text(
                              'Time spent: ${hours}h ${minutes}m ${seconds}s',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            );
                          }
                          return const Text('Time spent: 0h 0m 0s');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Due date information
                  Row(
                    children: [
                      Icon(Icons.event, size: 18, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Due Date: ${task.due?.date ?? 'No deadline'}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
