import 'package:get_it/get_it.dart';
import 'package:tick_task/src/app_locale/language_bloc.dart';
import 'package:tick_task/src/core/bloc/loader_bloc.dart';
import 'package:tick_task/src/data/repository/comments_repository.dart';
import 'package:tick_task/src/data/repository/task_repository.dart';
import 'package:tick_task/src/feature/completed_task/bloc/completed_task_bloc.dart';
import 'package:tick_task/src/feature/create_task/bloc/create_task_bloc.dart';
import 'package:tick_task/src/services/completed_tasks_storage.dart';
import 'package:tick_task/src/services/task_label_storage.dart';
import 'package:tick_task/src/services/timer_service.dart';
import 'package:tick_task/src/feature/home/home_bloc/home_bloc.dart';
import 'package:tick_task/src/feature/task_detail/bloc/task_detail_bloc.dart';
import 'package:tick_task/src/feature/splash/splash_cubit/splash_cubit.dart';
import 'package:tick_task/src/theme/theme_bloc/theme_bloc.dart';

import '../../services/app_preferences_service.dart';

abstract class SL {
  static final getIt = GetIt.instance;

  static T get<T extends Object>({String? instanceName}) {
    return getIt.get<T>(instanceName: instanceName);
  }

  static void rSingleTon<T extends Object>(T instance) {
    getIt.registerSingleton<T>(instance);
  }

  static void rLazySingleTon<T extends Object>(T Function() factoryFunc) {
    getIt.registerLazySingleton<T>(factoryFunc);
  }

  static void unregister<T extends Object>() {
    getIt.unregister(instance: T);
  }

  static void loadAppServiceLocator() {
    rLazySingleTon(() => TimerService());
    rLazySingleTon(() => AppPreferencesService());
    rLazySingleTon(() => TaskRepository());
    rLazySingleTon(() => CommentsRepository());
    rLazySingleTon(() => CompletedTaskBloc(
          completedTasksStorage: get<CompletedTasksStorage>(),
        ));
    rLazySingleTon(() => TaskLabelStorage());
    rLazySingleTon(
        () => ThemeBloc(appPreferencesService: get<AppPreferencesService>()));
    rLazySingleTon(() => LanguageBloc(
          appPreferencesService: get<AppPreferencesService>(),
        ));
    rLazySingleTon(() => SplashCubit(
          appPreferencesService: get<AppPreferencesService>(),
        ));
    rLazySingleTon(() => HomeBloc(
          taskRepository: get<TaskRepository>(),
          timerService: get<TimerService>(),
          labelStorage: get<TaskLabelStorage>(),
        ));
    rLazySingleTon(
      () => TaskDetailBloc(
        taskRepository: get<TaskRepository>(),
        commentsRepository: get<CommentsRepository>(),
        timerService: get<TimerService>(),
        completedTasksStorage: get<CompletedTasksStorage>(),
      ),
    );

    rLazySingleTon(() => CreateTaskBloc());
    rLazySingleTon(() => LoaderBloc());
    rLazySingleTon(() => CompletedTasksStorage());
    // initiallize the timers
    SL.getIt<TimerService>().initializeTimers();
  }
}
