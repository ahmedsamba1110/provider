import '../app/generalImports.dart';

const String appName = 'Bareqq Provider';

const String baseUrl = 'https://edemand.wrteam.me/partner/api/v1/';

const bool isDemoMode = false;

//add your default country code here
const String defaultCountryCode = 'IN';

//if you do not want user to select another country rather than default country,
//then make below variable true
const bool allowOnlySingleCountry = false;

const Map<String, dynamic> dateAndTimeSetting = {
  "dateFormat": "dd/MM/yyyy",
  "use24HourFormat": false
};
//
const String defaultLanguageCode = 'en';
const String defaultLanguageName = 'English';

const List<AppLanguage> appLanguages = [
  //Please add language code here and language name and svg image in assets/images/svg/
  AppLanguage(
    languageCode: 'en',
    languageName: 'English',
  ),
  AppLanguage(
    languageCode: 'hi',
    languageName: 'हिन्दी - Hindi',
  ),
  AppLanguage(
    languageCode: 'ar',
    languageName: 'عربى - Arabic',
  ),
];
