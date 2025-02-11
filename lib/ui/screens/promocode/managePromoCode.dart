import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/generalImports.dart';

class ManagePromocode extends StatefulWidget {
  const ManagePromocode({super.key, this.promocode});

  final PromocodeModel? promocode;

  @override
  ManagePromocodeState createState() => ManagePromocodeState();

  static Route<ManagePromocode> route(RouteSettings routeSettings) {
    final Map? arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => ManagePromocode(promocode: arguments?['promocode']),
    );
  }
}

class ManagePromocodeState extends State<ManagePromocode> {
  int currIndex = 1;
  int totalForms = 2;

  //form 1
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  Map? selectedDiscountType;
  ScrollController scrollController = ScrollController();
  late String? selectedStartDate =
          widget.promocode?.startDate?.split(" ").first,
      selectedEndDate = widget.promocode?.endDate?.split(" ").first;

  //
  late TextEditingController promocodeController =
      TextEditingController(text: widget.promocode?.promoCode);
  late TextEditingController startDtController = TextEditingController(
      text: widget.promocode?.startDate
          ?.split(" ")
          .first
          .toString()
          .formatDate());
  late TextEditingController endDtController = TextEditingController(
      text:
          widget.promocode?.endDate?.split(" ").first.toString().formatDate());
  late TextEditingController noOfUserController =
      TextEditingController(text: widget.promocode?.noOfUsers);
  late TextEditingController minOrderAmtController =
      TextEditingController(text: widget.promocode?.minimumOrderAmount);
  late TextEditingController discountController =
      TextEditingController(text: widget.promocode?.discount);
  late TextEditingController discountTypeController = TextEditingController(
      text: widget.promocode?.discountType
          .toString()
          .translate(context: context));
  late TextEditingController noOfRepeatUsageController =
      TextEditingController(text: widget.promocode?.noOfRepeatUsage);
  FocusNode promocodeFocus = FocusNode();
  FocusNode startDtFocus = FocusNode();
  FocusNode endDtFocus = FocusNode();
  FocusNode noOfUserFocus = FocusNode();
  FocusNode minOrderAmtFocus = FocusNode();
  FocusNode discountFocus = FocusNode();
  FocusNode discountTypeFocus = FocusNode();
  FocusNode maxDiscFocus = FocusNode();
  FocusNode messageFocus = FocusNode();
  FocusNode noOfRepeatUsage = FocusNode();
  PickImage pickImage = PickImage();

  bool isStatus = false;
  bool isRepeatUsage = false;

  late TextEditingController maxDiscController =
      TextEditingController(text: widget.promocode?.maxDiscountAmount);
  late TextEditingController messageController =
      TextEditingController(text: widget.promocode?.message);

  List<Map> discountTypesFilter = [];

