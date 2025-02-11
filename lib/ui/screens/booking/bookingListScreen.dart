import 'package:edemand_partner/data/model/chat/chatUser.dart';
import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen>
    with AutomaticKeepAliveClientMixin {
  int currFilter = 0;
  String? selectedStatus;
  String? selectedBookingOrder;
  int? currentOrder = 0;
  List<Map> filters = []; //set  model  from  API  Response
  List<Map> orderFilters = [];

  @override
  void didChangeDependencies() {
    filters = [
      {'id': '0', 'fName': 'all'.translate(context: context)},
      {'id': '1', 'fName': 'awaiting'.translate(context: context)},
      {'id': '2', 'fName': 'confirmed'.translate(context: context)},
      {'id': '3', 'fName': 'started'.translate(context: context)},
      {'id': '4', 'fName': 'rescheduled'.translate(context: context)},
      {'id': '5', 'fName': 'booking_ended'.translate(context: context)},
      {'id': '6', 'fName': 'completed'.translate(context: context)},
      {'id': '7', 'fName': 'cancelled'.translate(context: context)},
    ];
    orderFilters = [
      {'id': '0', 'fName': 'defaultBookings'.translate(context: context)},
      {'id': '1', 'fName': 'customBookings'.translate(context: context)},
    ];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    filters = [
      {'id': '0', 'fName': 'all'.translate(context: context)},
      {'id': '1', 'fName': 'awaiting'.translate(context: context)},
      {'id': '2', 'fName': 'confirmed'.translate(context: context)},
      {'id': '3', 'fName': 'started'.translate(context: context)},
      {'id': '4', 'fName': 'rescheduled'.translate(context: context)},
      {'id': '5', 'fName': 'booking_ended'.translate(context: context)},
      {'id': '6', 'fName': 'completed'.translate(context: context)},
      {'id': '7', 'fName': 'cancelled'.translate(context: context)},
    ];
    orderFilters = [
      {'id': '0', 'fName': 'defaultBookings'.translate(context: context)},
      {'id': '1', 'fName': 'customBookings'.translate(context: context)},
    ];
    return DefaultTabController(
      length: filters.length,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
          body: Column(
            children: [
              CustomSizedBox(
                height: 55,
                child: _buildTabBar(context),
              ),
              Expanded(
                child: BookingsTabContent(
                  status: selectedStatus,
                  scrollController: widget.scrollController,
                  bookingOrder: selectedBookingOrder,
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: CustomContainer(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
                  border: Border.all(
                    color: context.colorScheme.lightGreyColor,
                    width: 0.5,
                  ),
                  color: context.colorScheme.secondaryColor,
                ),
                child: _buildBookingOrderTabBar(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: filters.length,
      itemBuilder: (BuildContext context, int index) {
        return CustomInkWellContainer(
          onTap: () {
            if (currFilter == index) {
              return;
            }
            currFilter = index;
            setState(() {});

            switch (currFilter) {
              case 0:
                selectedStatus = null;
                break;
              case 1:
                selectedStatus = 'awaiting';
                break;
              case 2:
                selectedStatus = 'confirmed';
                break;
              case 3:
                selectedStatus = 'started';
                break;
              case 4:
                selectedStatus = 'rescheduled';
                break;
              case 5:
                selectedStatus = 'booking_ended';
                break;
              case 6:
                selectedStatus = 'completed';
                break;
              case 7:
                selectedStatus = 'cancelled';
                break;
            }
            context
                .read<FetchBookingsCubit>()
                .fetchBookings(selectedStatus, selectedBookingOrder);
          },
          child: CustomContainer(
            decoration: BoxDecoration(
              color: currFilter == index
                  ? Theme.of(context).colorScheme.accentColor
                  : Theme.of(context).colorScheme.secondaryColor,
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            constraints: const BoxConstraints(minWidth: 90),
            height: 50,
            child: Center(
              child: Text(
                filters[index]['fName'],
                style: TextStyle(
                  color: currFilter == index
                      ? AppColors.whiteColors
                      : Theme.of(context).colorScheme.blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingOrderTabBar(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center, // Centers the tabs horizontally

      children: List.generate(orderFilters.length, (int index) {
        return Expanded(
          child: CustomInkWellContainer(
            showSplashEffect: false,
            onTap: () {
              if (currentOrder == index) {
                return;
              }
              currentOrder = index;
              setState(() {});

              switch (currentOrder) {
                case 0:
                  selectedBookingOrder = '';
                  break;
                case 1:
                  selectedBookingOrder = '1';
                  break;
              }
              context
                  .read<FetchBookingsCubit>()
                  .fetchBookings(selectedStatus, selectedBookingOrder);
            },
            child: CustomContainer(
              decoration: BoxDecoration(
                color: currentOrder == index
                    ? Theme.of(context).colorScheme.accentColor
                    : Theme.of(context).colorScheme.secondaryColor,
                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 50,
              child: Center(
                child: CustomText(
                  orderFilters[index]['fName'],
                  color: currentOrder == index
                      ? AppColors.whiteColors
                      : Theme.of(context).colorScheme.blackColor,
                  fontWeight: FontWeight.bold,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BookingsTabContent extends StatefulWidget {
  const BookingsTabContent(
      {super.key,
      this.status,
      this.bookingOrder,
      required this.scrollController});

  final String? status;
  final ScrollController scrollController;
  final String? bookingOrder;

  @override
  State<BookingsTabContent> createState() => _BookingsTabContentState();
}

class _BookingsTabContentState extends State<BookingsTabContent> {
  void pageScrollListen() {
    if (widget.scrollController.isEndReached()) {
      if (context.read<FetchBookingsCubit>().hasMoreData()) {
        context
            .read<FetchBookingsCubit>()
            .fetchMoreBookings(widget.status, widget.bookingOrder);
      }
    }
  }

  @override
  void initState() {
    context
        .read<FetchBookingsCubit>()
        .fetchBookings(widget.status, widget.bookingOrder);
    widget.scrollController.addListener(pageScrollListen);
    super.initState();
  }

  Widget getTitleAndSubDetails({
    required String title,
    required String subDetails,
    bool? isSubtitleBold,
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
        if (title == "statusLbl") ...[
          CustomContainer(
            borderRadius: UiUtils.borderRadiusOf5,
            padding: const EdgeInsets.all(5),
            color: UiUtils.getStatusColor(
                    context: context, statusVal: subDetails.toLowerCase())
                .withValues(alpha: 0.2),
            child: CustomText(
              subDetails,
              fontSize: 14,
              maxLines: 2,
              color: UiUtils.getStatusColor(
                  context: context, statusVal: subDetails.toLowerCase()),
              fontWeight:
                  isSubtitleBold ?? false ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ] else ...[
          CustomText(
            subDetails,
            fontSize: 14,
            maxLines: 2,
            color: Theme.of(context).colorScheme.blackColor,
            fontWeight:
                isSubtitleBold ?? false ? FontWeight.bold : FontWeight.normal,
          ),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: () async {
        context
            .read<FetchBookingsCubit>()
            .fetchBookings(widget.status, widget.bookingOrder);
      },
      child: CustomSizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          child: BlocBuilder<FetchBookingsCubit, FetchBookingsState>(
            builder: (BuildContext context, FetchBookingsState state) {
              final bool systemWisePostbooking = (context
                      .read<FetchSystemSettingsCubit>()
                      .state as FetchSystemSettingsSuccess)
                  .generalSettings
                  .allowPostBookingChat!;
              final bool systemWisePrebooking = (context
                      .read<FetchSystemSettingsCubit>()
                      .state as FetchSystemSettingsSuccess)
                  .generalSettings
                  .allowPreBookingChat!;

              final bool isPreBookingChat = context
                      .read<ProviderDetailsCubit>()
                      .state
                      .providerDetails
                      .providerInformation!
                      .isPreBookingChatAllowed ==
                  '1';
              final bool isPostBookingChat = context
                      .read<ProviderDetailsCubit>()
                      .state
                      .providerDetails
                      .providerInformation!
                      .isPostBookingChatAllowed ==
                  '1';
              if (state is FetchBookingsInProgress) {
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

              if (state is FetchBookingsFailure) {
                return Center(
                  child: ErrorContainer(
                    onTapRetry: () {
                      context
                          .read<FetchBookingsCubit>()
                          .fetchBookings(widget.status, widget.bookingOrder);
                    },
                    errorMessage:
                        state.errorMessage.translate(context: context),
                  ),
                );
              }
              if (state is FetchBookingsSuccess) {
                if (state.bookings.isEmpty) {
                  return NoDataContainer(
                      titleKey: 'noDataFound'.translate(context: context));
                }

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      itemCount: state.bookings.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        final BookingsModel bookingModel =
                            state.bookings[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.bookingDetails,
                              arguments: {'bookingsModel': bookingModel},
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomContainer(
                                      height: 70,
                                      width: 70,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            UiUtils.borderRadiusOf50),
                                        child: CustomCachedNetworkImage(
                                          imageUrl:
                                              bookingModel.profileImage ?? '',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const CustomSizedBox(width: 15),
                                    Expanded(
                                      child: CustomSizedBox(
                                        height: 75,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomText(
                                                    bookingModel.customer ?? '',
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w700,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .blackColor,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .centerEnd,
                                                  child: CustomText(
                                                    (bookingModel.finalTotal ??
                                                            "0")
                                                        .replaceAll(',', '')
                                                        .toString()
                                                        .priceFormat(),
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w700,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .blackColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                            getTitleAndSubDetails(
                                              title: 'invoiceNumber',
                                              subDetails:
                                                  bookingModel.invoiceNo ?? '',
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const CustomSizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    getTitleAndSubDetails(
                                      title: 'mobileNumber',
                                      subDetails: bookingModel.customerNo ?? '',
                                    ),
                                    const Spacer(),
                                    getTitleAndSubDetails(
                                      title: 'dateAndTime',
                                      subDetails:
                                          "${bookingModel.dateOfService.toString().formatDate()}, ${(bookingModel.startingTime ?? "").toString().formatTime()}",
                                    ),
                                  ],
                                ),
                                if (bookingModel.addressId != "0") ...[
                                  const CustomSizedBox(height: 10),
                                  getTitleAndSubDetails(
                                    title: 'addressLbl',
                                    subDetails: bookingModel.address
                                        .toString()
                                        .removeExtraComma(),
                                  ),
                                ],
                                const CustomSizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: getTitleAndSubDetails(
                                        title: 'statusLbl',
                                        subDetails: bookingModel.status
                                            .toString()
                                            .translate(context: context)
                                            .capitalize(),
                                        isSubtitleBold: true,
                                      ),
                                    ),
                                    if (systemWisePrebooking &&
                                        systemWisePostbooking &&
                                        isPreBookingChat &&
                                        isPostBookingChat)
                                      CustomInkWellContainer(
                                        borderRadius: BorderRadius.circular(5),
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, Routes.chatMessages,
                                              arguments: {
                                                "chatUser": ChatUser(
                                                  id: bookingModel.customerId ??
                                                      "-",
                                                  bookingId: bookingModel.id
                                                      .toString(),
                                                  bookingStatus: bookingModel
                                                      .status
                                                      .toString(),
                                                  name: bookingModel.customer
                                                      .toString(),
                                                  receiverType: "2",
                                                  unReadChats: 0,
                                                  profile:
                                                      bookingModel.profileImage,
                                                  senderId: context
                                                          .read<
                                                              ProviderDetailsCubit>()
                                                          .providerDetails
                                                          .user
                                                          ?.id ??
                                                      "0",
                                                ),
                                              });
                                        },
                                        child: CustomContainer(
                                            height: 36,
                                            width: 36,
                                            borderRadius:
                                                UiUtils.borderRadiusOf5,
                                            padding: const EdgeInsetsDirectional
                                                .symmetric(
                                                horizontal: 10, vertical: 10),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .accentColor
                                                .withValues(alpha: 0.1),
                                            child: CustomSvgPicture(
                                              "dr_chat",
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .accentColor,
                                            )),
                                      ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    CustomInkWellContainer(
                                      borderRadius: BorderRadius.circular(5),
                                      onTap: () {
                                        if (bookingModel.status.toString() ==
                                                "cancelled" ||
                                            bookingModel.status.toString() ==
                                                "completed") {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                content: Text(
                                                    'youCantCallToProviderMessage'
                                                        .translate(
                                                            context: context)),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      'ok'.translate(
                                                          context: context),
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .accentColor),
                                                    ),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          try {
                                            launchUrl(Uri.parse(
                                                "tel:${bookingModel.customerNo}"));
                                          } catch (e) {
                                            UiUtils.showMessage(
                                              context,
                                              message: "somethingWentWrong"
                                                  .translate(context: context),
                                              type: ToastificationType.error,
                                            );
                                          }
                                        }
                                      },
                                      child: CustomContainer(
                                        height: 36,
                                        width: 36,
                                        borderRadius: 5,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .accentColor
                                            .withValues(alpha: 0.1),
                                        child: Icon(
                                          Icons.call,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .accentColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                    if (state.isLoadingMoreBookings)
                      CustomCircularProgressIndicator(
                        color: Theme.of(context).colorScheme.accentColor,
                      )
                  ],
                );
              }

              return const CustomContainer();
            },
          ),
        ),
      ),
    );
  }
}
