import '../../app/generalImports.dart';

class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoader extends LanguageState {
  LanguageLoader(this.languageCode);

  final dynamic languageCode;
}

class LanguageLoadFail extends LanguageState {}

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial());

  void loadCurrentLanguage() {
    emit(LanguageLoader(HiveRepository.getSelectedLanguageCode));
  }

  Future<void> changeLanguage(String languageName) async {
    HiveRepository.setSelectedLanguageCode = languageName;
    emit(LanguageLoader(languageName));
  }

  String getCurrentLanguageCode() {
  return HiveRepository.getSelectedLanguageCode;
  }
}
