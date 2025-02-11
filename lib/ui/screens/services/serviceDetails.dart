import 'package:edemand_partner/ui/widgets/bannerAdWidget.dart';
import 'package:edemand_partner/ui/widgets/customReadMoreTextContainer.dart';
import 'package:edemand_partner/ui/widgets/interstitalAdWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../app/generalImports.dart';

class ServiceDetails extends StatefulWidget {
  const ServiceDetails({
    super.key,
    required this.service,
  });

  final ServiceModel service;

  @override
  ServiceDetailsState createState() => ServiceDetailsState();

  static Route<ServiceDetails> route(RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;

    return CupertinoPageRoute(
      builder: (_) => ServiceDetails(
        service: arguments['serviceModel'],
      ),
    );
  }
}

class ServiceDetailsState extends State<ServiceDetails> {
  Map<String, String> allowNotAllowFilter = {'0': 'notAllowed', '1': 'allowed'};

  @override
  void initState() {
    super.initState();
    context.read<FetchServiceReviewsCubit>().fetchReviews(int.parse(widget.service.id!));
  }

  @override
  Widget build(BuildContext context) {
    return InterstitialAdWidget(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        bottomNavigationBar: const BannerAdWidget(),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryColor,
          surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
          elevation: 1,
          centerTitle: true,
          title: CustomText(
            'serviceDetailsLbl'.translate(context: context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.blackColor,
          ),
          leading: const CustomBackArrow(),
        ),
        body: mainWidget(),
      ),
    );
  }

  Widget mainWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      clipBehavior: Clip.none,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          summaryWidget(),
          showDivider(),
          descriptionWidget(),
          showDivider(),
          durationWidget(),
          showDivider(),
          serviceDetailsWidget(),
          if (widget.service.otherImages != null && widget.service.otherImages!.isNotEmpty) ...[
            showDivider(),
            otherImagesWidget(),
          ],
          if (widget.service.files != null && widget.service.files!.isNotEmpty) ...[
            showDivider(),
            filesImagesWidget(),
          ],
          if (widget.service.faqs != null && widget.service.faqs!.isNotEmpty) ...[
            showDivider(),
            faqsWidget(),
          ],
          if (widget.service.longDescription != null &&
              widget.service.longDescription.toString().trim().isNotEmpty) ...[
            showDivider(),
            longDescriptionWidget(),
          ],
          setRatingsAndReviews()
        ],
      ),
    );
  }

  Widget otherImagesWidget() {
    return CustomContainer(
      color: Theme.of(context).colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            'otherImages'.translate(context: context),
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.blackColor,
            fontSize: 14,
          ),
          const CustomSizedBox(height: 10),
          CustomSizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.service.otherImages!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.imagePreviewScreen,
                        arguments: {
                          'startFrom': index,
                          'isReviewType': false,
                          'dataURL': widget.service.otherImages!
                        },
                      ).then((Object? value) {
                        //locked in portrait mode only
                        SystemChrome.setPreferredOrientations(
                          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
                        );
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
                      child: CustomCachedNetworkImage(
                        imageUrl: widget.service.otherImages![index],
                        width: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget filesImagesWidget() {
    return CustomContainer(
      color: Theme.of(context).colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            'files'.translate(context: context),
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.blackColor,
            fontSize: 14,
          ),
          const CustomSizedBox(height: 10),
          Column(
            children: List.generate(widget.service.files!.length, (index) {
              return Column(
                children: [
                  CustomInkWellContainer(
                    onTap: () {
                      launchUrl(
                        Uri.parse(widget.service.files![index]),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: CustomSizedBox(
                      width: double.maxFinite,
                      child: Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: Theme.of(context).colorScheme.lightGreyColor,
                            size: 30,
                          ),
                          const CustomSizedBox(
                            width: 5,
                          ),
                          Text(
                            widget.service.files![index].extractFileName(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.blackColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!(index == widget.service.files!.length - 1)) const Divider(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget longDescriptionWidget() {
    return CustomContainer(
      color: Theme.of(context).colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            'serviceDescription'.translate(context: context),
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.blackColor,
            fontSize: 14,
          ),
          const CustomSizedBox(height: 10),
          HtmlWidget(widget.service.longDescription.toString()),
        ],
      ),
    );
  }

  Widget faqsWidget() {
    return CustomContainer(
      color: Theme.of(context).colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            'faqsFull'.translate(context: context),
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.blackColor,
            fontSize: 14,
          ),
          const CustomSizedBox(height: 10),
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: List.generate(
                  widget.service.faqs!.length,
                  (final int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(

                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          collapsedIconColor: Theme.of(context).colorScheme.blackColor,
                          expandedAlignment: Alignment.topLeft,

                          title: Text(
                            widget.service.faqs![index].question ?? "",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.blackColor,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                          children: <Widget>[
                            Text(
                              widget.service.faqs![index].answer ?? "",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.lightGreyColor,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget showDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Theme.of(context).colorScheme.lightGreyColor,
    );
  }

  Widget getTitleAndSubDetails({
    required String title,
    required String subDetails,
    Color? subTitleBackgroundColor,
    Color? subTitleColor,
    double? width,
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
        CustomContainer(
          width: width,
          decoration: BoxDecoration(
            color: subTitleBackgroundColor?.withValues(alpha: 0.2) ?? Colors.transparent,
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
          ),
          child: CustomReadMoreTextContainer(
            text: subDetails,
            textStyle: TextStyle(
                fontSize: 14, color: subTitleColor ?? Theme.of(context).colorScheme.blackColor),
          ),
        ),
      ],
    );
  }

  Widget summaryWidget() {
    return CustomContainer(
      borderRadius: UiUtils.borderRadiusOf10,
      height: 170,
      color: Theme.of(context).colorScheme.secondaryColor,
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
                  child: CustomCachedNetworkImage(
                    imageUrl: widget.service.imageOfTheService!,
                    width: 70,
                    height: 90,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const CustomSizedBox(
                width: 15,
              ),
              Expanded(
                child: CustomSizedBox(
                  height: 90,
                  width: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        widget.service.title!.toString().capitalize(),
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.blackColor,
                      ),
                      setStars(
                        double.parse(widget.service.rating!),
                        atCenter: Alignment.centerLeft,
                      ),
                      CustomText(
                        "${"reviewsTab".translate(context: context)} (${widget.service.numberOfRatings})",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.blackColor,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const CustomSizedBox(
            height: 10,
          ),
          Row(
            children: [
              if (widget.service.discountedPrice != '0')
                Expanded(
                  child: getTitleAndSubDetails(
                    title: 'discountPriceLbl',
                    subDetails: widget.service.discountedPrice!
                        .replaceAll(',', '')
                        .toString()
                        .priceFormat(),
                  ),
                ),
              Expanded(
                child: getTitleAndSubDetails(
                  title: 'totalPriceLbl',
                  subDetails: widget.service.price!.replaceAll(',', '').toString().priceFormat(),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget setStars(double ratings, {required Alignment atCenter}) {
    return RatingBar.readOnly(
      initialRating: ratings,
      isHalfAllowed: true,
      halfFilledIcon: Icons.star_half,
      filledIcon: Icons.star_rounded,
      emptyIcon: Icons.star_border_rounded,
      filledColor: AppColors.starRatingColor,
      halfFilledColor: AppColors.starRatingColor,
      emptyColor: Theme.of(context).colorScheme.lightGreyColor,
      aligns: atCenter,
      onRatingChanged: (double rating) {},
    );
  }

  Widget getTitle({required String title}) {
    return CustomText(
      title.translate(context: context),
      maxLines: 1,
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Theme.of(context).colorScheme.blackColor,
    );
  }

  Widget descriptionWidget() {
    return CustomContainer(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
        color: Theme.of(context).colorScheme.secondaryColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: getTitleAndSubDetails(
        title: 'aboutService',
        subDetails: widget.service.description!,
      ),
    );
  }

  Widget durationWidget() {
    return CustomContainer(
      borderRadius: UiUtils.borderRadiusOf10,
      color: Theme.of(context).colorScheme.secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'durationLbl'.translate(context: context),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.blackColor,
          ),
          const CustomSizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                'durationDescrLbl'.translate(context: context),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.lightGreyColor,
              ),
              CustomText(
                "${widget.service.duration!} ${"minutes".translate(context: context)}",
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.blackColor,
              ),
            ],
          ),
          const CustomSizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                'requiredMembers'.translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.blackColor,
              ),
              CustomText(
                widget.service.numberOfMembersRequired!,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.blackColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget serviceDetailsWidget() {
    return CustomContainer(
      color: Theme.of(context).colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'serviceDetailsLbl'.translate(context: context),
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.blackColor,
            fontSize: 14,
          ),
          const CustomSizedBox(height: 10),
          getTitleAndSubDetailsWithBackgroundColor(
            title: 'isApprovedByAdmin',
            subDetails: (widget.service.isApprovedByAdmin == "1" ? "approved" : "disApproved")
                .translate(context: context),
            subTitleColor: widget.service.isApprovedByAdmin!.capitalize() == '1'
                ? AppColors.greenColor
                : AppColors.redColor,
            subTitleBackgroundColor: widget.service.isApprovedByAdmin!.capitalize() == '1'
                ? AppColors.greenColor
                : AppColors.redColor,
          ),
          const CustomSizedBox(height: 10),
          getTitleAndSubDetailsWithBackgroundColor(
            title: 'statusLbl',
            subDetails: widget.service.status!.translate(context: context),
            subTitleColor: widget.service.status!.capitalize() == 'Enable'
                ? AppColors.greenColor
                : AppColors.redColor,
            subTitleBackgroundColor: widget.service.status!.capitalize() == 'Enable'
                ? AppColors.greenColor
                : AppColors.redColor,
          ),
          const CustomSizedBox(height: 10),
          setKeyValueRow(
            key: 'cancelableBeforeLbl'.translate(context: context),
            value: "${widget.service.cancelableTill!} ${"minutes".translate(context: context)}",
          ),
          const CustomSizedBox(height: 10),
          setKeyValueRow(
            key: 'isCancelableLbl'.translate(context: context),
            value: allowNotAllowFilter[widget.service.isCancelable!]!.translate(context: context),
          ),
          const CustomSizedBox(height: 10),
          if (context.read<FetchSystemSettingsCubit>().isPayLaterAllowedByAdmin()) ...[
            setKeyValueRow(
              key: 'isPayLaterAllowed'.translate(context: context),
              value: allowNotAllowFilter[widget.service.isPayLaterAllowed!]!
                  .translate(context: context),
            ),
            const CustomSizedBox(height: 10),
          ],
          setKeyValueRow(
            key: 'atStoreAllowed'.translate(context: context),
            value: allowNotAllowFilter[widget.service.isStoreAllowed!]!.translate(context: context),
          ),
          const CustomSizedBox(height: 10),
          setKeyValueRow(
            key: 'atDoorstepAllowed'.translate(context: context),
            value:
                allowNotAllowFilter[widget.service.isDoorStepAllowed!]!.translate(context: context),
          ),
          const CustomSizedBox(height: 10),
          setKeyValueRow(
            key: 'taxTypeLbl'.translate(context: context),
            value: widget.service.taxType!.translate(context: context).capitalize(),
          ),
        ],
      ),
    );
  }

  Widget getTitleAndSubDetailsWithBackgroundColor({
    required String title,
    required String subDetails,
    Color? subTitleBackgroundColor,
    Color? subTitleColor,
    double? width,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          title.translate(context: context),
          fontSize: 14,
          maxLines: 2,
          color: Theme.of(context).colorScheme.lightGreyColor,
        ),
        CustomContainer(
          width: width,
          constraints: const BoxConstraints(minWidth: 100),
          decoration: BoxDecoration(
            color: subTitleBackgroundColor?.withValues(alpha: 0.2) ?? Colors.transparent,
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
          ),
          padding: const EdgeInsets.all(5),
          child: Center(
            child: CustomText(
              subDetails,
              fontSize: 14,
              maxLines: 2,
              color: subTitleColor ?? Theme.of(context).colorScheme.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget setKeyValueRow({required String key, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          key,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.lightGreyColor,
        ),
        CustomText(
          value,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.blackColor,
        ),
      ],
    );
  }

  Widget setRatingsAndReviews() {
    return BlocBuilder<FetchServiceReviewsCubit, FetchServiceReviewsState>(
      builder: (BuildContext context, FetchServiceReviewsState state) {
        if (state is FetchServiceReviewsInProgress) {
          return const ShimmerLoadingContainer(
            child: CustomShimmerContainer(
              height: 100,
            ),
          );
        }

        if (state is FetchServiceReviewsFailure) {
          return const CustomSizedBox();
        }

        if (state is FetchServiceReviewsSuccess) {
          if (state.reviews.isEmpty) {
            return const CustomSizedBox();
          }
          return Column(
            children: [
              showDivider(),
              CustomContainer(
                color: Theme.of(context).colorScheme.secondaryColor,
                borderRadius: UiUtils.borderRadiusOf10,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'reviewsRatingsLbl'.translate(context: context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.blackColor,
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.lightGreyColor.withValues(alpha: 0.4),
                    ),
                    ratingsWidget(state),
                    Divider(
                      color: Theme.of(context).colorScheme.lightGreyColor.withValues(alpha: 0.4),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      // padding: const EdgeInsets.only(top: 5, bottom: 5),
                      physics: const NeverScrollableScrollPhysics(),
                      clipBehavior: Clip.none,
                      itemBuilder: (BuildContext context, int index) {
                        final ReviewsModel rating = state.reviews[index];
                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
                                  child: CustomCachedNetworkImage(
                                    imageUrl: rating.profileImage!,
                                    height: 60,
                                    width: 60,
                                  ),
                                ),
                                const CustomSizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomText(
                                              rating.userName!,
                                              color: Theme.of(context).colorScheme.blackColor,
                                            ),
                                          ),
                                          CustomSizedBox(
                                            height: 20,
                                            width: 45,
                                            child: CustomIconButton(
                                              borderRadius: UiUtils.borderRadiusOf5,
                                              imgName: 'star',
                                              titleText: rating.rating!,
                                              fontSize: 10,
                                              titleColor: Theme.of(context).colorScheme.blackColor,
                                              bgColor: Theme.of(context).colorScheme.secondaryColor,
                                              iconColor: AppColors.starRatingColor,
                                              borderColor:
                                                  Theme.of(context).colorScheme.lightGreyColor,
                                            ),
                                          )
                                        ],
                                      ),
                                      const CustomSizedBox(
                                        height: 3,
                                      ),
                                      CustomText(
                                        rating.ratedOn.toString().formatDateAndTime(),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                        color: Theme.of(context).colorScheme.lightGreyColor,
                                      ),
                                      const CustomSizedBox(
                                        height: 5,
                                      ),
                                      CustomText(
                                        rating.comment!,
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.lightGreyColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (rating.images!.isNotEmpty)
                              CustomSizedBox(
                                height: 65,
                                child: setReviewImages(reviewDetails: rating),
                              ),
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          color: Theme.of(context).colorScheme.lightGreyColor.withValues(alpha: 0.4),
                        );
                      },
                      itemCount: state.reviews.length,
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return const CustomContainer();
      },
    );
  }

  Widget setReviewImages({required ReviewsModel reviewDetails}) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: List.generate(
        reviewDetails.images!.length,
        (int index) => CustomInkWellContainer(
          onTap: () => Navigator.pushNamed(
            context,
            Routes.imagePreviewScreen,
            arguments: {'reviewDetails': reviewDetails, 'startFrom': index},
          ).then((Object? value) {
            //locked in portrait mode only
            SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
            );
          }),
          child: CustomContainer(
            height: 55,
            width: 55,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
            ),
            child: CustomCachedNetworkImage(
              imageUrl: reviewDetails.images![index],
            ),
          ),
        ),
      ),
    );
  }

  Widget ratingsWidget(FetchServiceReviewsSuccess state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CustomText(
          state.ratings.averageRating!.length <= 4
              ? state.ratings.averageRating.toString()
              : state.ratings.averageRating.toString().substring(0, 4),
          color: Theme.of(context).colorScheme.blackColor,
          fontSize: 20,
        ),
        setStars(
          double.parse(state.ratings.averageRating!),
          atCenter: Alignment.center,
        ),
        CustomText(
          "${"reviewsTab".translate(context: context)} (${state.total})",
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.lightGreyColor,
        ),
      ],
    );
  }
}
