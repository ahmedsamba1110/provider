import 'package:edemand_partner/app/generalImports.dart';
import 'package:edemand_partner/cubits/fetchPreviousSubscriptionsCubit.dart';
import 'package:edemand_partner/ui/screens/subscription/widgets/subscriptionDetailsContainer.dart';
import 'package:flutter/material.dart';

class SubscriptionHistoryScreen extends StatefulWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  SubscriptionHistoryScreenState createState() => SubscriptionHistoryScreenState();

  static Route<SubscriptionHistoryScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => const SubscriptionHistoryScreen(),
    );
  }
}

class SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListen);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _pageScrollListen() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchPreviousSubscriptionsCubit>().hasMoreData()) {
        context.read<FetchPreviousSubscriptionsCubit>().fetchMorePreviousSubscriptions();
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
          'previousSubscriptions'.translate(context: context),
          color: Theme.of(context).colorScheme.blackColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        leading: const CustomBackArrow(),
      ),
      body: mainWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget getTitleAndDetails({required String title, required String subDetails}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title.translate(context: context),
          fontSize: 14,
          color: Theme.of(context).colorScheme.lightGreyColor,
        ),
        const CustomSizedBox(width: 2),
        CustomText(
          subDetails,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.blackColor,
        ),
      ],
    );
  }

  Widget showPreviousSubscriptionList({
    required List<SubscriptionInformation> subscriptionsData,
    required bool isLoadingMore,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      controller: _pageScrollController,
      clipBehavior: Clip.none,
      child: Column(
        children: [
          if (subscriptionsData.isEmpty) ...[
            Center(child: NoDataContainer(titleKey: 'noDataFound'.translate(context: context)))
          ],
          if (subscriptionsData.isNotEmpty) ...[
            Column(
              children: List.generate(subscriptionsData.length + (isLoadingMore ? 1 : 0), (index) {
                if (index >= subscriptionsData.length) {
                  return const CustomCircularProgressIndicator();
                }
                return SubscriptionDetailsContainer(
                  isActiveSubscription: false,
                  needToShowPaymentStatus: true,
                  isAvailableForPurchase: false,
                  isPreviousSubscription: true,
                  showLoading: false,
                  onBuyButtonPressed: () {},
                  subscriptionDetails: subscriptionsData[index],
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget mainWidget() {
    return CustomRefreshIndicator(
      onRefresh: () async {
        context.read<FetchPreviousSubscriptionsCubit>().fetchPreviousSubscriptions();
      },
      child: BlocBuilder<FetchPreviousSubscriptionsCubit, FetchPreviousSubscriptionsState>(
        builder: (context, state) {
          if (state is FetchPreviousSubscriptionsFailure) {
            return Center(
              child: ErrorContainer(
                onTapRetry: () {
                  context.read<FetchPreviousSubscriptionsCubit>().fetchPreviousSubscriptions();
                },
                errorMessage: state.errorMessage.translate(context: context),
              ),
            );
          }
          if (state is FetchPreviousSubscriptionsSuccess) {
            return state.subscriptionsData.isEmpty
                ? Center(
                    child: NoDataContainer(
                      titleKey: 'previousSubscriptionsNotFound'.translate(context: context),
                    ),
                  )
                : showPreviousSubscriptionList(
                    subscriptionsData: state.subscriptionsData,
                    isLoadingMore: state.isLoadingMoreSubscriptions,
                  );
          }
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            itemCount: 8,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            itemBuilder: (BuildContext context, int index) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: ShimmerLoadingContainer(
                  child: CustomShimmerContainer(
                    height: 100,
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
