import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  ServicesScreenState createState() => ServicesScreenState();
}

class ServicesScreenState extends State<ServicesScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  //
  double? minFilterRange;
  double? maxFilterRange;
  ServiceFilterDataModel? filters;

  //
  String prevVal = '';

  Timer? _searchDelay;
  String previouseSearchQuery = '';

  //
  late TextEditingController searchController = TextEditingController()
    ..addListener(searchServiceListener);

  late final AnimationController _filterButtonOpacityAnimation =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  //
  ValueNotifier<bool> isScrolling = ValueNotifier(false);

  @override
  void initState() {
    context.read<FetchServicesCubit>().fetchServices(filter: filters);
    context.read<FetchServiceCategoryCubit>().fetchCategories();
    context.read<FetchTaxesCubit>().fetchTaxes();
    widget.scrollController.addListener(_pageScrollListener);
    super.initState();
  }

  void _pageScrollListener() {
    if (widget.scrollController.position.pixels > 7 && !isScrolling.value) {
      isScrolling.value = true;
    } else if (widget.scrollController.position.pixels < 7 &&
        isScrolling.value) {
      isScrolling.value = false;
    }
    if (widget.scrollController.isEndReached()) {
      if (context.read<FetchServicesCubit>().hasMoreServices()) {
        context.read<FetchServicesCubit>().fetchMoreServices(filter: filters);
      }
    }
  }

  void searchServiceListener() {
    _searchDelay?.cancel();
    searchCallAfterDelay();
  }

  void searchCallAfterDelay() {
    if (searchController.text != '') {
      _searchDelay = Timer(const Duration(milliseconds: 500), searchService);
    } else {
      context.read<FetchServicesCubit>().fetchServices();
    }
  }

  Future<void> searchService() async {
    if (searchController.text.isNotEmpty) {
      if (previouseSearchQuery != searchController.text) {
        context.read<FetchServicesCubit>().searchService(searchController.text);
        previouseSearchQuery = searchController.text;
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    isScrolling.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        body: Stack(
          children: [
            mainWidget(),
            ValueListenableBuilder(
              valueListenable: isScrolling,
              builder: (BuildContext context, Object? value, Widget? child) {
                return CustomContainer(
                  height: 75,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryColor,
                    boxShadow: isScrolling.value
                        ? [
                            BoxShadow(
                              offset: const Offset(0, 0.75),
                              spreadRadius: 1,
                              blurRadius: 5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .blackColor
                                  .withValues(alpha: 0.2),
                            )
                          ]
                        : [],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child:
                      Align(alignment: Alignment.topCenter, child: topWidget()),
                );
              },
            )
          ],
        ),
        floatingActionButton: const AddFloatingButton(
          routeNm: Routes.createService,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget topWidget() {
    return BlocConsumer<FetchServicesCubit, FetchServicesState>(
      listener: (BuildContext context, FetchServicesState state) {
        if (state is FetchServicesSuccess) {
          _filterButtonOpacityAnimation.forward();
        }
      },
      builder: (BuildContext context, FetchServicesState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: setSearchbar()),
              if (state is FetchServicesSuccess) ...[
                const CustomSizedBox(width: 10),
                AnimatedBuilder(
                  animation: _filterButtonOpacityAnimation,
                  builder: (BuildContext context, Widget? c) {
                    return AnimatedOpacity(
                      duration: _filterButtonOpacityAnimation.duration!,
                      opacity: _filterButtonOpacityAnimation.value,
                      child: setFilterButton(
                        maxRange: state.maxFilterRange + 1,
                        minRange: state.minFilterRange,
                      ),
                    );
                  },
                )
              ]
            ],
          ),
        );
      },
    );
  }

  Widget setSearchbar() {
    return CustomContainer(
      width: 250,
      height: 35,
      borderRadius: UiUtils.borderRadiusOf10,
      color: Theme.of(context).colorScheme.secondaryColor,
      child: TextFormField(
        controller: searchController,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          fillColor: Theme.of(context).colorScheme.blackColor,
          hintText: 'searchServicesLbl'.translate(context: context),
          hintStyle:
              TextStyle(color: Theme.of(context).colorScheme.lightGreyColor),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).colorScheme.lightGreyColor,
          ),
        ),
        textAlignVertical: TextAlignVertical.center,
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }

  Widget setFilterButton({required double minRange, required double maxRange}) {
    return CustomSizedBox(
      height: 35,
      width: 83,
      child: CustomIconButton(
        textDirection: TextDirection.rtl,
        imgName: 'filter',
        titleText: 'filterBtnLbl'.translate(context: context),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        iconColor: Theme.of(context).colorScheme.accentColor,
        titleColor: Theme.of(context).colorScheme.accentColor,
        bgColor: Theme.of(context).colorScheme.secondaryColor,
        onPressed: () async {
          final result = await UiUtils.showModelBottomSheets(
              context: context,
              child: BlocProvider.value(
                value: BlocProvider.of<FetchServiceCategoryCubit>(context),
                child: Builder(
                  builder: (BuildContext context) {
                    return FilterByBottomSheet(
                      minRange: minRange,
                      maxRange: maxRange,
                      selectedMinRange: double.parse(
                        filters?.minBudget ?? minRange.toString(),
                      ),
                      selectedMaxRange: double.parse(
                        filters?.maxBudget ?? maxRange.toString(),
                      ),
                      selectedRating: filters?.rating,
                    );
                  },
                ),
              ));

          if (result != null) {
            filters = result;

            setState(() {});
            Future.delayed(Duration.zero, () {
              context.read<FetchServicesCubit>().fetchServices(filter: result);
            });
          }
        },
      ),
    );
  }

  Widget getTitleAndSubDetails({
    required String title,
    required String subDetails,
    bool? showRatingIcon,
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
        Row(
          children: [
            Visibility(
              visible: showRatingIcon ?? false,
              child: const Icon(
                Icons.star_outlined,
                color: AppColors.starRatingColor,
                size: 20,
              ),
            ),
            CustomText(
              subDetails,
              fontSize: 14,
              maxLines: 2,
              color: Theme.of(context).colorScheme.blackColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget mainWidget() {
    return BlocListener<DeleteServiceCubit, DeleteServiceState>(
      listener: (BuildContext context, DeleteServiceState deleteServiceState) {
        if (deleteServiceState is DeleteServiceSuccess) {
          context
              .read<FetchServicesCubit>()
              .deleteServiceFromCubit(deleteServiceState.id);
          UiUtils.showMessage(
            context,
            message: 'serviceDeletedSuccessfully'.translate(context: context),
            type: ToastificationType.success,
          );
        }
        if (deleteServiceState is DeleteServiceFailure) {
          UiUtils.showMessage(
            context,
            message:
                deleteServiceState.errorMessage.translate(context: context),
            type: ToastificationType.error,
          );
        }
      },
      child: CustomRefreshIndicator(
        onRefresh: () async {
          filters = null;
          context.read<FetchServicesCubit>().fetchServices(filter: filters);
          context.read<FetchTaxesCubit>().fetchTaxes();
          context.read<FetchServiceCategoryCubit>().fetchCategories();
        },
        child: BlocBuilder<FetchServicesCubit, FetchServicesState>(
          builder: (BuildContext context, FetchServicesState state) {
            if (state is FetchServicesFailure) {
              return Center(
                child: ErrorContainer(
                  onTapRetry: () {
                    context
                        .read<FetchServicesCubit>()
                        .fetchServices(filter: filters);
                    context.read<FetchTaxesCubit>().fetchTaxes();
                  },
                  errorMessage: state.errorMessage.translate(context: context),
                ),
              );
            }
            if (state is FetchServicesSuccess) {
              if (state.services.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: NoDataContainer(
                      titleKey: 'noDataFound'.translate(context: context),
                    ),
                  ),
                );
              }
              return SingleChildScrollView(
                clipBehavior: Clip.none,
                controller: widget.scrollController,
                child: Column(
                  children: [
                    const CustomSizedBox(
                      height: 75,
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        bottom: 15,
                        left: 15,
                        right: 15,
                      ),
                      itemCount: state.services.length,
                      physics: const NeverScrollableScrollPhysics(),
                      clipBehavior: Clip.none,
                      itemBuilder: (BuildContext context, int index) {
                        final ServiceModel service = state.services[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.serviceDetails,
                              arguments: {'serviceModel': service},
                            );
                          },
                          child: CustomContainer(
                            padding: const EdgeInsets.all(10),
                            color: Theme.of(context).colorScheme.secondaryColor,
                            borderRadius: UiUtils.borderRadiusOf10,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    CustomSizedBox(
                                      width: 75,
                                      height: 105,
                                      child: setImage(
                                        imageURL: service.imageOfTheService!,
                                      ),
                                    ),
                                    const CustomSizedBox(height: 10),
                                    getTitleAndSubDetails(
                                      title: 'priceLbl'
                                          .translate(context: context),
                                      subDetails: (service.price ?? "0")
                                          .replaceAll(',', '')
                                          .toString()
                                          .priceFormat(),
                                    ),
                                  ],
                                ),
                                const CustomSizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        service.title!.capitalize(),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .blackColor,
                                      ),
                                      const CustomSizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                getTitleAndSubDetails(
                                                  title: 'rating'.translate(
                                                    context: context,
                                                  ),
                                                  subDetails:
                                                      service.rating!.length > 3
                                                          ? service.rating!
                                                              .substring(0, 3)
                                                          : service.rating!,
                                                  showRatingIcon: true,
                                                ),
                                                const CustomSizedBox(
                                                    height: 10),
                                                getTitleAndSubDetails(
                                                  title:
                                                      'durationLbl'.translate(
                                                    context: context,
                                                  ),
                                                  subDetails:
                                                      "${service.duration ?? '0'}  ${"minutes".translate(context: context)}",
                                                ),
                                                const CustomSizedBox(
                                                    height: 10),
                                                showButton(
                                                  imageName: 'edit',
                                                  titleName:
                                                      'editBtnLbl'.translate(
                                                    context: context,
                                                  ),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .accentColor,
                                                  onPressed: () {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    Navigator.pushNamed(
                                                      context,
                                                      Routes.createService,
                                                      arguments: {
                                                        'service': service,
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                getTitleAndSubDetails(
                                                  title: 'statusLbl'.translate(
                                                    context: context,
                                                  ),
                                                  subDetails:
                                                      (service.status ?? '')
                                                          .translate(
                                                              context: context),
                                                ),
                                                const CustomSizedBox(
                                                    height: 10),
                                                getTitleAndSubDetails(
                                                  title:
                                                      'personLabel'.translate(
                                                    context: context,
                                                  ),
                                                  subDetails: service
                                                          .numberOfMembersRequired ??
                                                      '',
                                                ),
                                                const CustomSizedBox(
                                                    height: 10),
                                                showButton(
                                                  imageName: 'delete',
                                                  titleName:
                                                      'deleteBtnLbl'.translate(
                                                    context: context,
                                                  ),
                                                  onPressed: () {
                                                    clickOfDeleteButton(
                                                      serviceId: service.id!,
                                                    );
                                                  },
                                                  color: AppColors.redColor,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),

                                      //  setButtons(service)
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const CustomSizedBox(
                        height: 10,
                      ),
                    ),
                    if (state.isLoadingMoreServices)
                      CustomCircularProgressIndicator(
                        color: Theme.of(context).colorScheme.accentColor,
                      )
                  ],
                ),
              );
            }
            return SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Column(
                children: [
                  const CustomSizedBox(
                    height: 65,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsetsDirectional.all(16),
                    itemCount: 8,
                    itemBuilder: (BuildContext context, int index) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0),
                        child: ShimmerLoadingContainer(
                          child: CustomShimmerContainer(
                            height: 120,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget setImage({required String imageURL}) {
    return CustomContainer(
      borderRadius: UiUtils.borderRadiusOf10,
      color: Colors.transparent,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
          child: CustomCachedNetworkImage(
            imageUrl: imageURL,
            width: 75,
            height: 105,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Widget showButton({
    required String imageName,
    required String titleName,
    void Function()? onPressed,
    required Color color,
  }) {
    return CustomSizedBox(
      width: 84,
      height: 30,
      child: CustomIconButton(
        imgName: imageName,
        iconColor: color,
        titleText: titleName,
        fontSize: 12.0,
        borderRadius: UiUtils.borderRadiusOf5,
        titleColor: color,
        borderColor: Colors.transparent,
        bgColor: color.withValues(alpha: 0.3),
        onPressed: onPressed,
      ),
    );
  }

  void clickOfDeleteButton({required String serviceId}) {
    UiUtils.showAnimatedDialog(
        context: context,
        child: BlocProvider.value(
          value: BlocProvider.of<DeleteServiceCubit>(context),
          child: Builder(builder: (context) {
            return ConfirmationDialog(
                title: "deleteService",
                description: "deleteDescription",
                confirmButtonName: "delete",
                showProgressIndicator: context.watch<DeleteServiceCubit>().state
                    is DeleteServiceInProgress,
                confirmButtonPressed: () {
                  //
                  if (context
                      .read<FetchSystemSettingsCubit>()
                      .isDemoModeEnable()) {
                    UiUtils.showDemoModeWarning(context: context);
                    return;
                  }
                  //
                  context.read<DeleteServiceCubit>().deleteService(
                    int.parse(serviceId),
                    onDelete: () {
                      Navigator.pop(context);
                    },
                  );
                });
          }),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
