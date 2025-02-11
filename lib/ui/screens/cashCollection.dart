import 'package:edemand_partner/ui/widgets/interstitalAdWidget.dart';
import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CashCollectionScreen extends StatefulWidget {
  const CashCollectionScreen({super.key});

  @override
  CashCollectionScreenState createState() => CashCollectionScreenState();

  static Route<CashCollectionScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<CashCollectionCubit>(
            create: (BuildContext context) => CashCollectionCubit(),
          ),
          BlocProvider<AdminCollectCashCollectionHistoryCubit>(
            create: (BuildContext context) => AdminCollectCashCollectionHistoryCubit(),
          ),

        ],
        child: const CashCollectionScreen(),
      ),
    );
  }
}

class CashCollectionScreenState extends State<CashCollectionScreen> {
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListen);

  String selectedFilter = 'cashCollectedByAdmin';
  ValueNotifier<bool> isScrolling = ValueNotifier(false);
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();
    loadData();
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
      if (selectedFilter == 'cashCollectedByAdmin' &&
          context.read<AdminCollectCashCollectionHistoryCubit>().hasMoreData()) {
        context
            .read<AdminCollectCashCollectionHistoryCubit>()
            .fetchAdminCollectedMoreCashCollection();
      } else if (selectedFilter == 'cashReceived' &&
          context.read<CashCollectionCubit>().hasMoreData()) {
        context.read<CashCollectionCubit>().fetchMoreCashCollection();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InterstitialAdWidget(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: AppBar(
          elevation: 1,
          centerTitle: true,
          surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
          backgroundColor: Theme.of(context).colorScheme.secondaryColor,
          title: CustomText(
            'cashCollection'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          leading: const CustomBackArrow(),
          actions: [
            IconButton(
              onPressed: () {
                UiUtils.showModelBottomSheets(
                    context: context,
                    enableDrag: true,
                    isScrollControlled: false,
                    child: SelectableListBottomSheet(bottomSheetTitle: "filter", itemList: [
                      {
                        "title": "cashCollectedByAdmin",
                        "id": "0",
                        "isSelected": selectedFilter == "cashCollectedByAdmin"
                      },
                      {
                        "title": "cashReceived",
                        "id": "1",
                        "isSelected": selectedFilter == "cashReceived"
                      }
                    ])).then((value) {
                  selectedFilter = value['selectedItemName'];
                  setState(() {});

                  //if data already loaded then we will emit the success state
                  if (selectedFilter == 'cashCollectedByAdmin' &&
                      context.read<AdminCollectCashCollectionHistoryCubit>().state
                          is AdminCollectCashCollectionHistoryFetchSuccess) {
                    context.read<AdminCollectCashCollectionHistoryCubit>().emitSuccessState();
                    return;
                  } else if (selectedFilter == 'cashReceived' &&
                      context.read<CashCollectionCubit>().state is CashCollectionFetchSuccess) {
                    context.read<CashCollectionCubit>().emitSuccessState();
                    return;
                  }
                  loadData();
                });
              },
              icon:
                  Icon(Icons.filter_list_rounded, color: Theme.of(context).colorScheme.blackColor),
            ),
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
                            'cashCollectionDescription'.translate(context: context),
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
      ),
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

  Widget getTitleAndSubDetails({
    required String title,
    required String subDetails,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          title.translate(context: context),
          fontSize: 14,
          maxLines: 2,
          color: Theme.of(context).colorScheme.lightGreyColor,
        ),
        const CustomSizedBox(
          height: 5,
        ),
        CustomText(
          subDetails,
          fontSize: 14,
          maxLines: 2,
          color: Theme.of(context).colorScheme.blackColor,
        ),
      ],
    );
  }

  Widget showCashCollectionList({
    required List<CashCollectionModel> cashCollectionData,
    required String payableCommissionAmount,
    required bool isLoadingMore,
  }) {
    return Stack(
      children: [
        if (cashCollectionData.isEmpty) ...[
          Center(child: NoDataContainer(titleKey: 'noDataFound'.translate(context: context)))
        ],
        if (cashCollectionData.isNotEmpty) ...[
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
                  itemCount: cashCollectionData.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return CustomContainer(
                      width: MediaQuery.sizeOf(context).width,
                      padding: const EdgeInsetsDirectional.all(10),
                      color: Theme.of(context).colorScheme.secondaryColor,
                      borderRadius: UiUtils.borderRadiusOf10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (cashCollectionData[index].orderID != '') ...[
                                CustomText(
                                  'orderID'.translate(context: context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.lightGreyColor,
                                ),
                                const CustomSizedBox(width: 2),
                                CustomText(
                                  cashCollectionData[index].orderID!,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).colorScheme.blackColor,
                                ),
                              ],
                              const Spacer(),
                              CustomContainer(
                                height: 25,
                                width: MediaQuery.sizeOf(context).width * 0.3,
                                decoration: BoxDecoration(
                                  color: cashCollectionData[index].status == 'paid'
                                      ? AppColors.starRatingColor.withValues(alpha: 0.2)
                                      : AppColors.greenColor.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
                                ),
                                child: Center(
                                  child: CustomText(
                                    cashCollectionData[index].status!.translate(context: context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: cashCollectionData[index].status == 'paid'
                                        ? AppColors.starRatingColor
                                        : AppColors.greenColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const CustomSizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: getTitleAndSubDetails(
                                  title: 'amount',
                                  subDetails: (cashCollectionData[index].commissionAmount ?? "0")
                                      .replaceAll(',', '')
                                      .toString()
                                      .priceFormat(),
                                ),
                              ),
                              Expanded(
                                child: getTitleAndSubDetails(
                                  title: 'date',
                                  subDetails: (cashCollectionData[index].date ?? "").formatDate(),
                                ),
                              ),
                            ],
                          ),
                          const CustomSizedBox(height: 5),
                          getTitleAndSubDetails(
                            title: 'message',
                            subDetails: '${cashCollectionData[index].message}',
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => const CustomSizedBox(
                    height: 10,
                  ),
                ),
                if (isLoadingMore) ...[
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
          child: ValueListenableBuilder(
            valueListenable: isScrolling,
            builder: (BuildContext context, Object? value, Widget? child) => CustomContainer(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryColor,
                boxShadow: isScrolling.value
                    ? [
                        BoxShadow(
                          offset: const Offset(0, 0.75),
                          spreadRadius: 1,
                          blurRadius: 5,
                          color: Theme.of(context).colorScheme.blackColor.withValues(alpha: 0.2),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'amountPayable'.translate(context: context),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.whiteColors,
                      ),
                    ),
                    Text(
                      (payableCommissionAmount == 'null' ? '0.0' : payableCommissionAmount)
                          .replaceAll(',', '')
                          .toString()
                          .priceFormat(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.whiteColors,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void loadData() {
    if (selectedFilter == 'cashCollectedByAdmin') {
      context.read<AdminCollectCashCollectionHistoryCubit>().fetchAdminCollectedCashCollection();
    } else if (selectedFilter == 'cashReceived') {
      context.read<CashCollectionCubit>().fetchCashCollection();
    }
  }

  Widget showLoadingShimmerEffect() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: 8,
      physics: const AlwaysScrollableScrollPhysics(),
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
  }

  Widget mainWidget() {
    return CustomRefreshIndicator(
      onRefresh: () async {
        loadData();
      },
      child: (selectedFilter == 'cashCollectedByAdmin')
          ? BlocBuilder<AdminCollectCashCollectionHistoryCubit,
              AdminCollectCashCollectionHistoryState>(
              builder: (BuildContext context, AdminCollectCashCollectionHistoryState state) {
                if (state is AdminCollectCashCollectionHistoryStateFailure) {
                  return Center(
                    child: ErrorContainer(
                      onTapRetry: () {
                        context
                            .read<AdminCollectCashCollectionHistoryCubit>()
                            .fetchAdminCollectedCashCollection();
                      },
                      errorMessage: state.errorMessage,
                    ),
                  );
                }
                if (state is AdminCollectCashCollectionHistoryFetchSuccess) {
                  return showCashCollectionList(
                    cashCollectionData: state.cashCollectionData,
                    payableCommissionAmount: state.totalPayableCommission,
                    isLoadingMore: state.isLoadingMore,
                  );
                }
                return showLoadingShimmerEffect();
              },
            )
          : BlocBuilder<CashCollectionCubit, CashCollectionState>(
              builder: (BuildContext context, CashCollectionState state) {
                if (state is CashCollectionFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      onTapRetry: () {
                        context.read<CashCollectionCubit>().fetchCashCollection();
                      },
                      errorMessage: state.errorMessage,
                    ),
                  );
                }
                if (state is CashCollectionFetchSuccess) {
                  return showCashCollectionList(
                    payableCommissionAmount: state.totalPayableCommission,
                    cashCollectionData: state.cashCollectionData,
                    isLoadingMore: state.isLoadingMore,
                  );
                }
                return showLoadingShimmerEffect();
              },
            ),
    );
  }
}
