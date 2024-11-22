import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/app_preferences_service.dart';

// Language bloc
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final AppPreferencesService _appPreferencesService;

  LanguageBloc({required AppPreferencesService appPreferencesService})
      : _appPreferencesService = appPreferencesService,
        super(LoadAppLanguage(appPreferencesService.getLocale())) {
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<LoadSavedLanguage>(_onLoadSavedLanguage);
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    await _appPreferencesService.saveLocale(event.languageCode);
    emit(LoadAppLanguage(event.languageCode));
  }

  void _onLoadSavedLanguage(
    LoadSavedLanguage event,
    Emitter<LanguageState> emit,
  ) {
    final savedLocale = _appPreferencesService.getLocale();
    emit(LoadAppLanguage(savedLocale));
  }
}

// Language events
abstract class LanguageEvent {}

class ChangeLanguageEvent extends LanguageEvent {
  final String languageCode;
  ChangeLanguageEvent(this.languageCode);
}

class LoadSavedLanguage extends LanguageEvent {}

// Language states
abstract class LanguageState {}

class LoadAppLanguage extends LanguageState {
  final String currentLanguageCode;
  LoadAppLanguage(this.currentLanguageCode);
}
