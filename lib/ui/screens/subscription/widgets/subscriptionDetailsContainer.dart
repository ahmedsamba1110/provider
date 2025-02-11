import 'package:edemand_partner/app/generalImports.dart';
import 'package:edemand_partner/ui/widgets/customReadMoreTextContainer.dart';
import 'package:flutter/material.dart';

class SubscriptionDetailsContainer extends StatelessWidget {
  final bool? showLoading;
  final bool isActiveSubscription;
  final bool isAvailableForPurchase;
  final bool isPreviousSubscription;
  final bool needToShowPaymentStatus;
  final SubscriptionInformation subscriptionDetails;
  final Function onBuyButtonPressed;

  const SubscriptionDetailsContainer({
    super.key,
    required this.subscriptionDetails,
    required this.onBuyButtonPressed,
    required this.isActiveSubscription,
    required this.isAvailableForPurchase,
    required this.isPreviousSubscription,
    this.showLoading,
    required this.needToShowPaymentStatus,
  });

  Widget getPaymentStatusContainer({required String paymentStatus, required BuildContext context}) {
    return Row(
      children: [
        Icon(
          paymentStatus == "0"
              ? Icons.pending
              : paymentStatus == "1"
                  ? Icons.done
                  : Icons.close,
          size: 16,
          color: paymentStatus == "0"
              ? AppColors.starRatingColor
              : paymentStatus == "1"
                  ? AppColors.greenColor
                  : AppColors.redColor,
        ),
        const CustomSizedBox(
          width: 5,
        ),
        Text(
          paymentStatus == "0"
              ? "paymentPending".translate(context: context)
              : paymentStatus == "1"
                  ? "paymentSuccess".translate(context: context)
                  : "paymentFailed".translate(context: context),
          style: TextStyle(
            color: paymentStatus == "0"
                ? AppColors.starRatingColor
                : paymentStatus == "1"
                    ? AppColors.greenColor
                    : AppColors.redColor,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
      ],
    );
  }

  Widget getTitle({required String title, required BuildContext context}) {
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

  Widget setSubscriptionPlanDetailsPoint({
    required final String title,
    required final BuildContext context,
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
            style: TextStyle(color: Theme.of(context).colorScheme.blackColor, fontSize: 12),
          ),
        )
      ],
    );
  }

