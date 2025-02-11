import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Route route(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (BuildContext context) => const LoginScreen(),
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final bool isDemoModeEnabled =
        context.read<FetchSystemSettingsCubit>().isDemoModeEnable();
    if (isDemoModeEnabled) {
      _phoneNumberController.text = "1234567890";
      _passwordController.text = "12345678";
    }
    context.read<FetchSystemSettingsCubit>().getSettings(isAnonymous: true);
  }

  Future<void> _onLoginButtonClick() async {
    FocusScope.of(context).unfocus();
    if (_loginFormKey.currentState!.validate()) {
      final String countryCallingCode =
          context.read<CountryCodeCubit>().getSelectedCountryCode();
      //
      String? fcmId;
      try {
        fcmId = await FirebaseMessaging.instance.getToken() ?? "";
      } catch (_) {}
      //
      context.read<SignInCubit>().signIn(
            phoneNumber: _phoneNumberController.text,
            password: _passwordController.text,
            countryCode: countryCallingCode,
            fcmId: fcmId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        body: BlocConsumer<SignInCubit, SignInState>(
          listener: (BuildContext context, SignInState state) async {
            if (state is SignInSuccess) {
              //
              if (state.error) {
                UiUtils.showMessage(context,
                    message: state.message.translate(context: context),
                    type: ToastificationType.error);
                return;
              }

              context
                  .read<ProviderDetailsCubit>()
                  .setUserInfo(state.providerDetails);
              //
              HiveRepository.setUserLoggedIn = true;
              //
              if (state.providerDetails.providerInformation?.isApproved ==
                  '1') {
                Future.delayed(
                  Duration.zero,
                  () {
                    Navigator.pushReplacementNamed(context, Routes.main);
                  },
                );
              } else {
                Future.delayed(
                  Duration.zero,
                  () {
                    Navigator.pushReplacementNamed(
                      context,
                      Routes.registration,
                      arguments: {'isEditing': false},
                    );
                  },
                );
              }
            }
            if (state is SignInFailure) {
              Future.delayed(
                Duration.zero,
                () {
                  UiUtils.showMessage(context,
                      message: state.errorMessage.translate(context: context),
                      type: ToastificationType.error);
                },
              );
            }
          },
          builder: (BuildContext context, SignInState state) {
            return Form(
              key: _loginFormKey,
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                child: CustomContainer(
                  height: MediaQuery.sizeOf(context).height,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomSizedBox(
                        height: 40,
                      ),
                      const CustomSvgPicture(
                        'loginlogo',
                        width: 100,
                        height: 108,
                        boxFit: BoxFit.cover,
                      ),
                      const CustomSizedBox(
                        height: 40,
                      ),
                      Text(
                        'welcome-bareqq provider'.translate(context: context),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.blackColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const CustomSizedBox(
                        height: 40,
                      ),
                      CustomTextFormField(
                        bottomPadding: 0,

                        controller: _phoneNumberController,
                        textInputType: TextInputType.phone,
                        inputFormatters: UiUtils.allowOnlyDigits(),
                        isDense: false,
                        validator: (String? value) {
                          return Validator.validateNumber(context, value!);
                        },
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.blackColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                        // borderColor: Theme.of(context).colorScheme.accentColor,
                        isRoundedBorder: true,
                        backgroundColor: Colors.transparent,
                        hintText:
                            'enterMobileNumber'.translate(context: context),
                        hintTextColor:
                            Theme.of(context).colorScheme.lightGreyColor,
                        prefix: Padding(
                          padding: const EdgeInsetsDirectional.only(
                              start: 12.0, bottom: 2),
                          child:
                              BlocBuilder<CountryCodeCubit, CountryCodeState>(
                            builder:
                                (BuildContext context, CountryCodeState state) {
                              String code = '--';

                              if (state is CountryCodeFetchSuccess) {
                                code = state.selectedCountry!.callingCode;
                              }

                              return CustomSizedBox(
                                height: 27,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomInkWellContainer(
                                      onTap: () {
                                        if (allowOnlySingleCountry) {
                                          return;
                                        }
                                        Navigator.pushNamed(context,
                                                Routes.countryCodePickerRoute)
                                            .then((Object? value) {
                                          Future.delayed(const Duration(
                                                  milliseconds: 250))
                                              .then((value) {
                                            context
                                                .read<CountryCodeCubit>()
                                                .fillTemporaryList();
                                          });
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Builder(
                                            builder: (BuildContext context) {
                                              if (state
                                                  is CountryCodeFetchSuccess) {
                                                return CustomSizedBox(
                                                  width: 35,
                                                  height: 27,
                                                  child: Image.asset(
                                                    state.selectedCountry!.flag,
                                                    fit: BoxFit.cover,
                                                  ),
                                                );
                                              }
                                              if (state
                                                  is CountryCodeFetchFail) {
                                                return ErrorContainer(
                                                    errorMessage: state.error
                                                        .toString()
                                                        .translate(
                                                            context: context));
                                              }
                                              return const CustomCircularProgressIndicator();
                                            },
                                          ),
                                          const CustomSizedBox(
                                            width: 10,
                                          ),
                                          if (!allowOnlySingleCountry)
                                            CustomSvgPicture(
                                              'sp_down',
                                              height: 5,
                                              width: 5,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .accentColor,
                                            ),
                                        ],
                                      ),
                                    ),
                                    VerticalDivider(
                                      thickness: 1,
                                      indent: 6,
                                      endIndent: 6,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightGreyColor,
                                    ),
                                    Text(
                                      code,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .blackColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const CustomSizedBox(
                                      width: 5,
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const CustomSizedBox(
                        height: 15,
                      ),
                      CustomTextFormField(
                        bottomPadding: 0,
                        controller: _passwordController,
                        isDense: false,
                        isRoundedBorder: true,
                        isPswd: true,
                        validator: (String? value) =>
                            Validator.nullCheck(context, value),
                        backgroundColor: Colors.transparent,
                        hintText:
                            'enterYourPassword'.translate(context: context),
                        hintTextColor:
                            Theme.of(context).colorScheme.lightGreyColor,
                      ),
                      const CustomSizedBox(
                        height: 8,
                      ),
                      buildForgotPasswordLabel(),
                      const CustomSizedBox(
                        height: 20,
                      ),
                      buildLoginButton(context,
                          showProgress: state is SignInInProgress),
                      const CustomSizedBox(
                        height: 25,
                      ),
                      buildNewRegistrationContainer(),
                      const CustomSizedBox(
                        height: 40,
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'byContinueYouAccept'
                                    .translate(context: context),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .blackColor
                                      .withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(top: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomInkWellContainer(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          Routes.appSettings,
                                          arguments: {
                                            'title': 'termsConditionLbl'
                                          },
                                        );
                                      },
                                      child: Text(
                                        'termsConditionLbl'
                                            .translate(context: context),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .blackColor,
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ' & ',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .blackColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    CustomInkWellContainer(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          Routes.appSettings,
                                          arguments: {
                                            'title': 'privacyPolicyLbl'
                                          },
                                        );
                                      },
                                      child: Text(
                                        'privacyPolicyLbl'
                                            .translate(context: context),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .blackColor,
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      // buildRegisterButton()
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildForgotPasswordLabel() {
    return CustomContainer(
      alignment: AlignmentDirectional.centerEnd,
      child: CustomInkWellContainer(
        child: Text(
          'forgotPassword'.translate(context: context),
          style: TextStyle(
            color: Theme.of(context).colorScheme.accentColor,
            fontSize: 14,
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.sendOTPScreen,
            arguments: {
              'screenTitle': 'forgotPassword',
              'screenSubTitle':
                  'weWillTextYouVerificationCodeToResetYourPassword'
            },
          );
        },
      ),
    );
  }

  Widget buildLoginButton(BuildContext context, {bool? showProgress}) {
    return CustomRoundedButton(
      onTap: _onLoginButtonClick,
      buttonTitle: 'login'.translate(context: context),
      widthPercentage: 1,
      backgroundColor: Theme.of(context).colorScheme.accentColor,
      showBorder: false,
      child: (showProgress ?? false)
          ? CustomCircularProgressIndicator(
              color: AppColors.whiteColors,
            )
          : null,
    );
  }

  Row buildNewRegistrationContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${"notMember".translate(context: context)} ",
          style: TextStyle(
            color: Theme.of(context).colorScheme.accentColor,
            fontWeight: FontWeight.w400,
            fontFamily: 'PlusJakartaSans',
            fontStyle: FontStyle.normal,
            fontSize: 16.0,
          ),
        ),
        CustomInkWellContainer(
          child: Text(
            'registerNow'.translate(context: context),
            style: TextStyle(
              color: Theme.of(context).colorScheme.accentColor,
              fontWeight: FontWeight.w700,
              fontFamily: 'PlusJakartaSans',
              fontStyle: FontStyle.normal,
              fontSize: 16.0,
            ),
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.sendOTPScreen,
              arguments: {
                'screenTitle': 'enterYouMobile',
                'screenSubTitle': 'weWillSendYouCode'
              },
            );
          },
        ),
      ],
    );
  }
}
