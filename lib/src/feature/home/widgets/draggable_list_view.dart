import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tick_task/l10n/helper/localization_helper.dart';
import 'package:tick_task/src/core/di/dependency.dart';
import 'package:tick_task/src/core/utils/app_colors.dart';
import 'package:tick_task/src/core/utils/common_utils.dart';
import 'package:tick_task/src/data/model/custom_task_data.dart';
import 'package:tick_task/src/data/model/task_response.dart';
import 'package:tick_task/src/feature/home/home_bloc/home_bloc.dart';
import 'package:tick_task/src/services/task_label_storage.dart';

import '../../../../l10n/helper/translation_keys.dart';
import '../../create_task/create_task_page.dart';

// Widget for displaying draggable task lists in different categories
class DragDropListsPage extends StatefulWidget {
  const DragDropListsPage({super.key, required this.tasks});
  final List<TodoistTaskResponseData> tasks;

  @override
  DragDropListsPageState createState() => DragDropListsPageState();
}

class DragDropListsPageState extends State<DragDropListsPage>
    with WidgetsBindingObserver {
  // Lists to hold tasks in different states
  List<TaskItem> todoList = [];
  List<TaskItem> inProgressList = [];
  List<TaskItem> doneList = [];

  // Controllers and variables for scroll behavior
  final Map<int, ScrollController> _scrollControllers = {};
  final Map<int, ScrollDirection> _scrollDirections = {};

  // UI colors for different lists
  final Color _backgroundColor = AppColors.backgroundColor;
  final List<Color> _listColors = [
    AppColors.todoListBackground.withOpacity(0.5),
    AppColors.inProgressListBackground.withOpacity(0.5),
    AppColors.doneListBackground.withOpacity(0.5),
  ];

  // Storage for task labels
  final TaskLabelStorage _labelStorage = SL.get<TaskLabelStorage>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize scroll controllers for each list
    for (int i = 0; i < 3; i++) {
      _scrollControllers[i] = ScrollController()
        ..addListener(() {
          setState(() {
            _scrollDirections[i] =
                _scrollControllers[i]!.position.userScrollDirection;
          });
        });
    }
    // Initialize lists and load saved timers
    _segregateTasks();
    _loadSavedTimers();
  }

  // Load saved timer states for all tasks
  Future<void> _loadSavedTimers() async {
    for (var list in [todoList, inProgressList, doneList]) {
      for (var task in list) {
        await task.loadSavedTimer();
      }
    }
    if (mounted) setState(() {});
  }

  // Segregate tasks into appropriate lists based on labels and completion status
  void _segregateTasks() async {
    // Clear existing lists
    todoList.clear();
    inProgressList.clear();
    doneList.clear();

    for (var task in widget.tasks) {
      // Get locally stored labels for this task
      final localLabels = await _labelStorage.getTaskLabels(task.id ?? '');
      final actualLabels = task.labels?.map((e) => e.toString()).toList();

      final TaskItem taskItem = TaskItem(task.content ?? '',
          id: task.id,
          description: task.description,
          priority: task.priority,
          labels: localLabels ?? actualLabels,
          dueDate:
              task.due?.date != null ? DateTime.parse(task.due!.date!) : null,
          commentCount: task.commentCount,
          createdAt: DateTime.parse(
              task.createdAt ?? DateTime.now().toIso8601String()),
          isCompleted: task.isCompleted);

      // Check local labels first, then fall back to actual labels if local are null
      if (localLabels != null) {
        if (localLabels.contains('Done') || task.isCompleted == true) {
          doneList.add(taskItem);
        } else if (localLabels.contains('Inprogress')) {
          inProgressList.add(taskItem);
        } else if (task.isCompleted != true) {
          todoList.add(taskItem);
        }
      } else if (actualLabels != null) {
        if (actualLabels.contains('Done') || task.isCompleted == true) {
          doneList.add(taskItem);
        } else if (actualLabels.contains('Inprogress')) {
          inProgressList.add(taskItem);
        } else if (task.isCompleted != true) {
          todoList.add(taskItem);
        }
      } else if (task.isCompleted != true) {
        // If no labels at all, default to todo list
        todoList.add(taskItem);
      }
    }

    // Sort todoList by creation time (latest first)
    todoList.sort((a, b) => (b.createdAt ?? DateTime.now())
        .compareTo(a.createdAt ?? DateTime.now()));

    if (mounted) setState(() {});
  }

  // Clean up resources when widget is disposed
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    // Save and stop all running timers
    for (var list in [todoList, inProgressList, doneList]) {
      for (var task in list) {
        task.stopTimer();
      }
    }
    super.dispose();
  }

  // Handle scroll notifications for animation effects
  bool _scrollNotification(ScrollNotification notification, int listIndex) {
    if (notification is ScrollEndNotification) {
      setState(() {
        _scrollDirections[listIndex] = ScrollDirection.idle;
      });
    }
    return true;
  }

  // Handle new task creation
  void _handleTaskCreated(TaskItem task, TaskCategory category) {
    setState(() {
      switch (category) {
        case TaskCategory.todo:
          todoList.add(task);
          break;
        case TaskCategory.inProgress:
          inProgressList.add(task);
          break;
        case TaskCategory.done:
          doneList.add(task);
          break;
      }
    });
    task.loadSavedTimer(); // Load timer state for new task
  }

  // Refresh all task lists
  void refreshTasks() {
    todoList.clear();
    inProgressList.clear();
    doneList.clear();
    _segregateTasks();
  }

  // Build the main UI with draggable lists
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              current is HomeInitial ||
              current is HomeLoaded ||
              current is HomeError,
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildDraggableList(
                            context.l10n
                                .get(AppTranslationStrings.todo)
                                .toUpperCase(),
                            todoList,
                            0),
                        _buildDraggableList(
                            context.l10n
                                .get(AppTranslationStrings.inProgress)
                                .toUpperCase(),
                            inProgressList,
                            1),
                        _buildDraggableList(
                            context.l10n
                                .get(AppTranslationStrings.done)
                                .toUpperCase(),
                            doneList,
                            2),
                      ],
                    ),
                  ),
                  // Add padding at bottom to avoid FAB overlap
                  const SizedBox(height: 80),
                ],
              ),
            );
          }),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: () => context.read<HomeBloc>().add(MoveToAddTaskPage()),
          /*AppRouter.navigateToCreateTask(
            context,
            _handleTaskCreated,
          ),*/
          backgroundColor: const Color(0xFF6C63FF),
          icon: const Icon(Icons.add),
          label: Text(context.l10n.get(AppTranslationStrings.addTask)),
        ),
      ),
    );
  }

  // Build individual draggable list
  Widget _buildDraggableList(String title, List<TaskItem> list, int listIndex) {
    return Expanded(
      child: DragTarget<DragData>(
        builder: (context, candidateData, rejectedData) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _listColors[listIndex],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) =>
                        _scrollNotification(notification, listIndex),
                    child: ListView.builder(
                      controller: _scrollControllers[listIndex],
                      itemCount: list.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return DragTarget<DragData>(
                          builder: (context, candidateData, rejectedData) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 70),
                              transform: Matrix4.rotationZ(
                                _scrollDirections[listIndex] ==
                                        ScrollDirection.forward
                                    ? 0.07
                                    : _scrollDirections[listIndex] ==
                                            ScrollDirection.reverse
                                        ? -0.07
                                        : 0,
                              ),
                              key: ValueKey('${listIndex}_$index'),
                              height: 50,
                              width: 125,
                              child: _buildDraggableCard(
                                  list[index], listIndex, index),
                            );
                          },
                          onWillAcceptWithDetails: (data) {
                            // Check if item is being dropped in the same position
                            final dragData = data.data;
                            final isSameList = dragData.sourceList == list;
                            final isSamePosition =
                                dragData.globalPosition == data.offset;
                            return !(isSameList && isSamePosition);
                          },
                          onAcceptWithDetails: (data) {
                            _handleDrop(data, _getListByIndex(listIndex));
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        onWillAcceptWithDetails: (data) {
          // Check if item is being dropped in the same position
          final dragData = data.data;
          final isSameList = dragData.sourceList == list;
          final isSamePosition = dragData.globalPosition == data.offset;
          return !(isSameList && isSamePosition);
        },
        onAcceptWithDetails: (data) {
          _handleDrop(data, _getListByIndex(listIndex));
        },
      ),
    );
  }

  // Build draggable card for individual task
  Widget _buildDraggableCard(TaskItem item, int listIndex, int itemIndex) {
    DragData dragData = DragData(
      item: item,
      sourceList: _getListByIndex(listIndex),
      sourceIndex: itemIndex,
      globalPosition: Offset.zero,
    );

    Color priorityColor = item.priority != null
        ? CommonUtils.getPriorityColor(item.priority!)
        : Colors.grey;

    return LongPressDraggable<DragData>(
      data: dragData,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: priorityColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item.title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCard(item, priorityColor),
      ),
      onDragStarted: () {},
      onDragEnd: (details) {
        dragData.globalPosition = details.offset;
      },
      child: GestureDetector(
        onTap: () {
          context
              .read<HomeBloc>()
              .add(MoveToTaskDetails(taskId: item.id ?? '0'));
          // GoRouter.of(context)
          //     .push(AppRouter.taskDetailRoute, extra: {'id': item.id});
        },
        child: _buildCard(item, priorityColor),
      ),
    );
  }

  // Build card UI for individual task
  Widget _buildCard(TaskItem item, Color priorityColor) {
    bool isInProgress = inProgressList.contains(item);

    // Assign the callback for UI updates
    item.onTimerUpdate = () {
      if (mounted) setState(() {});
    };

    return Card(
      color: priorityColor.withOpacity(0.75),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with ellipsis
            Expanded(
              child: SizedBox(
                width: 175,
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Priority and Comments row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'P${CommonUtils.getPriority(item.priority)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isInProgress)
                  GestureDetector(
                    child: Icon(
                      item.isTimerRunning ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                    onTap: () {
                      setState(() {
                        if (item.isTimerRunning) {
                          item.stopTimer();
                        } else {
                          item.startTimer();
                        }
                      });
                    },
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.comment, size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      '${item.commentCount ?? 0}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            // Timer row for in-progress tasks
            if (isInProgress)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const SizedBox(width: 8),
                  if (item.isTimerRunning || item.timeSpent.inSeconds > 0)
                    Text(
                      _formatDuration(item.timeSpent),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 2),
            GestureDetector(
                onTap: () => _showDeleteConfirmation(item),
                child:
                    Icon(Icons.delete_outline, color: Colors.white, size: 20))
          ],
        ),
      ),
    );
  }

  // Format duration for timer display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  // Get list reference by index
  List<TaskItem> _getListByIndex(int index) {
    switch (index) {
      case 0:
        return todoList;
      case 1:
        return inProgressList;
      case 2:
        return doneList;
      default:
        return [];
    }
  }

  // Handle app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Save current state but don't stop timers
        for (var list in [todoList, inProgressList, doneList]) {
          for (var task in list) {
            task.saveTimerState();
          }
        }
        break;
      case AppLifecycleState.resumed:
        // Reload and sync timers
        _loadSavedTimers();
        break;
      default:
        break;
    }
  }

  // Handle task movement to done list
  void _handleTaskMoveToDone(TaskItem task) {
    task.clearTimerData();
    // ... rest of your done list logic ...
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(TaskItem item) {
    showDialog(
      context: context,
      builder: (BuildContext cxt) {
        return AlertDialog(
          title: Text(context.l10n.get(AppTranslationStrings.deleteTask)),
          content: Text(
              context.l10n.get(AppTranslationStrings.deleteTaskConfirmation)),
          actions: [
            TextButton(
              child: Text(context.l10n.get(AppTranslationStrings.cancel)),
              onPressed: () => GoRouter.of(context).pop(),
            ),
            TextButton(
              child: Text(context.l10n.get(AppTranslationStrings.delete)),
              onPressed: () {
                final taskData = TodoistTaskResponseData(
                  id: item.id,
                  content: item.title,
                  description: item.description,
                  priority: item.priority,
                  labels: item.labels,
                );
                context.read<HomeBloc>().add(DeleteTask(taskData));
                GoRouter.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Handle task drop between lists
  void _handleDrop(
      DragTargetDetails<DragData> details, List<TaskItem> targetList) async {
    final dragData = details.data;

    setState(() {
      // Remove from source list
      dragData.sourceList.removeAt(dragData.sourceIndex);

      // Add to target list
      targetList.add(dragData.item);

      // Update task labels
      List<String> newLabels = List<String>.from(dragData.item.labels ?? []);

      // Remove existing status labels
      newLabels.removeWhere((label) =>
          label == 'Todo' || label == 'Inprogress' || label == 'Done');

      // Add new status label based on target list
      String newLabel = 'Todo';
      if (targetList == inProgressList) {
        newLabel = 'Inprogress';
      } else if (targetList == doneList) {
        newLabel = 'Done';
      }
      newLabels.add(newLabel);

      // Save updated labels locally
      _labelStorage.saveTaskLabel(dragData.item.id ?? '', newLabels);

      // Create updated task data
      final taskData = TodoistTaskResponseData(
        id: dragData.item.id,
        content: dragData.item.title,
        description: dragData.item.description,
        priority: dragData.item.priority,
        labels: newLabels,
        due: dragData.item.dueDate != null
            ? Due(date: dragData.item.dueDate!.toIso8601String())
            : null,
        commentCount: dragData.item.commentCount,
        isCompleted: targetList == doneList,
      );

      // Update task in backend
      context.read<HomeBloc>().add(UpdateTask(taskData));
    });
  }
}