  @override
  void dispose() {
    promocodeController.dispose();
    startDtController.dispose();
    endDtController.dispose();
    noOfUserController.dispose();
    minOrderAmtController.dispose();
    discountController.dispose();
    discountTypeController.dispose();
    noOfRepeatUsageController.dispose();
    promocodeFocus.dispose();
    endDtFocus.dispose();
    noOfUserFocus.dispose();
    minOrderAmtFocus.dispose();
    discountFocus.dispose();
    discountTypeFocus.dispose();
    maxDiscFocus.dispose();
    messageFocus.dispose();
    noOfRepeatUsage.dispose();
    pickImage.dispose();
    maxDiscController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _chooseImage() {
    pickImage.pick();
  }

  void onAddPromoCode() {
    UiUtils.removeFocus();
    final FormState? form = formKey1.currentState; //default value
    if (form == null) return;
    //
    form.save();
    //
    if (form.validate()) {
      if (pickImage.pickedFile != null || widget.promocode?.image != null) {
        //need to add more field in create promocode model
        final CreatePromocodeModel createPromocode = CreatePromocodeModel(
          promo_id: widget.promocode?.id,
          promoCode: promocodeController.text,
          startDate: selectedStartDate.toString(),
          endDate: selectedEndDate.toString(),
          minimumOrderAmount: minOrderAmtController.text,
          discountType: selectedDiscountType?['value'],
          discount: discountController.text,
          maxDiscountAmount: maxDiscController.text,
          message: messageController.text,
          repeat_usage: isRepeatUsage ? '1' : '0',
          status: isStatus ? "1" : '0',
          no_of_users: noOfUserController.text,
          no_of_repeat_usage: noOfRepeatUsageController.text,
          image: pickImage.pickedFile,
        );

        //
        if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable()) {
          UiUtils.showDemoModeWarning(context: context);
          return;
        }
        //
        context.read<CreatePromocodeCubit>().createPromocode(
              createPromocode,
            );
      } else {
        FocusScope.of(context).unfocus();

        //show if image is not picked
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('imageRequired'.translate(context: context)),
              content: Text('pleaseSelectImage'.translate(context: context)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('ok'.translate(context: context)),
                )
              ],
            );
          },
        );
      }
    }
  }

  @override
  void initState() {
    if (widget.promocode?.status != null) {
      if (widget.promocode?.status == '0') {
        isStatus = false;
      } else {
        isStatus = true;
      }
    }
    if (widget.promocode?.repeatUsage != null) {
      if (widget.promocode?.repeatUsage == '0') {
        isRepeatUsage = false;
      } else {
        isRepeatUsage = true;
      }
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    discountTypesFilter = [
      {
        'value': 'percentage',
        'title': 'percentage'.translate(context: context)
      },
      {'value': 'amount', 'title': 'amount'.translate(context: context)}
    ];

    if (widget.promocode?.discountType != null) {
      selectedDiscountType = discountTypesFilter
          .where((Map element) =>
              element['value'] == widget.promocode?.discountType)
          .toList()[0];
    }

    super.didChangeDependencies();
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
          widget.promocode?.id != null
              ? 'editPromoCodeTitleLbl'.translate(context: context)
              : 'addPromoCodeTitleLbl'.translate(context: context),
          color: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.bold,
        ),
        leading: const CustomBackArrow(),
      ),
      body: BlocListener<CreatePromocodeCubit, CreatePromocodeState>(
        listener: (BuildContext context, CreatePromocodeState state) {
          if (state is CreatePromocodeFailure) {
            UiUtils.showMessage(context,
                message: state.errorMessage.translate(context: context),
                type: ToastificationType.error);
          }
          if (state is CreatePromocodeSuccess) {
            UiUtils.showMessage(
              context,
              message: state.id == null
                  ? 'createPromocodeSuccess'.translate(context: context)
                  : 'updatePromocode'.translate(context: context),
              type: ToastificationType.success,
              onMessageClosed: () {
                if (state.id != null) {
                  context
                      .read<FetchPromocodesCubit>()
                      .updatePromocode(state.promocode, state.id!);
                } else {
                  context
                      .read<FetchPromocodesCubit>()
                      .addPromocodeToCubit(state.promocode);
                }
                Navigator.pop(context);
              },
            );
          }
        },
        child: screenBuilder(currIndex),
      ),
    );
  }

  Widget screenBuilder(int currentPage) {
    return Stack(
      children: [
        SingleChildScrollView(
          clipBehavior: Clip.none,
          padding: const EdgeInsets.fromLTRB(
              15, 15, 15, 15 + UiUtils.bottomButtonSpacing),
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: PromoCodeForm(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: bottomNavigation(),
        )
      ],
    );
  }

  Widget PromoCodeForm() {
    return Form(
      key: formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormField(
            labelText: 'promocodeLbl'.translate(context: context),
            controller: promocodeController,
            currNode: promocodeFocus,
            validator: (String? value) => Validator.nullCheck(context, value),
            nextFocus: messageFocus,
          ),
          CustomTextFormField(
            labelText: 'messageLbl'.translate(context: context),
            controller: messageController,
            currNode: messageFocus,
            nextFocus: startDtFocus,
            textInputType: TextInputType.multiline,
            validator: (String? value) => Validator.nullCheck(context, value),
          ),
          CustomText(
            'imageLbl'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          pickImage.ListenImageChange(
            (BuildContext context, image) {
              if (image == null) {
                if (widget.promocode?.image != null) {
                  return GestureDetector(
                    onTap: _chooseImage,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: CustomSizedBox(
                            height: 200,
                            width: MediaQuery.sizeOf(context).width,
                            child: CustomCachedNetworkImage(
                                imageUrl: widget.promocode!.image!),
                          ),
                        ),
                        CustomSizedBox(
                          height: 210,
                          width: MediaQuery.sizeOf(context).width - 5,
                          child: DashedRect(
                            color: Theme.of(context).colorScheme.blackColor,
                            strokeWidth: 2.0,
                            gap: 4.0,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: CustomInkWellContainer(
                    onTap: _chooseImage,
                    child: SetDottedBorderWithHint(
                      height: 100,
                      width: MediaQuery.sizeOf(context).width - 35,
                      radius: 7,
                      str: 'chooseImgLbl'.translate(context: context),
                      strPrefix: '',
                      borderColor: Theme.of(context).colorScheme.blackColor,
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(3.0),
                child: GestureDetector(
                  onTap: _chooseImage,
                  child: Stack(
                    children: [
                      CustomSizedBox(
                        height: 200,
                        width: MediaQuery.sizeOf(context).width,
                        child: Image.file(
                          image,
                        ),
                      ),
                      CustomSizedBox(
                        height: 210,
                        width: MediaQuery.sizeOf(context).width - 5,
                        child: DashedRect(
                          color: Theme.of(context).colorScheme.blackColor,
                          strokeWidth: 2.0,
                          gap: 4.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const CustomSizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  labelText: 'startDateLbl'.translate(context: context),
                  controller: startDtController,
                  //backgroundColor: Theme.of(context).colorScheme.secondaryColor,
                  currNode: startDtFocus,
                  nextFocus: endDtFocus,
                  validator: (String? value) =>
                      Validator.nullCheck(context, value),
                  callback: () => onDateTap(
                    isStartDate: true,
                    startDtController,
                  ),
                  isReadOnly: true,
                ),
              ),
              const CustomSizedBox(
                width: 10,
              ),
              Expanded(
                child: CustomTextFormField(
                  labelText: 'endDateLbl'.translate(context: context),
                  controller: endDtController,
                  currNode: endDtFocus,
                  nextFocus: minOrderAmtFocus,
                  callback: () {
                    if (startDtController.text.isEmpty) {
                      FocusScope.of(context).unfocus();
                      UiUtils.showMessage(
                        context,
                        message:
                            'selectStartDateFirst'.translate(context: context),
                        type: ToastificationType.warning,
                      );
                      return;
                    }
                    onDateTap(
                      endDtController,
                      isStartDate: false,
                    );
                  },
                  validator: (String? value) =>
                      Validator.nullCheck(context, value),
                  isReadOnly: true,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  labelText: 'minOrderAmtLbl'.translate(context: context),
                  controller: minOrderAmtController,
                  allowOnlySingleDecimalPoint: true,
                  currNode: minOrderAmtFocus,
                  nextFocus: noOfUserFocus,
                  validator: (String? value) =>
                      Validator.nullCheck(context, value),
                  textInputType: TextInputType.number,
                ),
              ),
              const CustomSizedBox(
                width: 10,
              ),
              Expanded(
                child: CustomTextFormField(
                  labelText: 'noOfUserLbl'.translate(context: context),
                  controller: noOfUserController,
                  currNode: noOfUserFocus,
                  nextFocus: discountFocus,
                  inputFormatters: UiUtils.allowOnlyDigits(),
                  textInputType: TextInputType.number,
                  validator: (String? value) =>
                      Validator.nullCheck(context, value),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  labelText: 'discountLbl'.translate(context: context),
                  controller: discountController,
                  textInputType: TextInputType.phone,
                  allowOnlySingleDecimalPoint: true,
                  currNode: discountFocus,
                  nextFocus: discountTypeFocus,
                  validator: (String? value) =>
                      Validator.nullCheck(context, value),
                ),
              ),
              const CustomSizedBox(
                width: 10,
              ),
              Expanded(
                child: CustomTextFormField(
                  isReadOnly: true,
                  suffixIcon: const Icon(Icons.arrow_drop_down_outlined),
                  labelText: 'discTypeLbl'.translate(context: context),
                  controller: discountTypeController,
                  validator: (String? value) {
                    if (selectedDiscountType == null) {
                      return 'chooseDiscountType'.translate(context: context);
                    }
                    return null;
                  },
                  currNode: discountTypeFocus,
                  nextFocus: maxDiscFocus,
                  callback: () async {
                    final List<Map<String, dynamic>> values = [
                      {
                        'id': 'percentage',
                        'title': 'percentage'.translate(context: context),
                        "isSelected":
                            selectedDiscountType?['value'] == "percentage"
                      },
                      {
                        'id': 'amount',
                        'title': 'amount'.translate(context: context),
                        "isSelected": selectedDiscountType?['value'] == "amount"
                      }
                    ];
                    UiUtils.showModelBottomSheets(
                            context: context,
                            child: SelectableListBottomSheet(
                                bottomSheetTitle: "discTypeLbl",
                                itemList: values))
                        .then((value) {
                      if (value != null) {
                        discountTypeController.text = value['selectedItemName'];

                        selectedDiscountType = discountTypesFilter
                            .where((Map element) =>
                                element['value'] == value["selectedItemId"])
                            .toList()[0];
                        setState(() {});
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  labelText: 'maxDiscAmtLbl'.translate(context: context),
                  controller: maxDiscController,
                  currNode: maxDiscFocus,
                  nextFocus: noOfRepeatUsage,
                  allowOnlySingleDecimalPoint: true,
                  textInputType: TextInputType.number,
                  validator: (String? value) {
                    return Validator.nullCheck(context, value);
                  },
                ),
              ),
              if (isRepeatUsage) ...[
                const CustomSizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomTextFormField(
                    labelText: 'noOfRepeatUsage'.translate(context: context),
                    controller: noOfRepeatUsageController,
                    currNode: noOfRepeatUsage,
                    inputFormatters: UiUtils.allowOnlyDigits(),
                    forceUnfocus: true,
                    validator: (String? p0) => Validator.nullCheck(context, p0),
                    textInputType: TextInputType.number,
                  ),
                )
              ]
            ],
          ),
          setTitleAndSwitch(
            onTap: () {
              isRepeatUsage = !isRepeatUsage;
              setState(() {});
            },
            isAllowed: isRepeatUsage,
            titleText: 'repeatUsageLbl'.translate(context: context),
          ),
          setTitleAndSwitch(
            onTap: () {
              isStatus = !isStatus;
              setState(() {});
            },
            isAllowed: isStatus,
            titleText: 'statusLbl'.translate(context: context),
          ),
        ],
      ),
    );
  }

  Future<void> onDateTap(
    TextEditingController dateInput, {
    required bool isStartDate,
  }) async {
    final DateTime? initialDate =
        isStartDate ? null : DateTime.parse('$selectedStartDate 00:00:00.000');
    //
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: initialDate ?? DateTime.now().subtract(Duration.zero), //1
      lastDate: DateTime.now()
          .add(const Duration(days: UiUtils.noOfDaysAllowToCreatePromoCode)),
    );

    if (pickedDate != null) {
      final String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      if (isStartDate) {
        selectedStartDate = formattedDate;
      } else {
        selectedEndDate = formattedDate;
      }
      setState(() {
        dateInput.text = formattedDate.formatDate();
      });
    }
  }

  Widget setTitleAndSwitch(
      {required Function()? onTap,
      required String titleText,
      required bool isAllowed}) {
    return CustomInkWellContainer(
      showSplashEffect: false,
      onTap: () {
        onTap?.call();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CustomText(
              titleText,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.blackColor,
            ),
          ),
          CustomSwitch(
            thumbColor: isAllowed ? Colors.green : Colors.red,
            value: isAllowed,
            onChanged: (bool val) {
              onTap?.call();
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  Padding bottomNavigation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 15, right: 15),
      child: CustomRoundedButton(
        widthPercentage: 1,
        textSize: 14,
        height: 55,
        titleColor: AppColors.whiteColors,
        onTap: (context.watch<CreatePromocodeCubit>().state
                is CreatePromocodeInProgress)
            ? () {}
            : onAddPromoCode,
        backgroundColor: Theme.of(context).colorScheme.accentColor,
        buttonTitle: widget.promocode?.id != null
            ? 'editPromoCodeTitleLbl'.translate(context: context)
            : 'addPromoCodeTitleLbl'.translate(context: context),
        showBorder: true,
        child: (context.watch<CreatePromocodeCubit>().state
                is CreatePromocodeInProgress)
            ? CustomCircularProgressIndicator(
                color: AppColors.whiteColors,
              )
            : null,
      ),
    );
  }
}
