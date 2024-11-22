import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tick_task/src/data/model/task_response.dart';
import 'package:tick_task/src/feature/completed_task/completed_task_page.dart';
import 'package:tick_task/src/feature/create_task/create_task_page.dart';
import 'package:tick_task/src/feature/home/home_page.dart';
import 'package:tick_task/src/feature/splash/splash_page.dart';
import 'package:tick_task/src/feature/task_detail/task_detail_page.dart';

import '../../feature/home/widgets/draggable_list_view.dart';

class AppRouter {
  static GoRouter get router => _router;

  static const splashScreenRoute = '/';
  static const homeRoute = '/home_screen';
  static const createTaskRoute = '/create_task_screen';
  static const completedTaskRoute = '/complete_task_screen';
  static const taskDetailRoute = '/task_detail_screen/:id';
  static const taskHistoryRoute = '/history_screen';

  static Widget _splashRouteBuilder(
          BuildContext context, GoRouterState state) =>
      const SplashPage();
  static Widget _homeRouteBuilder(BuildContext context, GoRouterState state) =>
      const HomePage();
  static Widget _completedTaskRouteBuilder(
      BuildContext context, GoRouterState state) {
    return const CompletedTaskPage();
  }

  static Widget _createTaskRouteBuilder(
      BuildContext context, GoRouterState state) {
    return const CreateTaskPage();
  }

  static Widget _taskDetailRouteBuilder(
      BuildContext context, GoRouterState state) {
    Map<String, dynamic> args = state.extra as Map<String, dynamic>;
    String taskId = args['id'].toString();
    return TaskDetailPage(taskId: taskId);
  }

  // static void navigateToTaskDetail(
  //   BuildContext context, {
  //   required String taskId,
  //   required TaskCategory currentCategory,
  //   required Function(TaskItem, TaskCategory) onTaskUpdated,
  // }) {
  //   context.push(taskDetailRoute);
  // }

  static final GoRouter _router = GoRouter(
    initialLocation: splashScreenRoute,
    routes: [
      GoRoute(path: splashScreenRoute, builder: _splashRouteBuilder),
      GoRoute(path: homeRoute, builder: _homeRouteBuilder),
      GoRoute(path: completedTaskRoute, builder: _completedTaskRouteBuilder),
      GoRoute(path: createTaskRoute, builder: _createTaskRouteBuilder),
      GoRoute(path: taskDetailRoute, builder: _taskDetailRouteBuilder),
      // GoRoute(path: taskHistoryRoute, builder: _taskHistoryRouteBuilder),
      // GoRoute(path: taskHistoryRoute,builder: (context, state) => const HistoryPage()),
    ],
  );
}
