import 'package:edemand_partner/ui/widgets/bannerAdWidget.dart';
import 'package:edemand_partner/ui/widgets/interstitalAdWidget.dart';
import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class PromoCode extends StatefulWidget {
  const PromoCode({super.key});

  @override
  PromoCodeState createState() => PromoCodeState();

  static Route<PromoCode> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) => DeletePromocodeCubit(),
          ),
        ],
        child: const PromoCode(),
      ),
    );
  }
}

class PromoCodeState extends State<PromoCode> {
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListener);

  @override
  void initState() {
    context.read<FetchPromocodesCubit>().fetchPromocodeList();
    super.initState();
  }

  void _pageScrollListener() {
    if (_pageScrollController.isEndReached()) {
      context.read<FetchPromocodesCubit>().fetchMorePromocodes();
    }
  }

  void deletePromocode(promocode) {
    UiUtils.showAnimatedDialog(
        context: context,
        child: BlocProvider.value(
          value: BlocProvider.of<DeletePromocodeCubit>(context),
          child: Builder(builder: (context) {
            return ConfirmationDialog(
                title: "deletePromocode",
                description: "deleteDescription",
                confirmButtonName: "delete",
                showProgressIndicator: context
                    .watch<DeletePromocodeCubit>()
                    .state is DeleteServiceInProgress,
                confirmButtonPressed: () {
                  if (promocode.id != null) {
                    if (context
                        .read<FetchSystemSettingsCubit>()
                        .isDemoModeEnable()) {
                      UiUtils.showDemoModeWarning(context: context);
                      return;
                    }
                    context.read<DeletePromocodeCubit>().deletePromocode(
                      int.parse(promocode.id!),
                      onDelete: () {
                        Navigator.pop(context);
                      },
                    );
                  } else {
                    UiUtils.showMessage(
                      context,
                     message:  'somethingWentWrong'.translate(context: context),
                     type:  ToastificationType.error,
                    );
                  }
                });
          }),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return InterstitialAdWidget(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: AppBar(
          elevation: 1,
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.secondaryColor,
          surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
          title: CustomText(
            'promoCodeLbl'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.bold,
          ),
          leading: const CustomBackArrow(),
        ),
        floatingActionButton: const AddFloatingButton(
          routeNm: Routes.addPromoCode,
        ),
        bottomNavigationBar: const BannerAdWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: BlocListener<DeletePromocodeCubit, DeletePromocodeState>(
          listener: (BuildContext context, DeletePromocodeState state) {
            if (state is DeletePromocodeSuccess) {
              context
                  .read<FetchPromocodesCubit>()
                  .deletePromocodeFromCubit(state.id);

              UiUtils.showMessage(
                context,
               message:  'promocodeDeleteSuccess'.translate(context: context),
               type:  ToastificationType.success,
              );
            }
            if (state is DeletePromocodeFailure) {
              UiUtils.showMessage(
                  context,
                 message:  state.errorMessage.translate(context: context),
                 type:  ToastificationType.error);
            }
          },
          child: mainWidget(),
        ),
      ),
    );
  }

  Widget mainWidget() {
    return CustomRefreshIndicator(
      onRefresh: () async {
        context.read<FetchPromocodesCubit>().fetchPromocodeList();
      },
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: BlocBuilder<FetchPromocodesCubit, FetchPromocodesState>(
          builder: (BuildContext context, FetchPromocodesState state) {
            if (state is FetchPromocodesInProgress) {
              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: 10,
                physics: const NeverScrollableScrollPhysics(),
                clipBehavior: Clip.none,
                itemBuilder: (BuildContext context, int index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: ShimmerLoadingContainer(
                      child: CustomShimmerContainer(
                        height: 150,
                      ),
                    ),
                  );
                },
              );
            }
            if (state is FetchPromocodesFailure) {
              return Center(
                child: ErrorContainer(
                  onTapRetry: () {
                    context.read<FetchPromocodesCubit>().fetchPromocodeList();
                  },
                  errorMessage: state.errorMessage.translate(context: context),
                ),
              );
            }

            if (state is FetchPromocodesSuccess) {
              if (state.promocodes.isEmpty) {
                return NoDataContainer(
                    titleKey: 'noDataFound'.translate(context: context));
              }
              return ListView.separated(
                controller: _pageScrollController,
                shrinkWrap: true,
                itemCount: state.promocodes.length,
                physics: const NeverScrollableScrollPhysics(),
                clipBehavior: Clip.none,
                itemBuilder: (BuildContext context, int index) {
                  final PromocodeModel promocode = state.promocodes[index];
                  return CustomContainer(
                    padding:
                        const EdgeInsetsDirectional.only(start: 10, end: 10),
                    color: Theme.of(context).colorScheme.secondaryColor,
                    borderRadius: UiUtils.borderRadiusOf10,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    UiUtils.borderRadiusOf10),
                                child: CustomCachedNetworkImage(
                                  imageUrl: promocode.image!,
                                  width: 80,
                                  height: 85,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            const CustomSizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 2),
                                    child: CustomText(
                                      promocode.promoCode!,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .blackColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 3, bottom: 2),
                                    child: CustomText(
                                      promocode.message!,
                                      maxLines: 2,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .blackColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 3, bottom: 2),
                                    child: setFromToTime(
                                      startDate: promocode.startDate!
                                          .split(' ')[0]
                                          .formatDate(),
                                      endDate: promocode.endDate!
                                          .split(' ')[0]
                                          .formatDate(),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: setStatusAndButtons(
                            promoCodeStatus: promocode.status!,
                            context,
                            height: 30,
                            editAction: () {
                              Navigator.pushNamed(
                                context,
                                Routes.addPromoCode,
                                arguments: {'promocode': promocode},
                              );
                            },
                            deleteAction: () {
                              deletePromocode(promocode);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const CustomSizedBox(
                  height: 10,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget setStatusAndButtons(
    BuildContext context, {
    required String promoCodeStatus,
    VoidCallback? editAction,
    VoidCallback? deleteAction,
    double? height,
  }) {
    //set required later
    return Row(
      children: [
        setStatus(
          status: promoCodeStatus,
        ),
        const CustomSizedBox(width: 10),
        CustomSizedBox(
          height: height,
          width: 84,
          child: CustomIconButton(
            imgName: 'edit',
            iconColor: Theme.of(context).colorScheme.accentColor,
            titleText: 'editBtnLbl'.translate(context: context),
            fontSize: 12.0,
            titleColor: Theme.of(context).colorScheme.accentColor,
            borderColor: Colors.transparent,
            bgColor: Theme.of(context)
                .colorScheme
                .accentColor
                .withValues(alpha: 0.3),
            onPressed: editAction,
            borderRadius: UiUtils.borderRadiusOf5,
          ),
        ),
        const CustomSizedBox(width: 10),
        CustomSizedBox(
          height: height,
          width: 84,
          child: CustomIconButton(
            imgName: 'delete',
            titleText: 'deleteBtnLbl'.translate(context: context),
            fontSize: 12.0,
            iconColor: AppColors.redColor,
            borderRadius: UiUtils.borderRadiusOf5,
            titleColor: AppColors.redColor,
            borderColor: Colors.transparent,
            bgColor: AppColors.redColor.withValues(alpha: 0.3),
            onPressed: deleteAction,
          ),
        ),
      ],
    );
  }

  Widget setFromToTime({required String startDate, required String endDate}) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 5),
          child: CustomSvgPicture(
            'b_calender',
            color: Theme.of(context).colorScheme.lightGreyColor,
          ),
        ),
        CustomText(
          startDate,
          color: Theme.of(context).colorScheme.lightGreyColor,
          fontSize: 12,
        ),
        const CustomSizedBox(
          width: 5,
        ),
        CustomText(
          'toLbl'.translate(context: context),
          color: Theme.of(context).colorScheme.lightGreyColor,
          fontSize: 12,
        ),
        const CustomSizedBox(
          width: 5,
        ),
        Expanded(
          child: CustomText(
            endDate,
            color: Theme.of(context).colorScheme.lightGreyColor,
            fontSize: 12,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget setStatus({required String status}) {
    final List<Map> statusFilterMap = [
      {
        'value': '0',
        'title': 'deactive'.translate(context: context),
        "color": AppColors.redColor
      },
      {
        'value': '1',
        'title': 'active'.translate(context: context),
        "color": AppColors.greenColor
      }
    ];

    final Map currentStatus = statusFilterMap
        .where((Map element) => element['value'] == status)
        .toList()[0];
    //
    return CustomContainer(
      width: 80,
      decoration: BoxDecoration(
        color: (currentStatus['color'] as Color).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
      ),
      padding: const EdgeInsets.all(5),
      child: Center(
        child: CustomText(
          currentStatus['title'],
          fontSize: 14,
          maxLines: 2,
          color: currentStatus['color'] as Color,
        ),
      ),
    );
  }
}
