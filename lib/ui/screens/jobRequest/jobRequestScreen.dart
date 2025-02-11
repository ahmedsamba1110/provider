import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/material.dart';

class JobRequestScreen extends StatefulWidget {
  const JobRequestScreen({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<JobRequestScreen> createState() => _JobRequestScreenState();
}

class _JobRequestScreenState extends State<JobRequestScreen> with AutomaticKeepAliveClientMixin {
  int currFilter = 0;
  List<Map> filters = [];
  String? selectedStatus = "open_jobs";
  String? isJobRequestEnable;

  @override
  void initState() {
    getIsAcceptingCustomJobs();

    super.initState();
  }

  void getIsAcceptingCustomJobs() {
    isJobRequestEnable = context.read<FetchSystemSettingsCubit>().getIsAcceptingCustomJobs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    filters = [
      {'id': '0', 'fName': 'open_jobs'.translate(context: context)},
      {'id': '1', 'fName': 'applied_jobs'.translate(context: context)},
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    filters = [
      {'id': '0', 'fName': 'open_jobs'.translate(context: context)},
      {'id': '1', 'fName': 'applied_jobs'.translate(context: context)},
    ];
    return DefaultTabController(
      length: filters.length,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
            appBar: AppBar(
                title: Text(
                  'jobRequestTitleLbl'.translate(context: context),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.blackColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.categories);
                    },
                    child: CustomContainer(
                      height: 36,
                      width: 40,
                      borderRadius: 5,
                      color: Theme.of(context).colorScheme.accentColor.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.format_list_bulleted,
                        color: Theme.of(context).colorScheme.accentColor,
                      ),
                    ),
                  ),
                  const CustomSizedBox(
                    width: 5,
                  ),
                  CustomSwitch(
                    trackColor: isJobRequestEnable == "1"
                        ? Theme.of(context).colorScheme.accentColor
                        : Theme.of(context).colorScheme.blackColor.withValues(alpha: 0.5),
                    thumbColor: Theme.of(context).colorScheme.secondaryColor,
                    onChanged: (value) {
                      // Show bottom sheet every time toggle is changed
                      UiUtils.showModelBottomSheets(
                          context: context,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CustomSvgPicture(
                                  "close_service",
                                  boxFit: BoxFit.fill,
                                ),
                                const CustomSizedBox(height: 20),
                                Text(
                                  "areYouSure?".translate(context: context),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.blackColor),
                                ),
                                const CustomSizedBox(height: 10),
                                Text(
                                  value
                                      ? "openJobEnableDescription".translate(context: context)
                                      : "openJobDesableDescription".translate(context: context),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.lightGreyColor),
                                ),
                                const CustomSizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomRoundedButton(
                                        onTap: () {
                                          setState(() {
                                            isJobRequestEnable = value ? "1" : "0";
                                          });
                                          context
                                              .read<ManageCustomJobValueCubit>()
                                              .ManageCustomJobValue(
                                                customJobValue: isJobRequestEnable,
                                              );
                                          Navigator.pop(context); // Close the bottom sheet
                                        },
                                        widthPercentage: 1,
                                        backgroundColor:
                                            Theme.of(context).colorScheme.secondaryColor,
                                        showBorder: true,
                                        borderColor: Theme.of(context).colorScheme.blackColor,
                                        buttonTitle: 'continue'.translate(context: context),
                                        titleColor: Theme.of(context).colorScheme.blackColor,
                                      ),
                                    ),
                                    const CustomSizedBox(width: 10),
                                    Expanded(
                                      child: CustomRoundedButton(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        widthPercentage: 1,
                                        backgroundColor: Theme.of(context).colorScheme.accentColor,
                                        showBorder: false,
                                        borderColor: Theme.of(context).colorScheme.accentColor,
                                        buttonTitle: 'notYet'.translate(context: context),
                                        titleColor: AppColors.whiteColors,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ));
                    },
                    value: isJobRequestEnable == "1",
                  ),
                  const CustomSizedBox(
                    width: 15,
                  ),
                ],
                backgroundColor: Theme.of(context).colorScheme.secondaryColor,
                surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
                elevation: 1,
                systemOverlayStyle: UiUtils.getSystemUiOverlayStyle(context: context),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(55),
                  child: _buildTabBar(context, isJobRequestEnable!),
                )),
            body: JobRequestTabContent(
              status: selectedStatus,
              scrollController: widget.scrollController,
              isJobRequestEnable: isJobRequestEnable,
            )),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, String isJobRequestEnable) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    return Center(
      child: CustomContainer(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        color: Theme.of(context).colorScheme.secondaryColor,
        width: deviceWidth,
        height: 55,
        child: Row(
          children: List.generate(filters.length, (index) {
            return Expanded(
              child: CustomInkWellContainer(
                onTap: () {
                  if (currFilter == index) {
                    return;
                  }
                  currFilter = index;
                  setState(() {});

                  switch (currFilter) {
                    case 0:
                      selectedStatus = "open_jobs";
                      break;
                    case 1:
                      selectedStatus = 'applied_jobs';
                      break;
                  }
                  context.read<FetchJobRequestCubit>().FetchJobRequest(jobType: selectedStatus);
                },
                child: CustomContainer(
                  decoration: BoxDecoration(
                      color: currFilter == index
                          ? Theme.of(context).colorScheme.accentColor
                          : Theme.of(context).colorScheme.secondaryColor,
                      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
                      border: Border.all(
                        color: currFilter == index
                            ? Theme.of(context).colorScheme.accentColor
                            : Theme.of(context).colorScheme.blackColor.withValues(alpha: 0.5),
                      )),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  constraints: const BoxConstraints(minWidth: 90),
                  height: 50,
                  child: Center(
                    child: Text(
                      filters[index]['fName']!,
                      style: TextStyle(
                        color: currFilter == index
                            ? AppColors.whiteColors
                            : Theme.of(context).colorScheme.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class JobRequestTabContent extends StatefulWidget {
  const JobRequestTabContent(
      {super.key, this.status, required this.scrollController, this.isJobRequestEnable});

  final String? status;
  final ScrollController scrollController;
  final String? isJobRequestEnable;

  @override
  State<JobRequestTabContent> createState() => _JobRequestTabContentState();
}

class _JobRequestTabContentState extends State<JobRequestTabContent> {
  void pageScrollListen() {
    if (widget.scrollController.position.extentAfter == 0) {
      if (context.read<FetchJobRequestCubit>().hasMoreJobRequest()) {
        context.read<FetchJobRequestCubit>().fetchMoreJobRequest(widget.status);
      }
    }
  }

  @override
  void initState() {
    context.read<FetchJobRequestCubit>().FetchJobRequest(jobType: widget.status);
    widget.scrollController.addListener(pageScrollListen);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
        onRefresh: () async {
          await context.read<FetchJobRequestCubit>().FetchJobRequest(jobType: widget.status);
        },
        child: CustomSizedBox(
          height: MediaQuery.sizeOf(context).height,
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: widget.status == 'open_jobs' ? openJobsList() : appliedJobsList(),
          ),
        ));
  }

  Widget openJobsList() {
    return BlocBuilder<FetchJobRequestCubit, FetchJobRequestState>(
      builder: (BuildContext context, FetchJobRequestState state) {
        if (state is FetchJobRequestInProgress) {
          // Show shimmer loading initially
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsetsDirectional.all(16),
            itemCount: 8,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: 170,
                  ),
                ),
              );
            },
          );
        }

        if (state is FetchJobRequestFailure) {
          // Error state
          return Center(
            child: ErrorContainer(
              onTapRetry: () {
                context.read<FetchJobRequestCubit>().FetchJobRequest(jobType: widget.status);
              },
              errorMessage: state.errorMessage.translate(context: context),
            ),
          );
        }

        if (state is FetchJobRequestSuccess) {
          // If there are no items
          if (state.jobRequest.isEmpty) {
            return NoDataContainer(
              imageTitle: "design",
              fontSize: 18,
              fontWeight: FontWeight.w700,
              titleKey: 'noJobsAvailable'.translate(context: context),
              subTitleKey: 'noJobsAvailableDetail'.translate(context: context),
            );
          }

          return Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                itemCount: state.jobRequest.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final JobRequestModel jobRequestModel = state.jobRequest[index];
                  final String requestedStartDate = jobRequestModel.requestedStartDate ?? "";
                  final String requestedStartTime = jobRequestModel.requestedStartTime ?? "";

                  // Combine date and time
                  final String combinedDateTimeString = "$requestedStartDate $requestedStartTime";

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.openJobRequestDetails,
                        arguments: {'jobRequestModel': jobRequestModel},
                      );
                    },
                    child: CustomContainer(
                      padding: const EdgeInsetsDirectional.all(10),
                      borderRadius: UiUtils.borderRadiusOf10,
                      color: Theme.of(context).colorScheme.secondaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            jobRequestModel.serviceTitle ?? "",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.blackColor,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 5),
                          CustomText(
                            jobRequestModel.serviceShortDescription ?? "",
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: context.colorScheme.lightGreyColor,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 10),
                          CustomText(
                            "budget".translate(context: context),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.lightGreyColor,
                          ),
                          Row(
                            children: [
                              CustomText(
                                (jobRequestModel.minPrice!).replaceAll(',', '').priceFormat(),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.blackColor,
                              ),
                              CustomText(
                                " ${"to".translate(context: context)} ",
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.lightGreyColor,
                              ),
                              CustomText(
                                (jobRequestModel.maxPrice!).replaceAll(',', '').priceFormat(),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.blackColor,
                              ),
                            ],
                          ),
                          CustomDivider(
                            thickness: 0.5,
                            color: Theme.of(context).colorScheme.lightGreyColor.withValues(alpha: 0.3),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomContainer(
                                height: 35,
                                width: 35,
                                decoration: const BoxDecoration(shape: BoxShape.circle),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
                                  child: CustomCachedNetworkImage(
                                    imageUrl: jobRequestModel.image ?? "",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      jobRequestModel.username ?? "",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.blackColor,
                                      maxLines: 1,
                                    ),
                                    CustomText(
                                      combinedDateTimeString.convertToAgo(context: context),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context).colorScheme.lightGreyColor,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              showButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.pushNamed(
                                    context,
                                    Routes.openJobRequestDetails,
                                    arguments: {'jobRequestModel': jobRequestModel},
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const CustomSizedBox(
                  height: 10,
                ),
              ),
              // Progress indicator logic
              if (state.isLoadingMoreJobRequest)
                CustomCircularProgressIndicator(
                  color: Theme.of(context).colorScheme.accentColor,
                )
            ],
          );
        }
        return const CustomContainer();
      },
    );
  }

  Widget appliedJobsList() {
    return BlocBuilder<FetchJobRequestCubit, FetchJobRequestState>(
      builder: (BuildContext context, FetchJobRequestState state) {
        if (state is FetchJobRequestInProgress) {
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsetsDirectional.all(16),
            itemCount: 8,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: 170,
                  ),
                ),
              );
            },
          );
        }

        if (state is FetchJobRequestFailure) {
          return Center(
            child: ErrorContainer(
              onTapRetry: () {
                context.read<FetchJobRequestCubit>().FetchJobRequest(jobType: widget.status);
              },
              errorMessage: state.errorMessage.translate(context: context),
            ),
          );
        }
        if (state is FetchJobRequestSuccess) {
          if (state.jobRequest.isEmpty) {
            return NoDataContainer(
              imageTitle: "design",
              fontSize: 18,
              fontWeight: FontWeight.w700,
              titleKey: 'noJobsAvailable'.translate(context: context),
              subTitleKey: 'noJobsAvailableDetail'.translate(context: context),
            );
          }

          return Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                itemCount: state.jobRequest.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final JobRequestModel jobRequestModel = state.jobRequest[index];
                  final String requestedStartDate = jobRequestModel.requestedStartDate!;
                  final String requestedStartTime = jobRequestModel.requestedStartTime!;

                  // Combine and parse using intl package
                  final String combinedDateTimeString = "$requestedStartDate $requestedStartTime";

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.appliedJobrequestDetails,
                        arguments: {'jobRequestModel': jobRequestModel},
                      );
                    },
                    child: CustomContainer(
                      padding: const EdgeInsetsDirectional.all(10),
                      borderRadius: UiUtils.borderRadiusOf10,
                      color: Theme.of(context).colorScheme.secondaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      jobRequestModel.serviceTitle!,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.blackColor,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 5),
                                    CustomText(
                                      jobRequestModel.serviceShortDescription!,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context).colorScheme.lightGreyColor,
                                      maxLines: 2,
                                    ),
                                    const Divider(),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomContainer(
                                          height: 35,
                                          width: 35,
                                          decoration: const BoxDecoration(shape: BoxShape.circle),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(UiUtils.borderRadiusOf50),
                                            child: CustomCachedNetworkImage(
                                              imageUrl: jobRequestModel.image ?? "",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CustomText(
                                                jobRequestModel.username!,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).colorScheme.blackColor,
                                                maxLines: 1,
                                              ),
                                              CustomText(
                                                combinedDateTimeString.convertToAgo(
                                                    context: context),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).colorScheme.lightGreyColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CustomText(
                                                "budget".translate(context: context),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: Theme.of(context).colorScheme.lightGreyColor,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: CustomText(
                                                      "${jobRequestModel.minPrice!.replaceAll(",", "").priceFormat()} - ${jobRequestModel.maxPrice!.replaceAll(",", "").priceFormat()}",
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color:
                                                          Theme.of(context).colorScheme.blackColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  CustomSvgPicture(
                                                    'arrow_next',
                                                    width: 15,
                                                    height: 15,
                                                    boxFit: BoxFit.fill,
                                                    color: Theme.of(context).colorScheme.blackColor,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const CustomSizedBox(
                  height: 10,
                ),
              ),
              if (state.isLoadingMoreJobRequest)
                CustomCircularProgressIndicator(
                  color: Theme.of(context).colorScheme.accentColor,
                )
            ],
          );
        }

        return const CustomContainer();
      },
    );
  }

  Widget showButton({
    void Function()? onPressed,
  }) {
    return CustomSizedBox(
      height: 35,
      width: 120,
      child: CustomIconButton(
        textDirection: TextDirection.rtl,
        imgName: "arrow_next",
        iconColor: Theme.of(context).colorScheme.accentColor,
        titleText: 'applyNow'.translate(
          context: context,
        ),
        fontWeight: FontWeight.w400,
        fontSize: 13.0,
        borderRadius: UiUtils.borderRadiusOf5,
        titleColor: Theme.of(context).colorScheme.accentColor,
        borderColor: Colors.transparent,
        bgColor: Theme.of(context).colorScheme.accentColor.withValues(alpha: 0.1),
        onPressed: onPressed,
      ),
    );
  }
}
