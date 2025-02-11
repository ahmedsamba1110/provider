import 'package:edemand_partner/app/generalImports.dart';
import 'package:edemand_partner/cubits/applyForCustomJobCubit.dart';
import 'package:edemand_partner/cubits/chat/chatUsersCubit.dart';
import 'package:edemand_partner/cubits/fetchPreviousSubscriptionsCubit.dart';
import 'package:edemand_partner/cubits/getProviderDetails.dart';
import 'package:edemand_partner/cubits/manageCategoryPreferenceCubit.dart';
import 'package:edemand_partner/data/repository/chat/chatRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  //locked in portrait mode only
  SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ],
  );
  //

  if (Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  await Hive.initFlutter();
  await HiveRepository.init();

  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationCubit>(
          create: (BuildContext context) => AuthenticationCubit(),
        ),
        BlocProvider<SignInCubit>(
          create: (BuildContext context) => SignInCubit(),
        ),
        BlocProvider<ProviderDetailsCubit>(
          create: (BuildContext context) => ProviderDetailsCubit(),
        ),
        BlocProvider<AppThemeCubit>(
          create: (BuildContext context) => AppThemeCubit(),
        ),
        BlocProvider<LanguageCubit>(
          create: (BuildContext context) => LanguageCubit(),
        ),
        BlocProvider<FetchBookingsCubit>(
          create: (BuildContext context) => FetchBookingsCubit(),
        ),
        BlocProvider<FetchServicesCubit>(
          create: (BuildContext context) => FetchServicesCubit(),
        ),
        BlocProvider<FetchServiceReviewsCubit>(
          create: (BuildContext context) => FetchServiceReviewsCubit(),
        ),
        BlocProvider<FetchServiceCategoryCubit>(
          create: (BuildContext context) => FetchServiceCategoryCubit(),
        ),
        BlocProvider(
          create: (context) => UpdateFCMCubit(),
        ),
        BlocProvider<CreatePromocodeCubit>(
          create: (BuildContext context) => CreatePromocodeCubit(),
        ),
        BlocProvider<UpdateBookingStatusCubit>(
          create: (BuildContext context) => UpdateBookingStatusCubit(),
        ),
        BlocProvider<FetchReviewsCubit>(
          create: (BuildContext context) => FetchReviewsCubit(),
        ),
        BlocProvider<DeleteServiceCubit>(
          create: (BuildContext context) => DeleteServiceCubit(),
        ),
        BlocProvider<TimeSlotCubit>(
          create: (BuildContext context) => TimeSlotCubit(),
        ),
        BlocProvider<FetchPromocodesCubit>(
          create: (BuildContext context) => FetchPromocodesCubit(),
        ),
        BlocProvider<FetchStatisticsCubit>(
          create: (BuildContext context) => FetchStatisticsCubit(),
        ),
        BlocProvider<FetchSystemSettingsCubit>(
          create: (BuildContext context) => FetchSystemSettingsCubit(),
        ),
        BlocProvider<CountryCodeCubit>(
          create: (BuildContext context) => CountryCodeCubit(),
        ),
        BlocProvider<AuthenticationCubit>(
          create: (BuildContext context) => AuthenticationCubit(),
        ),
        BlocProvider<SendVerificationCodeCubit>(
          create: (BuildContext context) => SendVerificationCodeCubit(),
        ),
        BlocProvider<CountryCodeCubit>(
          create: (BuildContext context) => CountryCodeCubit(),
        ),
        BlocProvider<ResendOtpCubit>(
          create: (BuildContext context) => ResendOtpCubit(),
        ),
        BlocProvider<ChangePasswordCubit>(
          create: (BuildContext context) => ChangePasswordCubit(),
        ),
        BlocProvider<FetchTaxesCubit>(
          create: (BuildContext context) => FetchTaxesCubit(),
        ),
        BlocProvider<FetchPreviousSubscriptionsCubit>(
          create: (context) => FetchPreviousSubscriptionsCubit(),
        ),
        BlocProvider<VerifyPhoneNumberFromAPICubit>(
          create: (BuildContext context) => VerifyPhoneNumberFromAPICubit(
              authenticationRepository: AuthRepository()),
        ),
        BlocProvider<AddSubscriptionTransactionCubit>(
          create: (context) => AddSubscriptionTransactionCubit(),
        ),
        BlocProvider<GetProviderDetailsCubit>(
          create: (context) => GetProviderDetailsCubit(),
        ),
        BlocProvider<ChatUsersCubit>(
          create: (context) => ChatUsersCubit(ChatRepository()),
        ),
        BlocProvider<FetchJobRequestCubit>(
          create: (context) => FetchJobRequestCubit(),
        ),
        BlocProvider<ManageCustomJobValueCubit>(
            create: (context) => ManageCustomJobValueCubit()),
        BlocProvider<ApplyForCustomJobCubit>(
          create: (context) => ApplyForCustomJobCubit(),
        ),
        BlocProvider<ManageCategoryPreferenceCubit>(
          create: (context) => ManageCategoryPreferenceCubit(),
        )
      ],
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        context.read<LanguageCubit>().loadCurrentLanguage();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme currentTheme = context.watch<AppThemeCubit>().state.appTheme;

    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (BuildContext context, LanguageState languageState) {
        //unfocused and dismiss the keyboard when tapping outside of the form field
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: MaterialApp(
            title: appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: UiUtils.rootNavigatorKey,
            onGenerateRoute: Routes.onGenerateRouted,
            initialRoute: Routes.splash,
            theme: appThemeData[currentTheme],
            builder: (BuildContext context, Widget? widget) {
              return widget!;
            },
            localizationsDelegates: const [
              AppLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: appLanguages.map((AppLanguage language) {
              return UiUtils.getLocaleFromLanguageCode(language.languageCode);
            }).toList(),
            locale: (languageState is LanguageLoader)
                ? Locale(languageState.languageCode)
                : const Locale(defaultLanguageCode),
          ),
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
