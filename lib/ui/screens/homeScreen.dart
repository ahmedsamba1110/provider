import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {super.key, required this.scrollController, this.navigateToTab});

  final ScrollController scrollController;
  final void Function(int)? navigateToTab;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  int gridItems = 4;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    //
    context.read<FetchStatisticsCubit>().getStatistics();
    context.read<FetchSystemSettingsCubit>().getSettings(isAnonymous: false);
    // context.read<FetchJobRequestCubit>().FetchJobRequest(jobType: "open_jobs");

    super.initState();
  }

  String? _getStatesValue(StatisticsModel states, int index) {
    switch (index) {
      case 0:
        return states.totalOrders;
      case 1:
        return states.totalCancles;
      case 2:
        return states.totalServices;
      case 3:
        return states.totalBalance;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    FirebaseMessaging.instance.getToken().then((String? value) {});
    FirebaseMessaging.instance.getToken();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        body: dashboard(),
      ),
    );
  }

  Widget dashboard() {
    final List<Map> cardDetails = [
      {
        'id': '0',
        'imgName':
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? 'ttl_booking'
                : 'ttl_booking_white',
        'title': 'totalBookingLbl'.translate(context: context),
        'showCurrencyIcon': false,
      },
      {
        'id': '1',
        'imgName':
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? 'ttl_cancel'
                : 'ttl_cancel_white',
        'title': 'totalCancelLbl'.translate(context: context),
        'showCurrencyIcon': false,
      },
      {
        'id': '2',
        'imgName': 'ttl_services',
        'title': 'totalServicesLbl'.translate(context: context),
        'imgColor': Theme.of(context).colorScheme.accentColor,
        'showCurrencyIcon': false,
      },
      {
        'id': '3',
        'imgName':
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? 'ttl_earning'
                : 'ttl_earning_white',
        'title': 'totalEarningLbl'.translate(context: context),
        'showCurrencyIcon': true,
        'imgColor': Theme.of(context).colorScheme.accentColor,
      }
    ];
    return CustomRefreshIndicator(
      onRefresh: () async {
        //
        context.read<FetchStatisticsCubit>().getStatistics();
        context
            .read<FetchSystemSettingsCubit>()
            .getSettings(isAnonymous: false);
      },
      child: BlocBuilder<FetchStatisticsCubit, FetchStatisticsState>(
        builder: (BuildContext context, FetchStatisticsState state) {
          if (state is FetchStatisticsInProgress) {
            return SingleChildScrollView(
              controller: widget.scrollController,
              clipBehavior: Clip.none,
              child: Column(
                children: [
                  GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    itemCount: gridItems,
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10, //horizontal spacing between 2 cards
                      childAspectRatio: MediaQuery.sizeOf(context).width /
                          (MediaQuery.sizeOf(context).height / 2.2),
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return const ShimmerLoadingContainer(
                          child: CustomShimmerContainer());
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: ShimmerLoadingContainer(
                      child: CustomShimmerContainer(
                        height: 250,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is FetchStatisticsFailure) {
            return Center(
              child: ErrorContainer(
                onTapRetry: () {
                  context.read<FetchStatisticsCubit>().getStatistics();
                  context
                      .read<FetchSystemSettingsCubit>()
                      .getSettings(isAnonymous: false);
                },
                errorMessage: state.errorMessage.translate(context: context),
              ),
            );
          }

          if (state is FetchStatisticsSuccess) {
            return SingleChildScrollView(
                clipBehavior: Clip.none,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(children: [
                  GridView.builder(
                    itemCount: gridItems,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5, //horizontal spacing between 2 cards
                      childAspectRatio: 1.1,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        color: Theme.of(context).colorScheme.secondaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                UiUtils.borderRadiusOf10)),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomSizedBox(
                                height: 35,
                                width: 38,
                                child: CustomSvgPicture(
                                  cardDetails[index]['imgName'],
                                  color: cardDetails[index]['imgColor'],
                                ),
                              ),
                              CustomText(
                                cardDetails[index]['title'],
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.blackColor,
                              ),
                              CustomTweenAnimation(
                                curve: Curves.fastLinearToSlowEaseIn,
                                beginValue: 0,
                                endValue: double.parse(
                                    _getStatesValue(state.statistics, index) ??
                                        ""),
                                durationInSeconds: 1,
                                builder: (BuildContext context, double value,
                                        Widget? child) =>
                                    CustomText(
                                  "${cardDetails[index]['showCurrencyIcon'] ? UiUtils.systemCurrency : ""}${value.toStringAsFixed(0)}",
                                  fontWeight: FontWeight.w700,
                                  color:
                                      Theme.of(context).colorScheme.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const CustomSizedBox(
                    height: 10,
                  ),
                  if (state.statistics.openJobs?.isNotEmpty ?? false) ...[
                    CustomContainer(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(UiUtils.borderRadiusOf10),
                        color: Theme.of(context).colorScheme.secondaryColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomContainer(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          UiUtils.borderRadiusOf10),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryColor),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          UiUtils.borderRadiusOf10),
                                      child: const CustomSvgPicture(
                                        'bag_image',

                                        // boxFit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const CustomSizedBox(width: 10),
                                Expanded(
                                    child: CustomSizedBox(
                                        // height: 40,
                                        child: Column(
                                  children: [
                                    CustomText(
                                      "jobRequestsForYouLbl"
                                          .translate(context: context),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .blackColor,
                                      maxLines: 1,
                                    ),
                                    Row(
                                      children: [
                                        CustomText(
                                          "${state.statistics.totalOpenJobs}+",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .blackColor,
                                        ),
                                        const CustomSizedBox(
                                          width: 3,
                                        ),
                                        CustomText(
                                          "requestLbl"
                                              .translate(context: context),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .blackColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ))),
                                const CustomSizedBox(width: 10),
                                InkWell(
                                  child: CustomText(
                                    "viewAll".translate(context: context),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .blackColor,
                                    maxLines: 1,
                                    showUnderline: true,
                                  ),
                                  onTap: () {
                                    widget.navigateToTab!(2);
                                    // Navigator.pushNamed(
                                    //     context, Routes.jobRequestScreen,
                                    //     arguments: widget.scrollController);
                                  },
                                ),
                              ],
                            ),
                            const Divider(),
                            Column(
                              children: [
                                ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: state.statistics.openJobs!.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final JobRequestModel jobRequestModel =
                                        state.statistics.openJobs![index];

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          Routes.openJobRequestDetails,
                                          arguments: {
                                            'jobRequestModel': jobRequestModel
                                          },
                                        );
                                      },
                                      child: CustomContainer(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                end: 10, start: 10, top: 5),
                                        borderRadius: UiUtils.borderRadiusOf10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryColor,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: CustomSizedBox(
                                                // height: 100,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        jobRequestModel
                                                                .serviceTitle ??
                                                            "",
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .blackColor,
                                                        maxLines: 2,
                                                      ),
                                                      const CustomSizedBox(
                                                          height: 5),
                                                      CustomText(
                                                        jobRequestModel
                                                                .serviceShortDescription ??
                                                            "",
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .lightGreyColor,
                                                        maxLines: 2,
                                                      ),
                                                      const CustomSizedBox(
                                                          height: 5),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              CustomContainer(
                                                                height: 18,
                                                                width: 18,
                                                                decoration: const BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          UiUtils
                                                                              .borderRadiusOf50),
                                                                  child:
                                                                      CustomCachedNetworkImage(
                                                                    imageUrl:
                                                                        jobRequestModel.image ??
                                                                            "",
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              CustomText(
                                                                jobRequestModel
                                                                        .username ??
                                                                    "",
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .blackColor,
                                                                maxLines: 1,
                                                              ),
                                                            ],
                                                          ),
                                                          InkWell(
                                                            child: CustomText(
                                                              "view".translate(
                                                                  context:
                                                                      context),
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .blackColor,
                                                              maxLines: 1,
                                                              showUnderline:
                                                                  true,
                                                            ),
                                                            onTap: () {
                                                              Navigator
                                                                  .pushNamed(
                                                                context,
                                                                Routes
                                                                    .openJobRequestDetails,
                                                                arguments: {
                                                                  'jobRequestModel':
                                                                      jobRequestModel
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      )
                                                    ]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    if (index == 0) {
                                      return const Divider();
                                    } else {
                                      return const CustomSizedBox(height: 10);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                  const CustomSizedBox(
                    height: 10,
                  ),
                  if (state.statistics.monthlyEarnings?.monthlySales
                          ?.isNotEmpty ??
                      false) ...[
                    CustomSizedBox(
                      height: 350,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: MonthlyEarningBarChart(
                          monthlySales:
                              state.statistics.monthlyEarnings!.monthlySales!,
                        ),
                      ),
                    ),
                  ],
                  if (state.statistics.caregories?.isNotEmpty ?? false) ...[
                    CustomSizedBox(
                      height: 260,
                      child: CategoryPieChart(
                          categoryProductCounts: state.statistics.caregories!),
                    )
                  ]
                ]));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
