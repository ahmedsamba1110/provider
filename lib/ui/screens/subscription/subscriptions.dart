import 'package:edemand_partner/app/generalImports.dart';
import 'package:edemand_partner/cubits/fetchPreviousSubscriptionsCubit.dart';
import 'package:edemand_partner/ui/screens/subscription/widgets/customRadioOptionsWidget.dart';

import 'package:edemand_partner/ui/screens/subscription/widgets/subscriptionDetailsContainer.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SubscriptionsScreen extends StatefulWidget {
  //
  final String from;

  const SubscriptionsScreen({
    super.key,
    required this.from,
  });

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) {
        final Map<String, dynamic> arguments =
            routeSettings.arguments as Map<String, dynamic>;
        //
        return MultiBlocProvider(
          providers: [
            BlocProvider<FetchSubscriptionsCubit>(
              create: (context) => FetchSubscriptionsCubit(),
            ),
            BlocProvider<AddSubscriptionTransactionCubit>(
              create: (context) => AddSubscriptionTransactionCubit(),
            ),
          ],
          child: SubscriptionsScreen(
            from: arguments["from"],
          ),
        );
      },
    );
  }

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  //
  late List<Map<String, dynamic>> enabledPaymentMethods =
      context.read<FetchSystemSettingsCubit>().getEnabledPaymentMethods();
  String? selectedPaymentMethod;

  PaymentGatewaysSettings? paymentGatewaySetting;

  //----------------------------------- Razorpay Payment Gateway Start ----------------------------
  final Razorpay _razorpay = Razorpay();

  Future<void> initializeRazorpay() async {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorPayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorPayPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorPayExternalWallet);
  }

  void _handleRazorPayPaymentSuccess(final PaymentSuccessResponse response) {
    _razorpay.clear();
    _addSubscriptionTransaction(isSuccess: true);
  }

  void _handleRazorPayPaymentError(final PaymentFailureResponse response) {
    _razorpay.clear();

    _addSubscriptionTransaction(isSuccess: false);
  }

  void _handleRazorPayExternalWallet(final ExternalWalletResponse response) {
    _razorpay.clear();
  }

  Future<void> openRazorPayGateway({
    required final double subscriptionAmount,
    required final String razorpayOrderId,
    required final String subscriptionId,
    required final String transactionId,
  }) async {
    final options = <String, Object?>{
      'key':
          paymentGatewaySetting!.razorpayKey, //this should be come from server
      'amount': (subscriptionAmount * 100).toInt(),
      'name': appName,
      'description':
          'razorpaySubscriptionPlanDescription'.translate(context: context),
      'currency': paymentGatewaySetting!.razorpayCurrency,
      'notes': {'transaction_id': transactionId},
      'order_id': razorpayOrderId,
      'prefill': {
        'contact':
            context.read<ProviderDetailsCubit>().providerDetails.user?.phone ??
                "",
        'email':
            context.read<ProviderDetailsCubit>().providerDetails.user?.email ??
                ""
      }
    };

    _razorpay.open(options);
  }

  //----------------------------------- Razorpay Payment Gateway End ----------------------------

  //----------------------------------- Stripe Payment Gateway Start ----------------------------
  Future<void> openStripePaymentGateway({
    required final double subscriptionAmount,
    required final String transactionId,
  }) async {
    try {
      StripeService.secret = paymentGatewaySetting!.stripeSecretKey;
      StripeService.init(
        paymentGatewaySetting!.stripePublishableKey,
        paymentGatewaySetting!.stripeMode,
      );

      final response = await StripeService.payWithPaymentSheet(
        amount: (subscriptionAmount * 100).ceil(),
        currency: paymentGatewaySetting!.stripeCurrency,
        isTestEnvironment: paymentGatewaySetting!.stripeMode == "test",
        transactionID: transactionId,
        from: 'subscription',
      );

      if (response.status == 'succeeded') {
        _addSubscriptionTransaction(
          isSuccess: true,
        );
      } else {
        _addSubscriptionTransaction(isSuccess: false);
      }
    } catch (_) {}
  }

  //----------------------------------- Stripe Payment Gateway End ----------------------------

  @override
  void initState() {
    super.initState();
    fetchSubscriptionDetails();
    getPaymentGatewaySetting();
    if (enabledPaymentMethods.isNotEmpty) {
      selectedPaymentMethod = enabledPaymentMethods[0]['paymentType'];
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void fetchSubscriptionDetails() {
    Future.delayed(
      Duration.zero,
      () {
        context.read<FetchSubscriptionsCubit>().fetchSubscriptions();
        context
            .read<FetchPreviousSubscriptionsCubit>()
            .fetchPreviousSubscriptions();
      },
    );
  }

  void fetchProviderSubscriptionDetailsFromSettingsAPI() {
    Future.delayed(
      Duration.zero,
      () {
        context
            .read<FetchSystemSettingsCubit>()
            .getSettings(isAnonymous: false);
      },
    );
  }

  void getPaymentGatewaySetting() {
    paymentGatewaySetting =
        context.read<FetchSystemSettingsCubit>().getPaymentMethodSettings();
  }

  Future<dynamic> _showSubscriptionPaymentMessageDialog({
    required final isSuccess,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(UiUtils.borderRadiusOf10)),
          ),
          title: Text(
            (isSuccess ? "paymentSuccess" : "paymentFailed")
                .translate(context: context),
            style: TextStyle(
                color: isSuccess ? AppColors.greenColor : AppColors.redColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                isSuccess
                    ? "assets/animation/success.json"
                    : "assets/animation/fail.json",
                height: 150,
                width: 150,
              ),
              const CustomSizedBox(
                height: 25,
              ),
              Text(
                isSuccess
                    ? "subscriptionSuccess".translate(context: context)
                    : "subscriptionFailure".translate(context: context),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.blackColor,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const CustomSizedBox(
                height: 25,
              ),
              CustomRoundedButton(
                widthPercentage: 0.9,
                backgroundColor: Theme.of(context).colorScheme.accentColor,
                buttonTitle: isSuccess
                    ? "goToHome".translate(context: context)
                    : 'okay'.translate(context: context),
                showBorder: false,
                onTap: () {
                  if (isSuccess) {
                    if (widget.from == "drawer") {
                      Navigator.of(context)
                          .popUntil((Route route) => route.isFirst);
                    } else if (widget.from == "login" ||
                        widget.from == "splash") {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, Routes.main);
                    }
                    return;
                  }
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      },
    );
  }

  void _addSubscriptionTransaction({
    required final bool isSuccess,
  }) {
    final Map<String, dynamic> transactionData =
        context.read<AddSubscriptionTransactionCubit>().getTransactionDetails();
    //
    if (!isSuccess) {
      context
          .read<AddSubscriptionTransactionCubit>()
          .addSubscriptionTransaction(
            needToCreateRazorpayOrderID: false,
            paymentMethodType: transactionData["paymentMethodType"],
            status: "failed",
            subscriptionId: transactionData["subscriptionId"],
            message: "Payment Failed",
            transactionId: transactionData["transactionId"],
          );
    } else {
      context
          .read<AddSubscriptionTransactionCubit>()
          .addSubscriptionTransaction(
            needToCreateRazorpayOrderID: false,
            message: "Payment successful",
            status: "success",
            paymentMethodType: transactionData["paymentMethodType"],
            subscriptionId: transactionData["subscriptionId"],
            transactionId: transactionData["transactionId"],
          );
    }
    _showSubscriptionPaymentMessageDialog(isSuccess: isSuccess);
  }

  Widget setSubscriptionPlanDetailsPoint({
    required final String title,
  }) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.greenColor,
        ),
        const CustomSizedBox(
          width: 5,
        ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: Theme.of(context).colorScheme.blackColor),
          ),
        )
      ],
    );
  }

  void onBuyButtonPressed(
      {required final bool isLoading,
      required final String subscriptionId,
      required final String price}) {
    UiUtils.showAnimatedDialog(
        context: context,
        child: ConfirmationDialog(
            title: "areYouSure",
            description: "buySubscriptionDescription",
            confirmButtonBackgroundColor:
                Theme.of(context).colorScheme.accentColor,
            confirmButtonName: "buy",
            widgetUnderDescription: enabledPaymentMethods.length <= 1 ||
                    price == "0"
                ? null
                : StatefulBuilder(builder: (context, dialogState) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: enabledPaymentMethods.length,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> paymentMethod =
                            enabledPaymentMethods[index];

                        return CustomRadioOptionsWidget(
                          isFirst: index == 0,
                          isLast: index == enabledPaymentMethods.length - 1,
                          image: paymentMethod["image"]!,
                          title: paymentMethod["title"]!,
                          subTitle: paymentMethod["description"]!,
                          value: paymentMethod["paymentType"]!,
                          groupValue: selectedPaymentMethod!,
                          applyAccentColor: false,
                          onChanged: (final Object? selectedValue) {
                            selectedPaymentMethod = selectedValue.toString();

                            dialogState(() {});
                            setState(() {});
                          },
                        );
                      },
                    );
                  }),
            confirmButtonPressed: () {
              Navigator.pop(context, {"isConfirm": true});
            })).then((value) {
      if (value == null) {
        return;
      }

      if ((value as Map)["isConfirm"]) {
        if (price == "0") {
          context
              .read<AddSubscriptionTransactionCubit>()
              .addSubscriptionTransaction(
                needToCreateRazorpayOrderID: false,
                subscriptionId: subscriptionId,
                message: "subscription successful",
                status: "active",
                paymentMethodType: "free",
              );
          return;
        }
        if (enabledPaymentMethods.isNotEmpty && selectedPaymentMethod != null) {
          //
          context
              .read<AddSubscriptionTransactionCubit>()
              .addSubscriptionTransaction(
                needToCreateRazorpayOrderID:
                    selectedPaymentMethod == "razorpay",
                subscriptionId: subscriptionId,
                message: "subscription successful",
                status: "Pending",
                paymentMethodType: selectedPaymentMethod!,
              );
          //
        } else {
          UiUtils.showMessage(
            context,
           message:  "onlinePaymentNotAvailableNow".translate(context: context),
           type:  ToastificationType.warning,
          );
        }
      }
      return;
    });
  }

  Widget getCurrentlyActivePlanDetails({
    required SubscriptionInformation activeSubscriptionInformation,
  }) {
    //
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: getTitle(
              title: "currentSubscription".translate(context: context)),
        ),
        SubscriptionDetailsContainer(
          onBuyButtonPressed: () {
            onBuyButtonPressed(
              price: activeSubscriptionInformation.discountPrice != "0"
                  ? activeSubscriptionInformation.discountPriceWithTax ?? "0"
                  : activeSubscriptionInformation.priceWithTax ?? "0",
              subscriptionId: activeSubscriptionInformation.id ?? "0",
              isLoading: false,
            );
          },
          subscriptionDetails: activeSubscriptionInformation,
          isPreviousSubscription: false,
          isAvailableForPurchase: false,
          showLoading: false,
          isActiveSubscription: true,
          needToShowPaymentStatus: true,
        ),
      ],
    );
  }

  Widget getTitle({required String title}) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.blackColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    );
  }

  Widget subscriptionsDetailsContainer() {
    return CustomSizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            if (context
                        .watch<ProviderDetailsCubit>()
                        .providerDetails
                        .subscriptionInformation
                        ?.isSubscriptionActive ==
                    "active" ||
                context
                        .watch<ProviderDetailsCubit>()
                        .providerDetails
                        .subscriptionInformation
                        ?.isSubscriptionActive ==
                    "pending")
              BlocBuilder<ProviderDetailsCubit, ProviderDetailsState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: getCurrentlyActivePlanDetails(
                      activeSubscriptionInformation:
                          state.providerDetails.subscriptionInformation ??
                              SubscriptionInformation(),
                    ),
                  );
                },
              ),
            BlocBuilder<FetchPreviousSubscriptionsCubit,
                FetchPreviousSubscriptionsState>(
              builder: (context, state) {
                if (state is FetchPreviousSubscriptionsInProgress) {
                  return ShimmerLoadingContainer(
                      child: CustomShimmerContainer(
                    height: 300,
                    width: MediaQuery.sizeOf(context).width,
                  ));
                }
                if (state is FetchPreviousSubscriptionsSuccess) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Row(
                          children: [
                            getTitle(
                                title: "previousSubscriptions"
                                    .translate(context: context)),
                            const Spacer(),
                            CustomInkWellContainer(
                              child: CustomText(
                                "viewAll".translate(context: context),
                                color: context.colorScheme.accentColor,
                                underlineOrLineColor:
                                    context.colorScheme.accentColor,
                                showUnderline: true,
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, Routes.previousSubscriptions);
                              },
                            )
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                              state.subscriptionsData.length > 5
                                  ? 5
                                  : state.subscriptionsData.length, (index) {
                            //
                            final SubscriptionInformation subscriptionDetails =
                                state.subscriptionsData[index];
                            //
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: SubscriptionDetailsContainer(
                                onBuyButtonPressed: () {
                                  onBuyButtonPressed(
                                    price: subscriptionDetails.discountPrice !=
                                            "0"
                                        ? subscriptionDetails
                                                .discountPriceWithTax ??
                                            "0"
                                        : subscriptionDetails.priceWithTax ??
                                            "0",
                                    isLoading: false,
                                    subscriptionId:
                                        subscriptionDetails.id ?? "0",
                                  );
                                },
                                subscriptionDetails: subscriptionDetails,
                                isPreviousSubscription: true,
                                isAvailableForPurchase: false,
                                isActiveSubscription: false,
                                needToShowPaymentStatus: true,
                                showLoading: false,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                }
                return const CustomContainer();
              },
            ),
            BlocConsumer<AddSubscriptionTransactionCubit,
                AddSubscriptionTransactionState>(
              listener: (context, state) async {
                if (state is AddSubscriptionTransactionFailure) {
                  UiUtils.showMessage(
                    context,
                    message: state.errorMessage.translate(context: context),
                    type: ToastificationType.error,
                  );
                }
                if (state is AddSubscriptionTransactionSuccess) {
                  //
                  context.read<ProviderDetailsCubit>().updateProviderDetails(
                        subscriptionInformation: state.subscriptionInformation,
                      );
                  //
                  if (state.subscriptionStatus == "success" ||
                      state.subscriptionStatus == "failed") {
                    return;
                  }
                  if (state.paymentMethodType == "stripe") {
                    //
                    openStripePaymentGateway(
                      transactionId: state.transactionId.toString(),
                      subscriptionAmount:
                          double.parse(state.subscriptionAmount),
                    );
                    //
                  } else if (state.paymentMethodType == "razorpay") {
                    //
                    await initializeRazorpay();
                    //
                    final Map<String, dynamic> transactionDetails = context
                        .read<AddSubscriptionTransactionCubit>()
                        .getTransactionDetails(); //
                    openRazorPayGateway(
                      subscriptionAmount: double.parse(
                          transactionDetails["subscriptionAmount"]),
                      razorpayOrderId: state.razorpayOrderId,
                      subscriptionId: transactionDetails["subscriptionId"],
                      transactionId: transactionDetails["transactionId"],
                    );
                    //
                  } else if (state.paymentMethodType == "paystack") {
                    //
                    _openWebviewPaymentGateway(
                        webviewLink: state.paystackPaymentURL);
                    //
                  } else if (state.paymentMethodType == "paypal") {
                    //
                    _openWebviewPaymentGateway(
                        webviewLink: state.paypalPaymentURL);
                    //
                  } else if (state.paymentMethodType == "flutterwave") {
                    //
                    _openWebviewPaymentGateway(
                        webviewLink: state.flutterwavePaymentURL);
                    //
                  } else if (state.paymentMethodType == "free") {
                    _showSubscriptionPaymentMessageDialog(isSuccess: true);
                  } else {
                    UiUtils.showMessage(
                      context,
                     message:  "onlinePaymentMethodNotAvailable"
                          .translate(context: context),
                     type:  ToastificationType.error,
                    );
                  }
                }
              },
              builder: (context, state) {
                bool showLoading = false;
                String onGoingPaymentSubscriptionId = "-1";
                //
                if (state is AddSubscriptionTransactionInProgress) {
                  showLoading = true;
                  onGoingPaymentSubscriptionId = state.subscriptionId;
                } else if (state is AddSubscriptionTransactionSuccess ||
                    state is AddSubscriptionTransactionFailure) {
                  showLoading = false;
                }
                return context
                            .watch<ProviderDetailsCubit>()
                            .providerDetails
                            .subscriptionInformation
                            ?.isSubscriptionActive ==
                        "deactive"
                    ? BlocBuilder<FetchSubscriptionsCubit,
                        FetchSubscriptionsState>(
                        builder: (context, state) {
                          if (state is FetchSubscriptionsFailure) {
                            return Center(
                              child: ErrorContainer(
                                errorMessage: state.errorMessage
                                    .translate(context: context),
                                onTapRetry: () {
                                  context
                                      .read<FetchSubscriptionsCubit>()
                                      .fetchSubscriptions();
                                },
                              ),
                            );
                          } else if (state is FetchSubscriptionsSuccess) {
                            //
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: getTitle(
                                      title: "subscriptionPlans"
                                          .translate(context: context),
                                    ),
                                  ),
                                  Column(
                                    children: List.generate(
                                        state.subscriptionsData.length +
                                            (state.isLoadingMoreSubscriptions
                                                ? 1
                                                : 0), (index) {
                                      if (index >=
                                          state.subscriptionsData.length) {
                                        return const CustomCircularProgressIndicator();
                                      }
                                      //
                                      final SubscriptionInformation
                                          subscriptionDetails =
                                          state.subscriptionsData[index];
                                      //
                                      return SubscriptionDetailsContainer(
                                        onBuyButtonPressed: () {
                                          onBuyButtonPressed(
                                            price: subscriptionDetails
                                                        .discountPrice !=
                                                    "0"
                                                ? subscriptionDetails
                                                        .discountPriceWithTax ??
                                                    "0"
                                                : subscriptionDetails
                                                        .priceWithTax ??
                                                    "0",
                                            isLoading:
                                                onGoingPaymentSubscriptionId ==
                                                        subscriptionDetails.id
                                                    ? showLoading
                                                    : false,
                                            subscriptionId:
                                                subscriptionDetails.id ?? "0",
                                          );
                                        },
                                        isPreviousSubscription: false,
                                        subscriptionDetails:
                                            subscriptionDetails,
                                        isAvailableForPurchase: context
                                                .read<ProviderDetailsCubit>()
                                                .providerDetails
                                                .subscriptionInformation
                                                ?.isSubscriptionActive ==
                                            "deactive",
                                        isActiveSubscription: false,
                                        needToShowPaymentStatus: false,
                                        showLoading:
                                            onGoingPaymentSubscriptionId ==
                                                    subscriptionDetails.id
                                                ? showLoading
                                                : false,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Center(
                            child: SingleChildScrollView(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: List.generate(
                                  7,
                                  (index) => ShimmerLoadingContainer(
                                    child: CustomShimmerContainer(
                                      height: 150,
                                      width: MediaQuery.sizeOf(context).width,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      borderRadius: UiUtils.borderRadiusOf10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : const CustomContainer();
              },
            ),
          ],
        ),
      ),
    );
  }

//
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: PopScope(
        canPop: widget.from != "login" || widget.from != "splash",
        /*  onWillPop: () {
          if  (widget.from == "login" || widget.from == "splash"){
            return Future.value(false);
          }
          return Future.value(true);
        },*/
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primaryColor,
            appBar: AppBar(
              elevation: 1,
              centerTitle: true,
              leading: widget.from == "login" || widget.from == "splash"
                  ? null
                  : const CustomBackArrow(),
              backgroundColor: Theme.of(context).colorScheme.secondaryColor,
              surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
              title: CustomText(
                'subscriptions'.translate(context: context),
                color: Theme.of(context).colorScheme.blackColor,
                fontWeight: FontWeight.bold,
              ),
              actions: [
                if (widget.from == "login" || widget.from == "splash") ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10),
                    child: context
                                .watch<ProviderDetailsCubit>()
                                .providerDetails
                                .subscriptionInformation
                                ?.isSubscriptionActive ==
                            "active"
                        ? CustomInkWellContainer(
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(Routes.main);
                            },
                            child: Icon(
                              Icons.home_outlined,
                              color: Theme.of(context).colorScheme.blackColor,
                              size: 30,
                            ),
                          )
                        : CustomInkWellContainer(
                            onTap: () {
                              UiUtils.showAnimatedDialog(
                                  context: context,
                                  child: const LogoutAccountDialog());
                            },
                            child: Icon(
                              Icons.logout,
                              color: Theme.of(context).colorScheme.blackColor,
                              size: 30,
                            ),
                          ),
                  )
                ]
              ],
            ),
            body: BlocListener<FetchSystemSettingsCubit,
                FetchSystemSettingsState>(
              listener: (context, state) {
                if (state is FetchSystemSettingsSuccess) {
                  context.read<ProviderDetailsCubit>().updateProviderDetails(
                      subscriptionInformation: state.subscriptionInformation);
                }
              },
              child: CustomRefreshIndicator(
                onRefresh: () async {
                  fetchSubscriptionDetails();
                  fetchProviderSubscriptionDetailsFromSettingsAPI();
                },
                child: subscriptionsDetailsContainer(),
              ),
            )),
      ),
    );
  }

  void _openWebviewPaymentGateway({required String webviewLink}) {
    Navigator.pushNamed(
      context,
      Routes.paypalPaymentScreen,
      arguments: {'paymentURL': webviewLink},
    ).then((final Object? value) {
      final parameter = value as Map;
      if (parameter['paymentStatus'] == 'Completed') {
        //
        _addSubscriptionTransaction(isSuccess: true);
        //
      } else if (parameter['paymentStatus'] == 'Failed') {
        _addSubscriptionTransaction(isSuccess: false);
      }
    });
  }
}
