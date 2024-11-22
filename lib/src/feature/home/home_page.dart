import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tick_task/src/core/di/dependency.dart';
import 'package:tick_task/src/core/routes/router.dart';
import 'package:tick_task/src/feature/home/widgets/draggable_list_view.dart';
import 'package:tick_task/src/feature/home/widgets/menu_side_drawer.dart';
import 'package:tick_task/l10n/helper/localization_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tick_task/src/feature/home/home_bloc/home_bloc.dart';
import 'package:tick_task/src/data/repository/task_repository.dart';
import 'package:tick_task/src/services/task_label_storage.dart';
import 'package:tick_task/src/services/timer_service.dart';
import '../../../l10n/helper/translation_keys.dart';
import '../../core/utils/app_colors.dart';

// Main home page widget that provides BLoC and navigation handling
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Initialize HomeBloc with required dependencies
      create: (context) => HomeBloc(
        taskRepository: SL.get<TaskRepository>(),
        timerService: SL.get<TimerService>(),
        labelStorage: SL.get<TaskLabelStorage>(),
      )..add(FetchTasks()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<HomeBloc, HomeState>(
            // Listen for navigation and update events
            listenWhen: (previous, current) =>
                current is MoveToTaskDetailsState ||
                current is MoveToAddTaskPageState ||
                current is HomePageUpdateState,
            listener: (context, state) {
              if (state is TaskUpdatedState || state is HomePageUpdateState) {
                // Preserve timer state when refreshing after updates
                context
                    .read<HomeBloc>()
                    .add(FetchTasks(preserveTimerState: true));
              }
              // Handle navigation to task details
              if (state is MoveToTaskDetailsState) {
                context.push(AppRouter.taskDetailRoute,
                    extra: {'id': state.taskId}).then((_) {
                  context.read<HomeBloc>()
                    ..add(ResetNavigationState())
                    ..add(FetchTasks(preserveTimerState: true));
                });
              }
              // Handle navigation to create task page
              else if (state is MoveToAddTaskPageState) {
                context.push(AppRouter.createTaskRoute).then((_) {
                  context.read<HomeBloc>()
                    ..add(ResetNavigationState())
                    ..add(FetchTasks(preserveTimerState: true));
                });
              }
            },
          ),
        ],
        child: const HomePageContent(),
      ),
    );
  }
}

// Separate widget for the content to avoid rebuilding everything
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.get(AppTranslationStrings.appTitle)),
        actions: [
          // History button with completion animation
          BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) =>
                current is HomeInitial ||
                current is HomeLoaded ||
                current is HomeError,
            builder: (context, state) {
              // Animate history button on task completion
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0.0,
                  end: state is TaskCompletedState ? 1.0 : 0.0,
                ),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.0 + (value * 0.2),
                    child: IconButton(
                      icon: Stack(
                        children: [
                          const Icon(Icons.history),
                          // Show completion indicator
                          if (state is TaskCompletedState)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () =>
                          context.push(AppRouter.completedTaskRoute),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: const MenuSideDrawer(),
      // Main content area with task lists
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            current is HomeInitial ||
            current is HomeLoaded ||
            current is HomeError,
        builder: (context, state) {
          // Show error message if loading failed
          if (state is HomeError) {
            return Center(child: Text(state.message));
          }
          // Show task lists when data is loaded
          else if (state is HomeLoaded) {
            // Filter out completed tasks
            final activeTasks = state.tasks
                .where((task) => !(task.isCompleted ?? false))
                .toList();

            return DragDropListsPage(
              tasks: activeTasks,
              key: ValueKey(activeTasks.hashCode),
            );
          }
          // Show loading placeholder
          return Container(
            color: AppColors.backgroundColor,
            height: MediaQuery.of(context).size.height,
          );
        },
      ),
    );
  }
}
