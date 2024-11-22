import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tick_task/src/app_locale/language_bloc.dart';
import 'package:tick_task/src/core/bloc/loader_bloc.dart';
import 'package:tick_task/src/core/di/dependency.dart';
import 'package:tick_task/src/core/routes/router.dart';
import 'package:tick_task/src/feature/create_task/bloc/create_task_bloc.dart';
import 'package:tick_task/src/feature/home/home_bloc/home_bloc.dart';
import 'package:tick_task/src/feature/splash/splash_cubit/splash_cubit.dart';
import 'package:tick_task/src/feature/task_detail/bloc/task_detail_bloc.dart';
import 'package:tick_task/src/services/app_preferences_service.dart';
import 'package:tick_task/src/theme/theme_bloc/theme_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tick_task/src/widgets/global_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  // Initialize AppPreferencesService
  await AppPreferencesService().init();

  SL.loadAppServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LanguageBloc(
            appPreferencesService: SL.getIt<AppPreferencesService>(),
          )..add(LoadSavedLanguage()),
        ),
        BlocProvider(
          create: (context) => ThemeBloc(
            appPreferencesService: SL.getIt<AppPreferencesService>(),
          )..add(LoadSavedTheme()),
        ),
        BlocProvider(
          create: (context) => SplashCubit(
            appPreferencesService: SL.getIt<AppPreferencesService>(),
          ),
        ),
        BlocProvider(create: (context) => SL.get<LoaderBloc>()),
        BlocProvider(create: (context) => SL.get<HomeBloc>()),
        BlocProvider(create: (context) => SL.get<CreateTaskBloc>()),
        BlocProvider(create: (context) => SL.get<TaskDetailBloc>())
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, langState) {
              if (themeState is ThemeInitial && langState is LoadAppLanguage) {
                final themeBloc = context.read<ThemeBloc>();
                return GlobalLoader(
                  child: MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    theme: themeBloc.getTheme(themeState.currentTheme, false),
                    darkTheme:
                        themeBloc.getTheme(themeState.currentTheme, true),
                    themeMode: themeState.isDarkMode
                        ? ThemeMode.dark
                        : ThemeMode.light,
                    locale: Locale(langState.currentLanguageCode),
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    routerConfig: AppRouter.router,
                  ),
                );
              }
              // Return a loading indicator or default app state
              return const MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
