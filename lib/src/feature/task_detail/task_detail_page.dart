import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tick_task/l10n/helper/localization_helper.dart';
import 'package:tick_task/l10n/helper/translation_keys.dart';
import 'package:tick_task/src/core/di/dependency.dart';
import 'package:tick_task/src/data/model/task_response.dart';
import 'package:tick_task/src/feature/task_detail/bloc/task_detail_bloc.dart';
import 'package:tick_task/src/feature/task_detail/widgets/comment_input.dart';
import 'package:tick_task/src/feature/task_detail/widgets/comments_section.dart';
import 'package:tick_task/src/feature/task_detail/widgets/task_details_section.dart';
import 'package:tick_task/src/feature/task_detail/widgets/time_spent_widget.dart';

// Main widget for displaying task details
class TaskDetailPage extends StatefulWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  // BLoC instance for managing task detail state
  late final TaskDetailBloc _taskDetailBloc;

  @override
  void initState() {
    super.initState();
    _taskDetailBloc = SL.getIt<TaskDetailBloc>();

    // Load task details after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Reset state first
        _taskDetailBloc.add(ResetState());
        // Then load new data
        _taskDetailBloc.add(LoadTaskAndComments(widget.taskId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _taskDetailBloc,
      child: TaskDetailView(taskId: widget.taskId),
    );
  }

  @override
  void dispose() {
    // Reset state when leaving the page
    _taskDetailBloc.add(ResetState());
    super.dispose();
  }
}

// Separate widget for task detail view to avoid unnecessary rebuilds
class TaskDetailView extends StatelessWidget {
  final String taskId;

  const TaskDetailView({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskDetailBloc, TaskDetailState>(
      builder: (context, state) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title:
                    Text(context.l10n.get(AppTranslationStrings.taskDetails)),
              ),
              body: _buildBody(context, state),
            ),
          ],
        );
      },
    );
  }

  // Build the main body based on current state
  Widget _buildBody(BuildContext context, TaskDetailState state) {
    if (state is TaskDetailLoaded) {
      // Check if task is completed or marked as done
      final bool isCompleted = state.task.isCompleted ??
          false || (state.task.labels?.contains('Done') ?? false);

      // Check if task can be marked as complete
      final bool canComplete = !isCompleted &&
          ((state.task.labels?.contains('Inprogress') ?? false) ||
              (state.task.labels?.contains('Done') ?? false));

      return Stack(
        children: [
          // Scrollable content area
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task details section with edit capability
                  TaskDetailsSection(
                    task: state.task,
                    isReadOnly: isCompleted,
                    onTaskUpdate: (title, description, priority, dueDate) {
                      if (!isCompleted) {
                        context.read<TaskDetailBloc>().add(UpdateTask(
                              title: title,
                              description: description,
                              priority: priority,
                              dueDate: dueDate,
                            ));
                      }
                    },
                  ),
                  // Timer widget showing time spent on task
                  TimeSpentWidget(
                    duration: state.timeSpent,
                    isRunning: state.isTimerRunning,
                    onStartStop: () {},
                  ),
                  const SizedBox(height: 16),
                  // Comments section with CRUD operations
                  CommentsSection(
                    comments: state.comments,
                    onDeleteComment: (commentId) {
                      context.read<TaskDetailBloc>().add(DeleteComment(
                            commentId: commentId,
                            taskId: taskId,
                          ));
                    },
                    onUpdateComment: (commentId, content) {
                      context.read<TaskDetailBloc>().add(UpdateComment(
                            commentId: commentId,
                            taskId: taskId,
                            newContent: content,
                          ));
                    },
                  ),
                  const SizedBox(height: 16),
                  // Input field for new comments
                  CommentInput(
                    onSubmit: (content) {
                      context.read<TaskDetailBloc>().add(AddComment(
                            taskId: taskId,
                            content: content,
                          ));
                    },
                  ),
                  const SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ),
          // Complete task button - only shown for eligible tasks
          if (canComplete)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Update labels for task completion
                  List<String> updatedLabels =
                      List<String>.from(state.task.labels ?? []);

                  if (!updatedLabels.contains('Done')) {
                    if (updatedLabels.contains('Inprogress')) {
                      updatedLabels.remove('Inprogress');
                    }
                    updatedLabels.add('Done');
                  }

                  // Create completed task data
                  final completedTask = TodoistTaskResponseData(
                    id: state.task.id,
                    content: state.task.content,
                    description: state.task.description,
                    priority: state.task.priority,
                    labels: updatedLabels,
                    isCompleted: true,
                    timeSpent: state.timeSpent,
                    isTimerRunning: false,
                  );

                  context
                      .read<TaskDetailBloc>()
                      .add(CompleteTask(completedTask));
                },
                child: Text(
                  context.l10n.get(AppTranslationStrings.completeTask),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    } else if (state is TaskDetailError) {
      // Error state with retry option
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Something went wrong'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context
                  .read<TaskDetailBloc>()
                  .add(LoadTaskAndComments(taskId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