  Widget buyButton({
    required final bool isLoading,
    required final String subscriptionId,
    required BuildContext context,
    required Function onBuyButtonPressed,
  }) {
    return CustomRoundedButton(
      widthPercentage: 0.3,
      height: 30,
      textSize: 14,
      radius: 5,
      backgroundColor: Theme.of(context).colorScheme.accentColor,
      buttonTitle: "buyPlan".translate(context: context),
      showBorder: false,
      onTap: () {
        onBuyButtonPressed.call();
      },
      child: isLoading
          ? CustomContainer(
              height: 30,
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: FittedBox(
                child: CustomCircularProgressIndicator(
                  color: AppColors.whiteColors,
                  strokeWidth: 2,
                ),
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryColor,
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
      ),
      child: CustomContainer(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryColor,
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (needToShowPaymentStatus) ...[
              getPaymentStatusContainer(
                paymentStatus: (subscriptionDetails.isPayment ?? "0").capitalize(),
                context: context,
              ),
              const CustomSizedBox(
                height: 5,
              ),
            ],

            getTitle(title: subscriptionDetails.name ?? "", context: context),
            const CustomSizedBox(
              height: 5,
            ),

            Row(
              children: [
                Text(
                  (subscriptionDetails.discountPrice ?? "0") != "0"
                      ? (subscriptionDetails.discountPriceWithTax ?? "0").priceFormat()
                      : (subscriptionDetails.priceWithTax ?? "0") == "0"
                          ? "free".translate(context: context)
                          : (subscriptionDetails.priceWithTax ?? "0").priceFormat(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.accentColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                if ((subscriptionDetails.discountPrice ?? "0") != "0") ...[
                  const CustomSizedBox(width: 3),
                  Text(
                    (subscriptionDetails.priceWithTax ?? "0").priceFormat(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightGreyColor,
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ],
                if (isAvailableForPurchase)
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: buyButton(
                        subscriptionId: subscriptionDetails.id ?? "0",
                        isLoading: showLoading ?? false,
                        context: context,
                        onBuyButtonPressed: onBuyButtonPressed.call,
                      ),
                    ),
                  )
              ],
            ),
            const CustomSizedBox(
              height: 5,
            ),
            if ((subscriptionDetails.taxPercenrage ?? "0") != "0")
              setSubscriptionPlanDetailsPoint(
                context: context,
                title:
                    "${subscriptionDetails.taxPercenrage ?? "0"}% ${"taxIncludedInPrice".translate(context: context)}",
              ),
            setSubscriptionPlanDetailsPoint(
              context: context,
              title: (subscriptionDetails.maxOrderLimit ?? "") != "" &&
                      (subscriptionDetails.maxOrderLimit ?? "") != "0"
                  ? "${"enjoyGenerousOrderLimitOf".translate(context: context)} ${subscriptionDetails.maxOrderLimit ?? "0"} ${"ordersDuringYourSubscriptionPeriod".translate(context: context)}"
                  : "enjoyUnlimitedOrders".translate(context: context),
            ),
            const CustomSizedBox(
              height: 5,
            ),
            setSubscriptionPlanDetailsPoint(
              context: context,
              title: (subscriptionDetails.duration ?? "") != "" &&
                      (subscriptionDetails.duration ?? "") != "unlimited"
                  ? "${"yourSubscriptionWillBeValidFor".translate(context: context)} ${subscriptionDetails.duration ?? ""} ${"days".translate(context: context)}"
                  : "enjoySubscriptionForUnlimitedDays".translate(context: context),
            ),

            const CustomSizedBox(
              height: 5,
            ),
            setSubscriptionPlanDetailsPoint(
              context: context,
              title: (subscriptionDetails.isCommision == "yes")
                  ? "${subscriptionDetails.commissionPercentage ?? ""}% ${"commissionWillBeAppliedToYourEarnings".translate(context: context)}"
                  : "noNeedToPayExtraCommission".translate(context: context),
            ),
            const CustomSizedBox(
              height: 5,
            ),
            setSubscriptionPlanDetailsPoint(
              context: context,
              title: subscriptionDetails.isCommision == "yes"
                  ? "${"commissionThreshold".translate(context: context)} ${subscriptionDetails.commissionThreshold ?? "".priceFormat()} ${"AmountIsReached".translate(context: context)}"
                  : "noThresholdOnPayOnDeliveryAmount".translate(context: context),
            ),
            //
            if (isAvailableForPurchase) ...[
              const CustomSizedBox(
                height: 5,
              ),
            ],
            if (isActiveSubscription || isPreviousSubscription) ...[
              const CustomSizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomContainer(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.greenColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("purchasedOn".translate(context: context)),
                          Text(
                            ( subscriptionDetails.purchaseDate ?? "").formatDate(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.greenColor,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const CustomSizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomContainer(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.redColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPreviousSubscription
                                ? "expiredOn".translate(context: context)
                                : "validTill".translate(context: context),
                          ),
                          Text(
                            (subscriptionDetails.duration ?? "") != "" && (subscriptionDetails.duration ?? "") != "unlimited"
                                ? (subscriptionDetails.expiryDate ?? "").formatDate()
                                : "-",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.redColor,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if ((subscriptionDetails.description ?? "") != "") ...[
              const CustomSizedBox(
                height: 5,
              ),
              CustomContainer(
                constraints: const BoxConstraints(minHeight: 65),
                child: CustomReadMoreTextContainer(
                  text: subscriptionDetails.description ?? "",
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.lightGreyColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
