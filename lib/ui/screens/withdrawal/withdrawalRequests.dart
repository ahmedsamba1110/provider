import 'package:edemand_partner/ui/widgets/bottomSheets/layouts/sendWithdrawalRequestBottomSheet.dart';
import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class WithdrawalRequestsScreen extends StatefulWidget {
  const WithdrawalRequestsScreen({super.key});

  @override
  WithdrawalRequestsScreenState createState() => WithdrawalRequestsScreenState();

  static Route<WithdrawalRequestsScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) => FetchWithdrawalRequestCubit(),
          ),
          BlocProvider(
            create: (BuildContext context) => SendWithdrawalRequestCubit(),
          ),
        ],
        child: const WithdrawalRequestsScreen(),
      ),
    );
  }
}

class WithdrawalRequestsScreenState extends State<WithdrawalRequestsScreen> {
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListen);

  ValueNotifier<bool> isScrolling = ValueNotifier(false);
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    context.read<FetchWithdrawalRequestCubit>().fetchWithdrawals();
    super.initState();
  }

  @override
  void dispose() {
    isScrolling.dispose();
    overlayEntry?.remove();
    overlayEntry?.dispose();
    super.dispose();
  }

  void _pageScrollListen() {
    if (_pageScrollController.position.pixels > 7 && !isScrolling.value) {
      isScrolling.value = true;
    } else if (_pageScrollController.position.pixels < 7 && isScrolling.value) {
      isScrolling.value = false;
    }
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchWithdrawalRequestCubit>().hasMoreData()) {
        context.read<FetchWithdrawalRequestCubit>().fetchMoreWithdrawals();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
        title: CustomText(
          'withdrawalRequest'.translate(context: context),
          color: Theme.of(context).colorScheme.blackColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        leading: const CustomBackArrow(),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: IconButton(
              onPressed: () {
                if (overlayEntry?.mounted ?? false) {
                  return;
                }
                overlayEntry = OverlayEntry(
                  builder: (BuildContext context) => Positioned.directional(
                    textDirection: Directionality.of(context),
                    end: 10,
                    top: MediaQuery.sizeOf(context).height * .10,
                    child: CustomContainer(
                      width: MediaQuery.sizeOf(context).width * .9,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryColor,
                        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 0.5,
                            spreadRadius: 0.5,
                            color: Colors.black54,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          'withdrawalRequestDescription'.translate(context: context),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.blackColor,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                );

                Overlay.of(context).insert(overlayEntry!);
                Timer(const Duration(seconds: 5), () => overlayEntry!.remove());
              },
              icon: Icon(
                Icons.help_outline_outlined,
                color: Theme.of(context).colorScheme.blackColor,
              ),
            ),
          )
        ],
      ),
      body: mainWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget setTitleAndSubDetails({required String title, required String subTitle}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CustomText(
            title.translate(context: context),
            fontSize: 14,
            maxLines: 1,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.blackColor,
          ),
        ),
        const Expanded(child: CustomSizedBox(width: 5)),
        Expanded(
          flex: 6,
          child: CustomText(
            subTitle,
            fontSize: 11,
            maxLines: 3,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.blackColor,
          ),
        ),
      ],
    );
  }

  Widget mainWidget() {
    return CustomRefreshIndicator(
      onRefresh: () async {
        context.read<FetchWithdrawalRequestCubit>().fetchWithdrawals();
      },
      child: BlocBuilder<FetchWithdrawalRequestCubit, FetchWithdrawalRequestState>(
        builder: (BuildContext context, FetchWithdrawalRequestState state) {
          if (state is FetchWithdrawalRequestFailure) {
            return Center(
              child: ErrorContainer(
                onTapRetry: () {
                  context.read<FetchWithdrawalRequestCubit>().fetchWithdrawals();
                },
                errorMessage: state.errorMessage.translate(context: context),
              ),
            );
          }
          if (state is FetchWithdrawalRequestSuccess) {
            return Stack(
              children: [
                if (state.withdrawals.isEmpty) ...[
                  Center(
                    child: NoDataContainer(titleKey: 'noDataFound'.translate(context: context)),
                  )
                ],
                if (state.withdrawals.isNotEmpty) ...[
                  SingleChildScrollView(
                    controller: _pageScrollController,
                    clipBehavior: Clip.none,
                    child: Column(
                      children: [
                        const CustomSizedBox(
                          height: 110,
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          itemCount: state.withdrawals.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            final WithdrawalModel withdrawal = state.withdrawals[index];
                            return CustomContainer(
                              padding: const EdgeInsetsDirectional.all(15),
                              color: Theme.of(context).colorScheme.secondaryColor,
                              borderRadius: UiUtils.borderRadiusOf10,
                              child: Column(
                                children: [
                                  setTitleAndSubDetails(
                                    title: 'bankDetailsLbl',
                                    subTitle: withdrawal.paymentAddress ?? '',
                                  ),
                                  const CustomSizedBox(
                                    height: 10,
                                  ),
                                  setTitleAndSubDetails(
                                    title: 'amountLbl',
                                    subTitle: (withdrawal.amount ?? "0")
                                        .replaceAll(',', '')
                                        .toString()
                                        .priceFormat(),
                                  ),
                                  const CustomSizedBox(
                                    height: 10,
                                  ),
                                  setTitleAndSubDetails(
                                    title: 'statusLbl',
                                    subTitle: withdrawal.status ?? '',
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const CustomSizedBox(
                            height: 10,
                          ),
                        ),
                        if (state.isLoadingMore) ...[
                          CustomCircularProgressIndicator(
                            color: Theme.of(context).colorScheme.accentColor,
                          )
                        ]
                      ],
                    ),
                  ),
                ],
                Align(
                  alignment: Alignment.topCenter,
                  child: CustomInkWellContainer(
                    onTap: () {
                      UiUtils.showModelBottomSheets(
                        context: context,
                        enableDrag: true,
                        isScrollControlled: true,
                        child: BlocProvider(
                          create: (BuildContext context) => SendWithdrawalRequestCubit(),
                          child: const SendWithdrawalRequestBottomsheet(),
                        ),
                      );
                      return;
                    },
                    child: ValueListenableBuilder(
                      valueListenable: isScrolling,
                      builder: (BuildContext context, Object? value, Widget? child) =>
                          CustomContainer(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryColor,
                          boxShadow: isScrolling.value
                              ? [
                                  BoxShadow(
                                    offset: const Offset(0, 0.75),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    color:
                                        Theme.of(context).colorScheme.blackColor.withValues(alpha: 0.2),
                                  )
                                ]
                              : [],
                        ),
                        child: CustomContainer(
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          height: 95,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.accentColor,
                            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'yourBalanceLbl'.translate(context: context),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.whiteColors,
                                    ),
                                  ),
                                  Text(
                                    state.availableBalance.replaceAll(',', '').priceFormat(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.whiteColors,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              CustomContainer(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondaryColor,
                                  borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
                                ),
                                height: 50,
                                width: 50,
                                child: Icon(
                                  Icons.add_outlined,
                                  color: Theme.of(context).colorScheme.blackColor,
                                  size: 40,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            itemCount: 8,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: MediaQuery.sizeOf(context).height * 0.18,
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
