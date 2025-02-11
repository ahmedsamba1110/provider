

import '../../app/generalImports.dart';

class AppThemeCubit extends Cubit<ThemeState> {
  AppThemeCubit() : super(ThemeState(HiveRepository.getCurrentTheme()));

  void changeTheme(AppTheme appTheme) {
    HiveRepository.setCurrentTheme(appTheme);
    emit(ThemeState(appTheme));
  }

  void toggleTheme() {
    if (state.appTheme == AppTheme.dark) {
      HiveRepository.setCurrentTheme(AppTheme.light);

      emit(ThemeState(AppTheme.light));
    } else {
      HiveRepository.setCurrentTheme(AppTheme.dark);

      emit(ThemeState(AppTheme.dark));
    }
  }

  bool isDarkMode() {
    return state.appTheme == AppTheme.dark;
  }
}

class ThemeState {

  ThemeState(this.appTheme);
  final AppTheme appTheme;
}
