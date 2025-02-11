import 'package:edemand_partner/data/model/chat/chatUser.dart';
import 'package:edemand_partner/ui/widgets/bottomSheets/layouts/additionalChargesBottomSheet.dart';
import 'package:edemand_partner/ui/widgets/dialog/layouts/verifyOTPDialog.dart';
import 'package:flutter/material.dart';
import '../../../app/generalImports.dart';
import '../../../utils/checkURLType.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key, required this.bookingsModel});

  final BookingsModel bookingsModel;

  @override
  BookingDetailsState createState() => BookingDetailsState();

  static Route<BookingDetails> route(RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => BookingDetails(
        bookingsModel: arguments['bookingsModel'],
      ),
    );
  }
}

class BookingDetailsState extends State<BookingDetails> {
  ScrollController? scrollController = ScrollController();
  Map<String, String>? currentStatusOfBooking;
  Map<String, String>? temporarySelectedStatusOfBooking;
  int totalServiceQuantity = 0;

  DateTime? selectedRescheduleDate;
  String? selectedRescheduleTime;
  List<Map<String, String>> filters = [];
  List<Map<String, dynamic>>? selectedProofFiles;
  List<Map<String, dynamic>>? additionalCharged;

  @override
  void initState() {
    scrollController!.addListener(() => setState(() {}));
    _getTotalQuantity();
    Future.delayed(Duration.zero, () {
      filters = [
        {
          'value': '1',
          'title': 'awaiting'.translate(context: context),
        },
        {
          'value': '2',
          'title': 'confirmed'.translate(context: context),
        },
        {
          'value': '3',
          'title': 'started'.translate(context: context),
        },
        {'value': '4', 'title': 'rescheduled'.translate(context: context)},
        {
          'value': '5',
          'title': 'booking_ended'.translate(context: context),
        },
        {
          'value': '6',
          'title': 'completed'.translate(context: context),
        },
        {
          'value': '7',
          'title': 'cancelled'.translate(context: context),
        },
      ];
    });
    _getTranslatedInitialStatus();
    super.initState();
  }

  void _getTotalQuantity() {
    widget.bookingsModel.services?.forEach(
      (Services service) {
        totalServiceQuantity += int.parse(service.quantity!);
      },
    );
    setState(
      () {},
    );
  }

  void _getTranslatedInitialStatus() {
    Future.delayed(Duration.zero, () {
      final String? initialStatusValue = getStatusForApi
          .where((Map<String, String> e) =>
              e['title'] == widget.bookingsModel.status)
          .toList()[0]['value'];
      currentStatusOfBooking = filters.where((Map<String, String> element) {
        return element['value'] == initialStatusValue;
      }).toList()[0];

      setState(() {});
    });
  }

// Don't translate this because we need to send this title in api;
  List<Map<String, String>> getStatusForApi = [
    {'value': '1', 'title': 'awaiting'},
    {'value': '2', 'title': 'confirmed'},
    {'value': '3', 'title': 'started'},
    {'value': '4', 'title': 'rescheduled'},
    {'value': '5', 'title': 'booking_ended'},
    {'value': '6', 'title': 'completed'},
    {'value': '7', 'title': 'cancelled'},
  ];

