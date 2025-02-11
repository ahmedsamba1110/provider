import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      //
      try {
        context
            .read<ProviderDetailsCubit>()
            .setUserInfo(HiveRepository.getProviderDetails());
        //
        context
            .read<FetchSystemSettingsCubit>()
            .getSettings(isAnonymous: false);
        //
        context.read<CountryCodeCubit>().loadAllCountryCode(context);
        //
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: AppColors.splashScreenGradientTopColor,
            systemNavigationBarColor: AppColors.splashScreenGradientBottomColor,
          ),
        );
      } catch (_) {}
    });
  }

  void checkIsUserAuthenticated({required bool isNeedToShowAppUpdate}) {
    Future.delayed(const Duration(seconds: 2)).then((value) {
      //
      final AuthenticationState authenticationState =
          context.read<AuthenticationCubit>().state;
      if (authenticationState == AuthenticationState.authenticated) {
        if (context
                .read<ProviderDetailsCubit>()
                .providerDetails
                .providerInformation
                ?.isApproved ==
            '1') {
          Navigator.of(context).pushReplacementNamed(Routes.main);
        } else if (context
                .read<ProviderDetailsCubit>()
                .providerDetails
                .providerInformation
                ?.isApproved ==
            '0') {
          Navigator.pushReplacementNamed(
            context,
            Routes.registration,
            arguments: {'isEditing': false},
          );
        } else {
          Navigator.of(context).pushReplacementNamed(Routes.loginScreenRoute);
        }
      } else if (authenticationState == AuthenticationState.unAuthenticated ||
          authenticationState == AuthenticationState.firstTime) {
        Navigator.of(context).pushReplacementNamed(Routes.loginScreenRoute);
      }

      if (isNeedToShowAppUpdate) {
        Navigator.pushNamed(
          context,
          Routes.appUpdateScreen,
          arguments: {'isForceUpdate': false},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<FetchSystemSettingsCubit, FetchSystemSettingsState>(
        listener: (BuildContext context, FetchSystemSettingsState state) async {
          if (state is FetchSystemSettingsSuccess) {
            try {
              //update provider subscription information, backup for get latest payment method
              final SubscriptionInformation subscriptionInformation =
                  state.subscriptionInformation;
              context.read<ProviderDetailsCubit>().updateProviderDetails(
                  subscriptionInformation: subscriptionInformation);
              //
              final AppSetting _appSetting = state.appSetting;
              final GeneralSettings _generalSettings = state.generalSettings;

              UiUtils.maxCharactersInATextMessage = _generalSettings
                  .maxCharactersInATextMessage
                  .toString()
                  .toInt();
              UiUtils.maxFilesOrImagesInOneMessage = _generalSettings
                  .maxFilesOrImagesInOneMessage
                  .toString()
                  .toInt();
              UiUtils.maxFileSizeInMBCanBeSent =
                  _generalSettings.maxFileSizeInMBCanBeSent.toString().toInt();
              //
              // assign currency values
              UiUtils.systemCurrency = _appSetting.currency;
              UiUtils.systemCurrencyCountryCode =
                  _appSetting.countryCurrencyCode;
              UiUtils.decimalPointsForPrice = _appSetting.decimalPoint;

              //
              // if maintenance mode is enable then we will redirect to maintenance mode screen
              if (_appSetting.providerAppMaintenanceMode == '1') {
                Navigator.pushReplacementNamed(
                  context,
                  Routes.maintenanceModeScreen,
                  arguments: _appSetting.messageForProviderApplication,
                );
                return;
              }

              // here we will check current version and updated version from panel
              // if application current version is less than updated version then
              // we will show app update screen

              final String? latestAndroidVersion =
                  _appSetting.providerCurrentVersionAndroidApp;
              final String? latestIOSVersion =
                  _appSetting.providerCurrentVersionIosApp;

              final PackageInfo packageInfo = await PackageInfo.fromPlatform();

              final String currentApplicationVersion = packageInfo.version;

              final Version currentVersion =
                  Version.parse(currentApplicationVersion);
              final latestVersionAndroid = Version.parse(
                  latestAndroidVersion == ""
                      ? "1.0.0"
                      : latestAndroidVersion ?? '1.0.0');
              final latestVersionIos = Version.parse(latestIOSVersion == ""
                  ? "1.0.0"
                  : latestIOSVersion ?? "1.0.0");

              if ((Platform.isAndroid &&
                      latestVersionAndroid > currentVersion) ||
                  (Platform.isIOS && latestVersionIos > currentVersion)) {
                // If it is force update then we will show app update with only Update button
                if (_appSetting.providerCompulsaryUpdateForceUpdate == '1') {
                  Navigator.pushReplacementNamed(
                    context,
                    Routes.appUpdateScreen,
                    arguments: {'isForceUpdate': true},
                  );
                  return;
                } else {
                  // If it is normal update then
                  // we will pass true here for isNeedToShowAppUpdate
                  checkIsUserAuthenticated(isNeedToShowAppUpdate: true);
                }
              } else {
                //if no update available then we will pass false here for isNeedToShowAppUpdate
                checkIsUserAuthenticated(isNeedToShowAppUpdate: false);
              }
            } catch (_) {}
          }
        },
        builder: (BuildContext context, FetchSystemSettingsState state) {
          if (state is FetchSystemSettingsFailure) {
            return Center(
              child: ErrorContainer(
                errorMessage: state.errorMessage.translate(context: context),
                onTapRetry: () {
                  context
                      .read<FetchSystemSettingsCubit>()
                      .getSettings(isAnonymous: false);
                },
              ),
            );
          }
          return Stack(
            children: [
              CustomContainer(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.splashScreenGradientTopColor,
                      AppColors.splashScreenGradientBottomColor,
                    ],
                    stops: [0, 1],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: const Center(
                  child: CustomSvgPicture(
                    'splashLogo',
                  ),
                ),
              ),
              if (isDemoMode)
                const Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CustomSvgPicture(
                      'wrteam_logo',
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