  Future<void> _onDropDownClick(List<Map<String, String>> filters) async {
    //get current status of booking
    if (widget.bookingsModel.status != null &&
        temporarySelectedStatusOfBooking == null) {
      currentStatusOfBooking = getStatusForApi
          .where((Map<String, String> e) =>
              e['title'] == widget.bookingsModel.status)
          .toList()[0];
    } else {
      currentStatusOfBooking = temporarySelectedStatusOfBooking;
    }

    //show bottomSheet to select new status
    var selectedStatusOfBooking = await UiUtils.showModelBottomSheets(
      context: context,
      child: UpdateStatusBottomSheet(
        selectedItem: currentStatusOfBooking!,
        itemValues: [...filters],
      ),
    );

    if (selectedStatusOfBooking?['selectedStatus'] != null) {
      //
      //if selectedStatus is started then show uploadFiles bottomSheet
      if (selectedStatusOfBooking['selectedStatus']['title'] ==
          'started'.translate(context: context)) {
        UiUtils.showModelBottomSheets(
          context: context,
          child: UploadProofBottomSheet(preSelectedFiles: selectedProofFiles),
        ).then((value) {
          selectedProofFiles = value;
          setState(() {});
        });
      }
      //
      //if selectedStatus is booking_ended then show uploadFiles bottomSheet
      if (selectedStatusOfBooking['selectedStatus']['title'] ==
          'booking_ended'.translate(context: context)) {
        //
        await UiUtils.showModelBottomSheets(
          context: context,
          child: UploadProofBottomSheet(preSelectedFiles: selectedProofFiles),
        ).then((value) {
          selectedProofFiles = value;
          setState(() {});
        });

        await UiUtils.showModelBottomSheets(
          context: context,
          child: AdditionalChargesBottomSheet(
            additionalCharges:
                additionalCharged, // pass any preselected charges if needed
          ),
        ).then((charges) {
          additionalCharged = charges;
          setState(() {}); // Update state after additional charges are set
        });
      } else {
        temporarySelectedStatusOfBooking =
            selectedStatusOfBooking['selectedStatus'];
        currentStatusOfBooking = selectedStatusOfBooking['selectedStatus'];
      }

      //if OTP validation is required then show OTP dialog
      if (currentStatusOfBooking?['title'] ==
              'completed'.translate(context: context) &&
          context
              .read<FetchSystemSettingsCubit>()
              .isOrderOTPVerificationEnable()) {
        UiUtils.showAnimatedDialog(
          context: context,
          child: VerifyOTPDialog(
            otp: widget.bookingsModel.otp ?? '0',
            confirmButtonPressed: () {
              Navigator.pop(context);
              temporarySelectedStatusOfBooking =
                  selectedStatusOfBooking['selectedStatus'];
              currentStatusOfBooking =
                  selectedStatusOfBooking['selectedStatus'];
              setState(() {});
            },
          ),
        );
      } else if (currentStatusOfBooking?['title'] ==
              'completed'.translate(context: context) &&
          context
              .read<FetchSystemSettingsCubit>()
              .isOrderOTPVerificationEnable() &&
          widget.bookingsModel.paymentMethod == "cod") {
        UiUtils.showAnimatedDialog(
            context: context,
            child: CustomDialogLayout(
              title: "collectCashFromCustomer",
              confirmButtonName: "okay",
              cancelButtonName: "cancel",
              confirmButtonBackgroundColor:
                  Theme.of(context).colorScheme.accentColor,
              cancelButtonBackgroundColor:
                  Theme.of(context).colorScheme.secondaryColor,
              showProgressIndicator: false,
              cancelButtonPressed: () {
                Navigator.pop(context);
              },
              confirmButtonPressed: () {
                Navigator.pop(context);
                temporarySelectedStatusOfBooking =
                    selectedStatusOfBooking['selectedStatus'];
                currentStatusOfBooking =
                    selectedStatusOfBooking['selectedStatus'];
                setState(() {});
              },
            ));
      } else if (currentStatusOfBooking?['title'] ==
              'completed'.translate(context: context) &&
          context
                  .read<FetchSystemSettingsCubit>()
                  .isOrderOTPVerificationEnable() ==
              false &&
          widget.bookingsModel.paymentMethod == "cod") {
        UiUtils.showAnimatedDialog(
            context: context,
            child: CustomDialogLayout(
              title: "collectdCash",
              confirmButtonName: "okay",
              cancelButtonName: "cancel",
              confirmButtonBackgroundColor:
                  Theme.of(context).colorScheme.accentColor,
              cancelButtonBackgroundColor:
                  Theme.of(context).colorScheme.secondaryColor,
              showProgressIndicator: false,
              cancelButtonPressed: () {
                Navigator.pop(context);
              },
              confirmButtonPressed: () {
                Navigator.pop(context);
                temporarySelectedStatusOfBooking =
                    selectedStatusOfBooking['selectedStatus'];
                currentStatusOfBooking =
                    selectedStatusOfBooking['selectedStatus'];
                setState(() {});
              },
            ));
      } else {
        temporarySelectedStatusOfBooking =
            selectedStatusOfBooking['selectedStatus'];
        currentStatusOfBooking = selectedStatusOfBooking['selectedStatus'];
      }

      //
      //if selectedStatus is reschedule then show select new date and time bottomSheet
      if (selectedStatusOfBooking['selectedStatus']['title'] ==
          'rescheduled'.translate(context: context)) {
        final Map? result = await UiUtils.showModelBottomSheets(
            context: context,
            isScrollControlled: true,
            enableDrag: true,
            child: CustomContainer(
              height: MediaQuery.sizeOf(context).height * 0.7,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(UiUtils.borderRadiusOf20),
                  topLeft: Radius.circular(UiUtils.borderRadiusOf20),
                ),
              ),
              child: CalenderBottomSheet(
                  advanceBookingDays: widget.bookingsModel.advanceBookingDays!),
            ));

        selectedRescheduleDate = result?['selectedDate'];
        selectedRescheduleTime = result?['selectedTime'];

        if (selectedRescheduleDate == null || selectedRescheduleTime == null) {
          selectedStatusOfBooking = getStatusForApi[0];
          temporarySelectedStatusOfBooking = getStatusForApi[0];
          currentStatusOfBooking = getStatusForApi[0];
          setState(() {});
        }
      } else {
        //reset the values if choose different one
        selectedRescheduleDate = null;
        selectedRescheduleTime = null;
      }
    }
    setState(() {});
  }

  Future getOTPDialog(
      {required String otp, required VoidCallback onOTPConfirmed}) async {
    final TextEditingController otpController = TextEditingController();
    final GlobalKey<FormState> otpFormKey = GlobalKey();
    //

    final AlertDialog data = CustomDialogs.showTextFieldDialog(
      context,
      formKey: otpFormKey,
      controller: otpController,
      textInputType: TextInputType.number,
      title: 'otp'.translate(context: context),
      hintText: 'enterOTP'.translate(context: context),
      message: 'pleaseEnterOTPGivenByCustomer'.translate(context: context),
      showProgress: false,
      confirmButtonColor: Theme.of(context).colorScheme.accentColor,
      validator: (String value) {
        if (value.trim().isEmpty) {
          return 'pleaseEnterOTP';
        }
        if (value.trim() != otp || value.trim() == '0') {
          return 'invalidOTP';
        }
      },
      onCancled: () {
        Navigator.pop(context);
      },
      onConfirmed: onOTPConfirmed,
    );
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return data;
      },
    ).then((value) => null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.watch<UpdateBookingStatusCubit>().state
          is! UpdateBookingStatusInProgress,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        appBar: AppBar(
          surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
          backgroundColor: Theme.of(context).colorScheme.secondaryColor,
          elevation: 1,
          centerTitle: true,
          leading: CustomBackArrow(
            canGoBack: context.watch<UpdateBookingStatusCubit>().state
                is! UpdateBookingStatusInProgress,
          ),
          title: Text(
            'bookingDetails'.translate(context: context),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.blackColor,
            ),
          ),
        ),

        body: mainWidget(), //mainWidget(),

        bottomNavigationBar: bottomBarWidget(),
      ),
    );
  }

  Widget onMapsBtn() {
    return CustomInkWellContainer(
      onTap: () async {
        try {
          await launchUrl(
            Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=${widget.bookingsModel.latitude},${widget.bookingsModel.longitude}',
            ),
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          UiUtils.showMessage(
            context,
            message: 'somethingWentWrong'.translate(context: context),
            type: ToastificationType.error,
          );
        }
      },
      child: CustomContainer(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.accentColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
        ),
        child: Text(
          'onMapsLbl'.translate(context: context),
          style: TextStyle(color: Theme.of(context).colorScheme.accentColor),
        ),
      ),
    );
  }

  Widget bottomBarWidget() {
    return BlocConsumer<UpdateBookingStatusCubit, UpdateBookingStatusState>(
      listener: (BuildContext context, UpdateBookingStatusState state) {
        if (state is UpdateBookingStatusFailure) {
          UiUtils.showMessage(context,
              message: state.errorMessage.translate(context: context),
              type: ToastificationType.error);
        }
        if (state is UpdateBookingStatusSuccess) {
          if (state.error == 'true') {
            //
            UiUtils.showMessage(
              context,
              message: state.message.translate(context: context),
              type: ToastificationType.error,
            );
            setState(() {
              selectedProofFiles = [];
              additionalCharged = [];
            });
            return;
          }
          //
          context.read<FetchBookingsCubit>().updateBookingDetailsLocally(
                bookingID: state.orderId.toString(),
                bookingStatus: state.status,
                listOfUploadedImages: state.imagesList,
              );

          UiUtils.showMessage(
            context,
            message: 'updatedSuccessfully'.translate(context: context),
            type: ToastificationType.success,
          );
        }
      },
      builder: (BuildContext context, UpdateBookingStatusState state) {
        Widget? child;
        if (state is UpdateBookingStatusInProgress) {
          child = CustomCircularProgressIndicator(
            color: AppColors.whiteColors,
          );
        }
        return CustomContainer(
          color: Theme.of(context).colorScheme.secondaryColor,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 15, vertical: 10),
            child: CustomSizedBox(
              width: MediaQuery.sizeOf(context).width / 2,
              height: (selectedRescheduleDate == null ||
                      selectedRescheduleTime == null)
                  ? 50
                  : 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedRescheduleDate != null &&
                      selectedRescheduleTime != null) ...[
                    CustomSizedBox(
                      height: 70,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'selectedDate'.translate(context: context),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(selectedRescheduleDate
                                    .toString()
                                    .split(' ')[0])
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'selectedTime'.translate(context: context),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(selectedRescheduleTime ?? '')
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: CustomFormDropdown(
                            initialTitle: currentStatusOfBooking?['title']
                                    .toString()
                                    .capitalize() ??
                                widget.bookingsModel.status
                                    .toString()
                                    .capitalize(),
                            selectedValue: currentStatusOfBooking?['title'],
                            onTap: () {
                              _onDropDownClick(filters);
                            },
                          ),
                        ),
                        const CustomSizedBox(
                          width: 8,
                        ),
                        Expanded(
                          flex: 3,
                          child: CustomRoundedButton(
                            showBorder: false,
                            buttonTitle: 'update'.translate(context: context),
                            backgroundColor:
                                Theme.of(context).colorScheme.accentColor,
                            widthPercentage: 1,
                            height: 50,
                            textSize: 14,
                            child: child,
                            onTap: () {
                              if (state is UpdateBookingStatusInProgress) {
                                return;
                              }
                              Map<String, String>? bookingStatus;
                              //
                              final List<Map<String, String>>
                                  selectedBookingStatus = getStatusForApi.where(
                                (Map<String, String> element) {
                                  return element['value'] ==
                                      currentStatusOfBooking?['value'];
                                },
                              ).toList();

                              if (selectedBookingStatus.isNotEmpty) {
                                bookingStatus = selectedBookingStatus[0];
                              }

                              context
                                  .read<UpdateBookingStatusCubit>()
                                  .updateBookingStatus(
                                      orderId:
                                          int.parse(widget.bookingsModel.id!),
                                      customerId: int.parse(
                                          widget.bookingsModel.customerId!),
                                      status: bookingStatus?['title'] ??
                                          widget.bookingsModel.status!,
                                      //OTP validation applied locally, so status is completed then OTP verified already, so directly passing the OTP
                                      otp: widget.bookingsModel.otp ?? '',
                                      date: selectedRescheduleDate
                                          .toString()
                                          .split(' ')[0],
                                      time: selectedRescheduleTime,
                                      proofData: selectedProofFiles,
                                      additionalCharges: additionalCharged);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget mainWidget() {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customerInfoWidget(),
          bookingDateAndTimeWidget(),
          Visibility(
            visible: widget.bookingsModel.workStartedProof!.isNotEmpty,
            child: uploadedProofWidget(
              title: 'workStartedProof',
              proofData: widget.bookingsModel.workStartedProof!,
            ),
          ),
          Visibility(
            visible: widget.bookingsModel.workCompletedProof!.isNotEmpty,
            child: uploadedProofWidget(
              title: 'workCompletedProof',
              proofData: widget.bookingsModel.workCompletedProof!,
            ),
          ),
          bookingDetailsWidget(),
          notesWidget(),
          serviceDetailsWidget(),
          pricingWidget()
        ],
      ),
    );
  }

  Widget getTitleAndSubDetails({
    required String title,
    required String subDetails,
    Color? subTitleBackgroundColor,
    Color? subTitleColor,
    double? width,
    Function()? onTap,
  }) {
    return CustomInkWellContainer(
      onTap: () {
        onTap?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (title != '') ...[
            CustomText(
              title.translate(context: context),
              fontSize: 14,
              maxLines: 2,
              color: Theme.of(context).colorScheme.lightGreyColor,
            ),
            const CustomSizedBox(
              height: 5,
            ),
          ],
          CustomContainer(
            width: width,
            decoration: BoxDecoration(
              color: subTitleBackgroundColor?.withValues(alpha: 0.2) ??
                  Colors.transparent,
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
            ),
            child: CustomText(
              subDetails,
              fontSize: 14,
              maxLines: 2,
              color: subTitleColor ?? Theme.of(context).colorScheme.blackColor,
            ),
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
            color: subTitleBackgroundColor?.withValues(alpha: 0.2) ??
                Colors.transparent,
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
          ),
          padding: const EdgeInsets.all(5),
          child: CustomText(
            subDetails,
            fontSize: 14,
            maxLines: 2,
            color: subTitleColor ?? Theme.of(context).colorScheme.blackColor,
          ),
        ),
      ],
    );
  }

  Widget showDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Theme.of(context).colorScheme.lightGreyColor,
    );
  }

  Widget getTitle({
    required String title,
    String? subTitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title.translate(context: context),
          maxLines: 1,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Theme.of(context).colorScheme.blackColor,
        ),
        if (subTitle != null) ...[
          const CustomSizedBox(
            height: 5,
          ),
          CustomText(
            subTitle.translate(context: context),
            maxLines: 1,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Theme.of(context).colorScheme.lightGreyColor,
          )
        ]
      ],
    );
  }

  Widget customerInfoWidget() {
    return CustomContainer(
      borderRadius: 0,
      //padding: const EdgeInsets.only(top: 15),
      color: Theme.of(context).colorScheme.secondaryColor,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: getTitle(title: 'customerDetails'),
          ),
          showDivider(),
          const CustomSizedBox(
            height: 10,
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomContainer(
                          height: 60,
                          width: 60,
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(UiUtils.borderRadiusOf50),
                            child: CustomCachedNetworkImage(
                              imageUrl: widget.bookingsModel.profileImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const CustomSizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                widget.bookingsModel.customer ?? '',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.blackColor,
                              ),
                              _buildTitleAndValueRowWidget(
                                title: "mobileNumber",
                                value: widget.bookingsModel.customerNo ?? '',
                                onTap: () {
                                  try {
                                    launchUrl(Uri.parse(
                                        "tel:${widget.bookingsModel.customerNo}"));
                                  } catch (e) {
                                    UiUtils.showMessage(context,
                                        message: "somethingWentWrong"
                                            .translate(context: context),
                                        type: ToastificationType.error);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const CustomSizedBox(
                          width: 15,
                        ),
                        CustomInkWellContainer(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () {
                            Navigator.pushNamed(context, Routes.chatMessages,
                                arguments: {
                                  "chatUser": ChatUser(
                                    id: widget.bookingsModel.customerId ?? "-",
                                    bookingId:
                                        widget.bookingsModel.id.toString(),
                                    bookingStatus:
                                        widget.bookingsModel.status.toString(),
                                    name: widget.bookingsModel.customer
                                        .toString(),
                                    receiverType: "2",
                                    unReadChats: 0,
                                    profile: widget.bookingsModel.profileImage,
                                    senderId: context
                                            .read<ProviderDetailsCubit>()
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
                              borderRadius: UiUtils.borderRadiusOf5,
                              padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 10, vertical: 10),
                              color: Theme.of(context)
                                  .colorScheme
                                  .accentColor
                                  .withValues(alpha: 0.1),
                              child: CustomSvgPicture(
                                "dr_chat",
                                color:
                                    Theme.of(context).colorScheme.accentColor,
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        CustomInkWellContainer(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () {
                            if (widget.bookingsModel.status.toString() ==
                                    "cancelled" ||
                                widget.bookingsModel.status.toString() ==
                                    "completed") {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Text('youCantCallToProviderMessage'
                                        .translate(context: context)),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'ok'.translate(context: context),
                                          style: TextStyle(
                                              color: Theme.of(context)
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
                                    "tel:${widget.bookingsModel.customerNo}"));
                              } catch (e) {
                                UiUtils.showMessage(context,
                                    message: "somethingWentWrong"
                                        .translate(context: context),
                                    type: ToastificationType.error);
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
                            child: Icon(Icons.call,
                                color:
                                    Theme.of(context).colorScheme.accentColor),
                          ),
                        ),
                      ],
                    ),
                    const CustomSizedBox(height: 16),
                    _buildTitleAndValueRowWidget(
                      title: "email",
                      value: widget.bookingsModel.customerEmail ?? '',
                      onTap: () {
                        try {
                          launchUrl(Uri.parse(
                              "mailto:${widget.bookingsModel.customerEmail}"));
                        } catch (e) {
                          UiUtils.showMessage(context,
                              message: "somethingWentWrong"
                                  .translate(context: context),
                              type: ToastificationType.error);
                        }
                      },
                    ),
                    if (widget.bookingsModel.addressId != "0") ...[
                      const CustomSizedBox(height: 10),
                      _buildTitleAndValueRowWidget(
                        title: "addressLbl",
                        value: (widget.bookingsModel.address ?? '')
                            .removeExtraComma(),
                        onTap: () {
                          try {
                            launchUrl(
                                Uri.parse(
                                    'https://www.google.com/maps/search/?api=1&query=${widget.bookingsModel.latitude},${widget.bookingsModel.longitude}'),
                                mode: LaunchMode.externalApplication);
                          } catch (e) {
                            UiUtils.showMessage(context,
                                message: "somethingWentWrong"
                                    .translate(context: context),
                                type: ToastificationType.error);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const CustomSizedBox(
                height: 10,
              ),
              showDivider(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndValueRowWidget({
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return CustomInkWellContainer(
      onTap: onTap,
      child: Row(
        children: [
          CustomText(
            "${title.translate(context: context)}:",
            fontSize: 14,
          ),
          Expanded(
            child: CustomText(
              value,
              color: context.colorScheme.blackColor,
              fontSize: 14,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget bookingDateAndTimeWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: getTitle(
                  title: 'bookingDateAndTime',
                  subTitle: widget.bookingsModel.multipleDaysBooking!.isNotEmpty
                      ? 'bookingScheduledForMultipleDays'
                      : null,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: getTitleAndSubDetails(
                      title: 'serviceDate'.translate(context: context),
                      subDetails: (widget.bookingsModel.dateOfService ?? '')
                          .formatDate(),
                    ),
                  ),
                  Expanded(
                    child: getTitleAndSubDetails(
                      title: 'starting'.translate(context: context),
                      subDetails: (widget.bookingsModel.startingTime ?? '')
                          .formatTime(),
                    ),
                  ),
                  Expanded(
                    child: getTitleAndSubDetails(
                      title: 'ending'.translate(context: context),
                      subDetails:
                          (widget.bookingsModel.endingTime ?? '').formatTime(),
                    ),
                  ),
                ],
              ),
              if (widget.bookingsModel.multipleDaysBooking!.isNotEmpty) ...[
                for (int i = 0;
                    i < widget.bookingsModel.multipleDaysBooking!.length;
                    i++) ...{
                  Row(
                    children: [
                      Expanded(
                        child: getTitleAndSubDetails(
                          title: '',
                          subDetails: (widget
                                      .bookingsModel
                                      .multipleDaysBooking![i]
                                      .multipleDayDateOfService ??
                                  '')
                              .formatDate(),
                        ),
                      ),
                      Expanded(
                        child: getTitleAndSubDetails(
                          title: '',
                          subDetails: (widget
                                      .bookingsModel
                                      .multipleDaysBooking![i]
                                      .multipleDayStartingTime ??
                                  '')
                              .formatTime(),
                        ),
                      ),
                      Expanded(
                        child: getTitleAndSubDetails(
                          title: '',
                          subDetails: (widget
                                      .bookingsModel
                                      .multipleDaysBooking![i]
                                      .multipleEndingTime ??
                                  '')
                              .formatTime(),
                        ),
                      ),
                    ],
                  ),
                }
              ]
            ],
          ),
        ),
        const CustomSizedBox(
          height: 10,
        ),
        showDivider(),
      ],
    );
  }

  Widget uploadedProofWidget(
      {required String title, required List<dynamic> proofData}) {
    return CustomContainer(
      borderRadius: UiUtils.borderRadiusOf10,
      color: Theme.of(context).colorScheme.secondaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getTitle(title: title.translate(context: context)),
                const CustomSizedBox(
                  height: 10,
                ),
                Row(
                  children: List.generate(proofData.length, (int index) {
                    return CustomContainer(
                      height: 50,
                      width: 50,
                      margin: const EdgeInsetsDirectional.only(end: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color:
                                Theme.of(context).colorScheme.lightGreyColor),
                      ),
                      child: CustomInkWellContainer(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.imagePreviewScreen,
                            arguments: {
                              'startFrom': index,
                              'isReviewType': false,
                              'dataURL': proofData
                            },
                          ).then(
                            (Object? value) {
                              //locked in portrait mode only
                              SystemChrome.setPreferredOrientations(
                                [
                                  DeviceOrientation.portraitUp,
                                  DeviceOrientation.portraitDown
                                ],
                              );
                            },
                          );
                        },
                        child: UrlTypeHelper.getType(proofData[index]) ==
                                UrlType.image
                            ? CustomCachedNetworkImage(
                                imageUrl: proofData[index],
                                height: 50,
                                width: 50,
                              )
                            : UrlTypeHelper.getType(proofData[index]) ==
                                    UrlType.video
                                ? Center(
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .accentColor,
                                    ),
                                  )
                                : const CustomContainer(),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          showDivider(),
        ],
      ),
    );
  }

  Widget bookingDetailsWidget() {
    return CustomContainer(
      color: Theme.of(context).colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getTitle(
                    title: 'bookingDetailsLbl'.translate(context: context)),
                const CustomSizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: getTitleAndSubDetails(
                        title: 'invoiceNumber',
                        subDetails: widget.bookingsModel.invoiceNo ?? '',
                      ),
                    ),
                    Expanded(
                      child: getTitleAndSubDetails(
                        title: 'serviceBookedAt'.translate(context: context),
                        subDetails: widget.bookingsModel.addressId == "0"
                            ? 'atStore'.translate(context: context)
                            : "atDoorstep".translate(context: context),
                      ),
                    ),
                  ],
                ),
                const CustomSizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return CustomSizedBox(
                            width: constraints.maxWidth,
                            child: getTitleAndSubDetailsWithBackgroundColor(
                              title: 'statusLbl',
                              subDetails: widget.bookingsModel.status
                                  .toString()
                                  .translate(context: context)
                                  .capitalize(),
                              subTitleBackgroundColor: UiUtils.getStatusColor(
                                      context: context,
                                      statusVal: widget.bookingsModel.status
                                          .toString())
                                  .withValues(alpha: 0.2),
                              subTitleColor: UiUtils.getStatusColor(
                                  context: context,
                                  statusVal:
                                      widget.bookingsModel.status.toString()),
                              width: constraints.maxWidth - 10,
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return getTitleAndSubDetailsWithBackgroundColor(
                            title: 'paymentMethodLbl',
                            subDetails: widget.bookingsModel.paymentMethod
                                .toString()
                                .translate(context: context)
                                .capitalize(),
                            subTitleBackgroundColor:
                                Theme.of(context).colorScheme.accentColor,
                            subTitleColor:
                                Theme.of(context).colorScheme.accentColor,
                            width: constraints.maxWidth,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          showDivider(),
        ],
      ),
    );
  }

  Widget serviceDetailsWidget() {
    return CustomContainer(
      color: Theme.of(context).colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getTitle(title: 'serviceDetailsLbl'),
                const CustomSizedBox(
                  height: 10,
                ),
                for (Services service in widget.bookingsModel.services!) ...[
                  setServiceRowValues(
                    title: service.serviceTitle!,
                    quantity: service.quantity!,
                    price: service.discountPrice != "0"
                        ? service.discountPrice!
                        : service.price!,
                  ),
                  const CustomSizedBox(
                    height: 5,
                  ),
                  if (widget.bookingsModel.additionalCharges!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getTitle(title: 'additionalServiceChargesDetailsLbl'),
                          const CustomSizedBox(
                            height: 10,
                          ),
                          for (int i = 0;
                              i <
                                  widget
                                      .bookingsModel.additionalCharges!.length;
                              i++) ...[
                            setServiceRowValues(
                              title: widget.bookingsModel.additionalCharges![i]
                                  ["name"],
                              quantity: "",
                              price: widget.bookingsModel.additionalCharges![i]
                                  ["charge"],
                            ),
                            // const CustomSizedBox(
                            //   height: 5,
                            // )
                          ],
                          // const CustomDivider(),
                          // setServiceRowValues(
                          //   title: 'totalPriceLbl'.translate(context: context),
                          //   quantity: "" /*totalServiceQuantity.toString()*/,
                          //   isTitleBold: true,
                          //   price: double.parse(widget
                          //           .bookingsModel.totalAdditionalCharges!
                          //           .toString()
                          //           .replaceAll(",", ""))
                          //       .toString(),
                          // ),
                          // const CustomSizedBox(
                          //   height: 10,
                          // )
                        ],
                      ),
                    ),
                ],
                // const CustomDivider(),
                // setServiceRowValues(
                //   title: 'totalPriceLbl'.translate(context: context),
                //   quantity: "" /*totalServiceQuantity.toString()*/,
                //   isTitleBold: true,
                //   price: (double.parse(widget.bookingsModel.total!
                //               .toString()
                //               .replaceAll(",", "")) -
                //           double.parse(
                //             widget.bookingsModel.taxAmount!
                //                 .toString()
                //                 .replaceAll(",", ""),
                //           ))
                //       .toString(),
                // ),
                // const CustomSizedBox(
                //   height: 10,
                // ),
              ],
            ),
          ),
          showDivider()
        ],
      ),
    );
  }

  Widget setServiceRowValues({
    required String title,
    required String quantity,
    required String price,
    String? pricePrefix,
    bool? isTitleBold,
    FontWeight? priceFontWeight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: CustomText(
            title,
            fontSize: 14,
            fontWeight: (isTitleBold ?? false)
                ? FontWeight.bold
                : ((title != 'serviceDetailsLbl'.translate(context: context))
                    ? FontWeight.w400
                    : FontWeight.w700),
            color: Theme.of(context).colorScheme.blackColor,
          ),
        ),
        if (quantity != '')
          Expanded(
            child: CustomText(
              (title == 'totalPriceLbl'.translate(context: context) ||
                      title ==
                          'totalServicePriceLbl'.translate(context: context))
                  ? "${"totalQtyLbl".translate(context: context)} $quantity"
                  : (title == 'gstLbl'.translate(context: context) ||
                          title == 'taxLbl'.translate(context: context))
                      ? quantity.formatPercentage()
                      : (title == 'couponDiscLbl'.translate(context: context))
                          ? "${quantity.formatPercentage()} ${"offLbl".translate(context: context)}"
                          : "${"qtyLbl".translate(context: context)} $quantity",
              fontSize: 14,
              textAlign: TextAlign.end,
              color: Theme.of(context).colorScheme.lightGreyColor,
            ),
          )
        else
          const CustomSizedBox(),
        if (price != '')
          Expanded(
            child: CustomText(
              pricePrefix != null
                  ? "$pricePrefix ${price.replaceAll(',', '').priceFormat()}"
                  : price.replaceAll(',', '').priceFormat(),
              textAlign: TextAlign.end,
              fontSize: (title == 'totalPriceLbl'.translate(context: context))
                  ? 14
                  : 14,
              fontWeight: priceFontWeight ?? FontWeight.w500,
              color: Theme.of(context).colorScheme.blackColor,
            ),
          )
        else
          const CustomSizedBox()
      ],
    );
  }

  Widget notesWidget() {
    if (widget.bookingsModel.remarks == '') {
      return const CustomSizedBox(
        height: 10,
      );
    }
    return Column(
      children: [
        CustomContainer(
          borderRadius: UiUtils.borderRadiusOf10,
          color: Theme.of(context).colorScheme.secondaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: getTitle(title: 'notesLbl'),
                    ),
                    CustomText(
                      widget.bookingsModel.remarks ?? '',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.lightGreyColor,
                    ),
                    const CustomSizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
              showDivider()
            ],
          ),
        ),
        const CustomSizedBox(height: 15.0),
      ],
    );
  }

  Widget pricingWidget() {
    return CustomContainer(
      color: Theme.of(context).colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getTitle(title: 'pricingLbl'),
            const CustomSizedBox(height: 10),
            setServiceRowValues(
              title: 'totalServiceChargesLbl'.translate(context: context),
              quantity: "" /*totalServiceQuantity.toString()*/,
              price: (double.parse(widget.bookingsModel.total!
                          .toString()
                          .replaceAll(",", "")) -
                      double.parse(
                        widget.bookingsModel.taxAmount!
                            .toString()
                            .replaceAll(",", ""),
                      ))
                  .toString(),
            ),
            const CustomSizedBox(height: 5),
            if (widget.bookingsModel.totalAdditionalCharges != null)
              setServiceRowValues(
                title: 'totalAdditionServiceChargesLbl'
                    .translate(context: context),
                quantity: "" /*totalServiceQuantity.toString()*/,
                price: double.parse(widget.bookingsModel.totalAdditionalCharges!
                        .toString()
                        .replaceAll(",", ""))
                    .toString(),
              ),
            if (widget.bookingsModel.promoDiscount != '0') ...[
              const CustomSizedBox(height: 5),
              setServiceRowValues(
                title: 'couponDiscLbl'.translate(context: context),
                pricePrefix: "-",
                quantity: "",
                /*widget.bookingsModel.promoCode == '' ? '--' : widget.bookingsModel.promoCode!,*/
                price: widget.bookingsModel.promoDiscount!,
              ),
            ],
            if (widget.bookingsModel.taxAmount != '' &&
                widget.bookingsModel.taxAmount != null &&
                widget.bookingsModel.taxAmount != "0" &&
                widget.bookingsModel.taxAmount != "0.00")
              setServiceRowValues(
                  title: "taxLbl".translate(context: context),
                  price: widget.bookingsModel.taxAmount.toString(),
                  quantity: "",
                  pricePrefix: "+"),
            const CustomSizedBox(height: 5),
            if (widget.bookingsModel.visitingCharges != "0")
              setServiceRowValues(
                  title: 'visitingCharge'.translate(context: context),
                  quantity: '',
                  price: widget.bookingsModel.visitingCharges!,
                  pricePrefix: "+"),
            const CustomSizedBox(height: 5),
            const CustomDivider(),
            setServiceRowValues(
              title: 'totalAmtLbl'.translate(context: context),
              quantity: '',
              isTitleBold: true,
              priceFontWeight: FontWeight.bold,
              price: widget.bookingsModel.finalTotal!,
            ),
          ],
        ),
      ),
    );
  }
}
