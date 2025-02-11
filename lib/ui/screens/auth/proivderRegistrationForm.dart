import 'package:edemand_partner/cubits/fetchUserCurrentLocationCubit.dart';
import 'package:edemand_partner/ui/widgets/customCheckbox.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';

import '../../../app/generalImports.dart';
import '../../../utils/location.dart';
import 'map.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key, required this.isEditing});

  final bool isEditing;

  @override
  RegistrationFormState createState() => RegistrationFormState();

  static Route<RegistrationForm> route(RouteSettings routeSettings) {
    final Map<String, dynamic> parameters =
        routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (BuildContext context) => EditProviderDetailsCubit(),
        child: RegistrationForm(
          isEditing: parameters['isEditing'],
        ),
      ),
    );
  }
}

class RegistrationFormState extends State<RegistrationForm> {
  int totalForms = 6;

  int currentIndex = 1;

  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey4 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey5 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey6 = GlobalKey<FormState>();

  ScrollController scrollController = ScrollController();
  HtmlEditorController htmlController = HtmlEditorController();

  ///form1
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode userNmFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode mobNoFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  Map<String, dynamic> pickedLocalImages = {
    'nationalIdImage': '',
    'addressIdImage': '',
    'passportIdImage': '',
    'logoImage': '',
    'bannerImage': ''
  };

  ///form2
  TextEditingController cityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController aboutCompanyController = TextEditingController();
  TextEditingController visitingChargesController = TextEditingController();
  TextEditingController advanceBookingDaysController = TextEditingController();
  TextEditingController numberOfMemberController = TextEditingController();

  FocusNode aboutCompanyFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode latitudeFocus = FocusNode();
  FocusNode longitudeFocus = FocusNode();
  FocusNode companyNmFocus = FocusNode();
  FocusNode visitingChargeFocus = FocusNode();
  FocusNode advanceBookingDaysFocus = FocusNode();
  FocusNode numberOfMemberFocus = FocusNode();
  Map? selectCompanyType;
  Map companyType = {'0': 'Individual', '1': 'Organisation'};

  ///form3
  List<bool> isChecked =
      List<bool>.generate(7, (int index) => false); //7 = daysOfWeek.length
  List<TimeOfDay> selectedStartTime = [];
  List<TimeOfDay> selectedEndTime = [];

  late List<String> daysOfWeek = [
    'monLbl'.translate(context: context),
    'tueLbl'.translate(context: context),
    'wedLbl'.translate(context: context),
    'thuLbl'.translate(context: context),
    'friLbl'.translate(context: context),
    'satLbl'.translate(context: context),
    'sunLbl'.translate(context: context),
  ];

  late List<String> daysInWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  ///form4
  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankCodeController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController taxNameController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();
  TextEditingController swiftCodeController = TextEditingController();

  FocusNode bankNameFocus = FocusNode();
  FocusNode bankCodeFocus = FocusNode();
  FocusNode bankAccountNumberFocus = FocusNode();
  FocusNode accountNameFocus = FocusNode();
  FocusNode accountNumberFocus = FocusNode();
  FocusNode taxNameFocus = FocusNode();
  FocusNode taxNumberFocus = FocusNode();
  FocusNode swiftCodeFocus = FocusNode();

  PickImage pickLogoImage = PickImage();
  PickImage pickBannerImage = PickImage();
  PickImage pickAddressProofImage = PickImage();
  PickImage pickPassportImage = PickImage();
  PickImage pickNationalIdImage = PickImage();

  ProviderDetails? providerData;
  bool? isIndividualType;

  String? isPreBookingChatAllowed;
  String? isPostBookingChatAllowed;
  String? atStore;
  String? atDoorstep;
  String? longDescription;
  ValueNotifier<List<String>> pickedOtherImages = ValueNotifier([]);
  List<String>? previouslyAddedOtherImages = [];

  @override
  void initState() {
    super.initState();

    initializeData();
  }

  void initializeData() {
    Future.delayed(Duration.zero).then((value) {
      //
      providerData = context.read<ProviderDetailsCubit>().providerDetails;
      //
      userNameController.text = providerData?.user?.username ?? '';
      emailController.text = providerData?.user?.email ?? '';
      mobileNumberController.text =
          "${providerData?.user?.countryCode ?? ""} ${providerData?.user?.phone ?? ""}";
      companyNameController.text =
          providerData?.providerInformation?.companyName ?? '';
      aboutCompanyController.text =
          providerData?.providerInformation?.about ?? '';
      //
      isPostBookingChatAllowed =
          providerData?.providerInformation?.isPostBookingChatAllowed ?? "0";
      isPreBookingChatAllowed =
          providerData?.providerInformation?.isPreBookingChatAllowed ?? "0";

      atDoorstep = providerData?.providerInformation?.atDoorstep ?? "0";
      atStore = providerData?.providerInformation?.atStore ?? "0";

      //
      bankNameController.text = providerData?.bankInformation?.bankName ?? '';
      bankCodeController.text = providerData?.bankInformation?.bankCode ?? '';
      accountNameController.text =
          providerData?.bankInformation?.accountName ?? '';
      accountNumberController.text =
          providerData?.bankInformation?.accountNumber ?? '';
      taxNameController.text = providerData?.bankInformation?.taxName ?? '';
      taxNumberController.text = providerData?.bankInformation?.taxNumber ?? '';
      swiftCodeController.text = providerData?.bankInformation?.swiftCode ?? '';
      //
      cityController.text = providerData?.locationInformation?.city ?? '';
      addressController.text = providerData?.locationInformation?.address ?? '';
      latitudeController.text =
          providerData?.locationInformation?.latitude ?? '';
      longitudeController.text =
          providerData?.locationInformation?.longitude ?? '';
      companyNameController.text =
          providerData?.providerInformation?.companyName ?? '';
      aboutCompanyController.text =
          providerData?.providerInformation?.about ?? '';
      visitingChargesController.text =
          providerData?.providerInformation?.visitingCharges ?? '';
      advanceBookingDaysController.text =
          providerData?.providerInformation?.advanceBookingDays ?? '';
      numberOfMemberController.text =
          providerData?.providerInformation?.numberOfMembers ?? '';
      selectCompanyType = providerData?.providerInformation?.type == '0'
          ? {'title': 'Individual', 'value': '0'}
          : {'title': 'Organization', 'value': '1'};
      isIndividualType = providerData?.providerInformation?.type == '1';
      //add elements in TimeOfDay List
      //
      final List<WorkingDay>? data =
          providerData?.workingDays?.reversed.toList();
      for (int i = 0; i < daysInWeek.length; i++) {
        //assign Default time @ start
        final List<String> startTime =
            (data?[i].startTime ?? '09:00:00').split(':');
        final List<String> endTime =
            (data?[i].endTime ?? '18:00:00').split(':');

        final int startTimeHour = int.parse(startTime[0]);
        final int startTimeMinute = int.parse(startTime[1]);
        selectedStartTime.insert(
          i,
          TimeOfDay(hour: startTimeHour, minute: startTimeMinute),
        );
        //
        final int endTimeHour = int.parse(endTime[0]);
        final int endTimeMinute = int.parse(endTime[1]);
        selectedEndTime.insert(
          i,
          TimeOfDay(hour: endTimeHour, minute: endTimeMinute),
        );
        isChecked[i] = data?[i].isOpen == 1;
      }

      longDescription = providerData?.providerInformation?.longDescription;
      previouslyAddedOtherImages =
          providerData?.providerInformation?.otherImages;

      setState(() {});
    });
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    mobileNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    companyNameController.dispose();
    visitingChargesController.dispose();
    advanceBookingDaysController.dispose();
    numberOfMemberController.dispose();
    aboutCompanyController.dispose();
    cityController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    addressController.dispose();
    bankNameController.dispose();
    bankCodeController.dispose();
    accountNameController.dispose();
    accountNumberController.dispose();
    taxNumberController.dispose();
    taxNameController.dispose();
    swiftCodeController.dispose();
    //
    pickedLocalImages.clear();
    pickedOtherImages.dispose();
    //
    confirmPasswordFocus.dispose();
    passwordFocus.dispose();
    mobNoFocus.dispose();
    emailFocus.dispose();
    userNmFocus.dispose();
    numberOfMemberFocus.dispose();
    advanceBookingDaysFocus.dispose();
    visitingChargeFocus.dispose();
    companyNmFocus.dispose();
    longitudeFocus.dispose();
    latitudeFocus.dispose();
    addressFocus.dispose();
    cityFocus.dispose();
    aboutCompanyFocus.dispose();
    swiftCodeFocus.dispose();
    taxNumberFocus.dispose();
    taxNameFocus.dispose();
    accountNumberFocus.dispose();
    accountNameFocus.dispose();
    bankAccountNumberFocus.dispose();
    bankCodeFocus.dispose();
    bankNameFocus.dispose();
    //
    pickNationalIdImage.dispose();
    pickPassportImage.dispose();
    pickAddressProofImage.dispose();
    pickBannerImage.dispose();
    pickLogoImage.dispose();
    //
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: PopScope(
        canPop: currentIndex == 1,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            return;
          } else {
            if (currentIndex > 1) {
              currentIndex--;
              pickedLocalImages = pickedLocalImages;
              setState(() {});
            }
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
          appBar: AppBar(
            elevation: 1,
            centerTitle: true,
            title: CustomText(
              widget.isEditing
                  ? 'editDetails'.translate(context: context)
                  : 'completeKYCDetails'.translate(context: context),
              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.bold,
            ),
            leading: widget.isEditing
                ? CustomBackArrow(
                    onTap: () {
                      if (currentIndex > 1) {
                        currentIndex--;
                        pickedLocalImages = pickedLocalImages;
                        setState(() {});
                        return;
                      }
                      Navigator.pop(context);
                    },
                  )
                : null,
            backgroundColor: Theme.of(context).colorScheme.secondaryColor,
            surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
            actions: <Widget>[
              PageNumberIndicator(
                currentIndex: currentIndex,
                total: totalForms,
              )
            ],
          ),
          bottomNavigationBar: bottomNavigation(currentIndex: currentIndex),
          body: screenBuilder(currentIndex),
        ),
      ),
    );
  }

  Padding bottomNavigation({required int currentIndex}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentIndex > 1) ...[
            Expanded(
              child: nextPrevBtnWidget(
                isNext: false,
                currentIndex: currentIndex,
              ),
            ),
            const CustomSizedBox(width: 10),
          ],
          Expanded(
            child: BlocListener<EditProviderDetailsCubit,
                    EditProviderDetailsState>(
                listener: (BuildContext context,
                    EditProviderDetailsState state) async {
                  if (state is EditProviderDetailsSuccess) {
                    UiUtils.showMessage(
                      context,
                      message: 'detailsUpdatedSuccessfully'
                          .translate(context: context),
                      type: ToastificationType.success,
                    );
                    //
                    if (widget.isEditing) {
                      context
                          .read<ProviderDetailsCubit>()
                          .setUserInfo(state.providerDetails);
                      Future.delayed(const Duration(seconds: 1)).then((value) {
                        Navigator.pop(context);
                      });
                    } else {
                      Future.delayed(
                        Duration.zero,
                        () {
                          HiveRepository.setUserLoggedIn = false;
                          HiveRepository.clearBoxValues(
                              boxName: HiveRepository.userDetailBoxKey);
                          context
                              .read<AuthenticationCubit>()
                              .setUnAuthenticated();
                          //   NotificationService.disposeListeners();
                          AppQuickActions.clearShortcutItems();
                        },
                      );

//
                      Future.delayed(const Duration(seconds: 1)).then((value) {
                        Navigator.pushReplacementNamed(
                          context,
                          Routes.successScreen,
                          arguments: {
                            'title':
                                'detailsSubmitted'.translate(context: context),
                            'message':
                                'detailsHasBeenSubmittedWaitForAdminApproval'
                                    .translate(context: context),
                            'imageName': 'registration'
                          },
                        );
                      });
                    }
                  } else if (state is EditProviderDetailsFailure) {
                    UiUtils.showMessage(
                      context,
                      message: state.errorMessage.translate(context: context),
                      type: ToastificationType.error,
                    );
                  }
                },
                child: nextPrevBtnWidget(
                  isNext: true,
                  currentIndex: currentIndex,
                )),
          ),
        ],
      ),
    );
  }

  Widget nextPrevBtnWidget({required bool isNext, required int currentIndex}) {
    return BlocBuilder<EditProviderDetailsCubit, EditProviderDetailsState>(
      builder: (BuildContext context, EditProviderDetailsState state) {
        Widget? child;
        if (state is EditProviderDetailsInProgress) {
          child = CustomCircularProgressIndicator(
            color: AppColors.whiteColors,
          );
        } else if (state is EditProviderDetailsSuccess ||
            state is EditProviderDetailsFailure) {
          child = null;
        }
        return CustomRoundedButton(
          widthPercentage: isNext ? 1 : 0.5,
          backgroundColor: isNext
              ? Theme.of(context).colorScheme.accentColor
              : Theme.of(context).colorScheme.secondaryColor,
          buttonTitle: isNext && currentIndex >= totalForms
              ? 'submitBtnLbl'.translate(context: context)
              : isNext
                  ? 'nxtBtnLbl'.translate(context: context)
                  : 'prevBtnLbl'.translate(context: context),
          showBorder: !isNext,
          borderColor: Theme.of(context).colorScheme.blackColor,
          titleColor: isNext
              ? AppColors.whiteColors
              : Theme.of(context).colorScheme.blackColor,
          onTap: () => state is EditProviderDetailsInProgress
              ? () {}
              : onNextPrevBtnClick(isNext: isNext, currentPage: currentIndex),
          child: isNext && currentIndex >= totalForms ? child : null,
        );
      },
    );
  }

  Future<void> onNextPrevBtnClick({
    required bool isNext,
    required int currentPage,
  }) async {
    if (currentPage == 3) {
      final tempText = await htmlController.getText();

      if (tempText.trim().isNotEmpty) {
        longDescription = tempText;
      }
    }
    if (isNext) {
      FormState? form = formKey1.currentState; //default value
      switch (currentPage) {
        case 2:
          form = formKey2.currentState;
          break;
        case 4:
          form = formKey4.currentState;
          break;
        case 5:
          form = formKey5.currentState;
          break;
        case 6:
          form = formKey6.currentState;
          break;
        default:
          form = formKey1.currentState;
          break;
      }
      if (currentPage != 3) {
        if (form == null) return;
        form.save();
      }

      if (currentPage == 3 || form!.validate()) {
        if (currentPage < totalForms) {
          currentIndex++;
          if (currentPage != 3) {
            scrollController.jumpTo(0); //reset Scrolling on Form change
          }
          pickedLocalImages = pickedLocalImages;
          setState(() {});
        } else {
          final List<WorkingDay> workingDays = [];
          for (int i = 0; i < daysInWeek.length; i++) {
            //
            workingDays.add(
              WorkingDay(
                isOpen: isChecked[i] ? 1 : 0,
                endTime:
                    "${selectedEndTime[i].hour.toString().padLeft(2, "0")}:${selectedEndTime[i].minute.toString().padLeft(2, "0")}:00",
                startTime:
                    "${selectedStartTime[i].hour.toString().padLeft(2, "0")}:${selectedStartTime[i].minute.toString().padLeft(2, "0")}:00",
                day: daysInWeek[i],
              ),
            );
          }

          final ProviderDetails editProviderDetails = ProviderDetails(
            workingDays: workingDays,
            user: UserDetails(
              id: providerData?.user?.id,
              username: userNameController.text.trim(),
              email: emailController.text.trim(),
              phone: providerData?.user?.phone,
              countryCode: providerData?.user?.countryCode,
              company: companyNameController.text.trim(),
              image: pickedLocalImages['logoImage'],
            ),
            providerInformation: ProviderInformation(
                type: selectCompanyType?['value'],
                companyName: companyNameController.text.trim(),
                visitingCharges: visitingChargesController.text.trim(),
                advanceBookingDays: advanceBookingDaysController.text.trim(),
                about: aboutCompanyController.text.trim(),
                numberOfMembers: numberOfMemberController.text.trim(),
                banner: pickedLocalImages['bannerImage'],
                nationalId: pickedLocalImages['nationalIdImage'],
                passport: pickedLocalImages['passportIdImage'],
                addressId: pickedLocalImages['addressIdImage'],
                otherImages: pickedOtherImages.value,
                longDescription: longDescription,
                isPostBookingChatAllowed: isPostBookingChatAllowed,
                isPreBookingChatAllowed: isPreBookingChatAllowed,
                atDoorstep: atDoorstep,
                atStore: atStore),
            bankInformation: BankInformation(
              accountName: accountNameController.text.trim(),
              accountNumber: accountNumberController.text.trim(),
              bankCode: bankCodeController.text.trim(),
              bankName: bankNameController.text.trim(),
              taxName: taxNameController.text.trim(),
              taxNumber: taxNumberController.text.trim(),
              swiftCode: swiftCodeController.text.trim(),
            ),
            locationInformation: LocationInformation(
              longitude: longitudeController.text.trim(),
              latitude: latitudeController.text.trim(),
              address: addressController.text.trim(),
              city: cityController.text.trim(),
            ),
          );
          //
          if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable() &&
              widget.isEditing) {
            UiUtils.showDemoModeWarning(context: context);
            return;
          }
          print('hjsdhfjswagdesgwfchjgfjhgf');
          context
              .read<EditProviderDetailsCubit>()
              .editProviderDetails(providerDetails: editProviderDetails);
        }
      }
    } else if (currentPage > 1) {
      currentIndex--;
      pickedLocalImages = pickedLocalImages;
      setState(() {});
    }
  }

  Widget screenBuilder(int currentPage) {
    Widget currentForm = form1(); //default form1
    switch (currentPage) {
      case 2:
        currentForm = form2();
        break;
      case 3:
        currentForm = form3();
        break;
      case 4:
        currentForm = form4();
        break;
      case 5:
        currentForm = form5();
        break;
      case 6:
        currentForm = form6();
        break;
      default:
        currentForm = form1();
        break;
    }
    return currentPage == 3
        ? currentForm
        : SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: currentForm,
          );
  }

  Widget form1() {
    return Form(
      key: formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'personalDetails'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          const CustomDivider(thickness: 1),
          const CustomSizedBox(
            height: 10,
          ),
          CustomTextFormField(
            labelText: 'userNmLbl'.translate(context: context),
            controller: userNameController,
            currNode: userNmFocus,
            nextFocus: emailFocus,
            validator: (String? userName) =>
                Validator.nullCheck(context, userName),
          ),
          CustomTextFormField(
            labelText: 'emailLbl'.translate(context: context),
            controller: emailController,
            currNode: emailFocus,
            nextFocus: mobNoFocus,
            textInputType: TextInputType.emailAddress,
            validator: (String? email) => Validator.nullCheck(context, email),
          ),
          CustomTextFormField(
            labelText: 'mobNoLbl'.translate(context: context),
            controller: mobileNumberController,
            currNode: mobNoFocus,
            textInputType: TextInputType.phone,
            isReadOnly: true,
            validator: (String? mobileNumber) =>
                Validator.nullCheck(context, mobileNumber),
          ),
          const CustomSizedBox(
            height: 12,
          ),
          CustomText(
            'idProofLbl'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          const CustomDivider(thickness: 1),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                idImageWidget(
                  imageController: pickNationalIdImage,
                  titleTxt: 'nationalIdLbl'.translate(context: context),
                  imageHintText: 'chooseFileLbl'.translate(context: context),
                  imageType: 'nationalIdImage',
                  oldImage: context
                          .read<ProviderDetailsCubit>()
                          .providerDetails
                          .providerInformation
                          ?.nationalId ??
                      '',
                ),
                idImageWidget(
                  imageController: pickAddressProofImage,
                  titleTxt: 'addressLabel'.translate(context: context),
                  imageHintText: 'chooseFileLbl'.translate(context: context),
                  imageType: 'addressIdImage',
                  oldImage: context
                          .read<ProviderDetailsCubit>()
                          .providerDetails
                          .providerInformation
                          ?.addressId ??
                      '',
                ),
                idImageWidget(
                  imageController: pickPassportImage,
                  titleTxt: 'passportLbl'.translate(context: context),
                  imageHintText: 'chooseFileLbl'.translate(context: context),
                  imageType: 'passportIdImage',
                  oldImage: context
                          .read<ProviderDetailsCubit>()
                          .providerDetails
                          .providerInformation
                          ?.passport ??
                      '',
                ),
              ],
            ),
          ),
          const CustomSizedBox(
            height: 12,
          ),
          CustomText(
            'chatSetting'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          const CustomDivider(thickness: 1),
          GestureDetector(
            onTap: () {
              atStore == "1" ? atStore = "0" : atStore = "1";
              setState(() {});
            },
            child: Row(
              children: [
                Expanded(
                    child: CustomText("atStore".translate(context: context))),
                const SizedBox(
                  width: 5,
                ),
                CustomSwitch(
                    thumbColor: atStore == "1" ? Colors.green : Colors.red,
                    onChanged: (p0) {
                      atStore == "1" ? atStore = "0" : atStore = "1";
                      setState(() {});
                    },
                    value: atStore == "1"),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              atDoorstep == "1" ? atDoorstep = "0" : atDoorstep = "1";
              setState(() {});
            },
            child: Row(
              children: [
                Expanded(
                    child:
                        CustomText("atDoorstep".translate(context: context))),
                const SizedBox(
                  width: 5,
                ),
                CustomSwitch(
                    thumbColor: atDoorstep == "1" ? Colors.green : Colors.red,
                    onChanged: (p0) {
                      atDoorstep == "1" ? atDoorstep = "0" : atDoorstep = "1";
                      setState(() {});
                    },
                    value: atDoorstep == "1"),
              ],
            ),
          ),
          if ((context.read<FetchSystemSettingsCubit>().state
                  as FetchSystemSettingsSuccess)
              .generalSettings
              .allowPreBookingChat!)
            GestureDetector(
              onTap: () {
                isPreBookingChatAllowed == "1"
                    ? isPreBookingChatAllowed = "0"
                    : isPreBookingChatAllowed = "1";
                setState(() {});
              },
              child: Row(
                children: [
                  Expanded(
                      child: CustomText("isPreBookingChatAllowed"
                          .translate(context: context))),
                  const SizedBox(
                    width: 5,
                  ),
                  CustomSwitch(
                      thumbColor: isPreBookingChatAllowed == "1"
                          ? Colors.green
                          : Colors.red,
                      onChanged: (p0) {
                        isPreBookingChatAllowed == "1"
                            ? isPreBookingChatAllowed = "0"
                            : isPreBookingChatAllowed = "1";
                        setState(() {});
                      },
                      value: isPreBookingChatAllowed == "1"),
                ],
              ),
            ),
          if ((context.read<FetchSystemSettingsCubit>().state
                  as FetchSystemSettingsSuccess)
              .generalSettings
              .allowPostBookingChat!)
            GestureDetector(
              onTap: () {
                isPostBookingChatAllowed == "1"
                    ? isPostBookingChatAllowed = "0"
                    : isPostBookingChatAllowed = "1";
                setState(() {});
              },
              child: Row(
                children: [
                  Expanded(
                      child: CustomText("isPostBookingChatAllowed"
                          .translate(context: context))),
                  const SizedBox(
                    width: 5,
                  ),
                  CustomSwitch(
                      thumbColor: isPostBookingChatAllowed == "1"
                          ? Colors.green
                          : Colors.red,
                      onChanged: (p0) {
                        isPostBookingChatAllowed == "1"
                            ? isPostBookingChatAllowed = "0"
                            : isPostBookingChatAllowed = "1";
                        setState(() {});
                      },
                      value: isPostBookingChatAllowed == "1"),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget form2() {
    return Form(
      key: formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'companyDetails'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          const CustomDivider(thickness: 1),
          const CustomSizedBox(
            height: 10,
          ),
          CustomTextFormField(
            labelText: 'compNmLbl'.translate(context: context),
            controller: companyNameController,
            currNode: companyNmFocus,
            nextFocus: visitingChargeFocus,
            validator: (String? companyName) =>
                Validator.nullCheck(context, companyName),
          ),
          CustomTextFormField(
            labelText: 'visitingCharge'.translate(context: context),
            controller: visitingChargesController,
            currNode: visitingChargeFocus,
            nextFocus: companyNmFocus,
            validator: (String? visitingCharge) =>
                Validator.nullCheck(context, visitingCharge),
            textInputType: TextInputType.number,
            allowOnlySingleDecimalPoint: true,
            prefix: Padding(
              padding: const EdgeInsetsDirectional.all(15.0),
              child: CustomText(
                UiUtils.systemCurrency ?? '',
                fontSize: 14.0,
                color: Theme.of(context).colorScheme.blackColor,
              ),
            ),
          ),
          CustomTextFormField(
            labelText: 'advanceBookingDay'.translate(context: context),
            controller: advanceBookingDaysController,
            currNode: advanceBookingDaysFocus,
            nextFocus: numberOfMemberFocus,
            validator: (String? advancedBooking) {
              final String? value =
                  Validator.nullCheck(context, advancedBooking);
              if (value != null) {
                return value;
              }
              if (int.parse(advancedBooking ?? '0') < 1) {
                return 'advanceBookingDaysShouldBeGreaterThan0'
                    .translate(context: context);
              }
              return null;
            },
            textInputType: TextInputType.number,
          ),
          CustomTextFormField(
            labelText: 'aboutCompany'.translate(context: context),
            controller: aboutCompanyController,
            currNode: aboutCompanyFocus,
            minLines: 3,
            expands: true,
            textInputType: TextInputType.multiline,
            validator: (String? aboutCompany) =>
                Validator.nullCheck(context, aboutCompany),
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  bottomPadding: 0,
                  controller: TextEditingController(
                      text: selectCompanyType?["title"] ?? ""),
                  labelText: 'selectType'.translate(context: context),
                  isReadOnly: true,
                  hintText: 'selectType'.translate(context: context),
                  suffixIcon: const Icon(Icons.arrow_drop_down_outlined),
                  callback: () {
                    selectCompanyTypes();
                  },
                ),
              ),
              const CustomSizedBox(
                width: 10,
              ),
              Expanded(
                child: CustomTextFormField(
                  bottomPadding: 0,
                  labelText: 'numberOfMember'.translate(context: context),
                  controller: numberOfMemberController,
                  currNode: numberOfMemberFocus,
                  nextFocus: aboutCompanyFocus,
                  validator: (String? numberOfMembers) =>
                      Validator.nullCheck(context, numberOfMembers),
                  isReadOnly: isIndividualType ?? false,
                  textInputType: TextInputType.number,
                ),
              ),
            ],
          ),

          const CustomSizedBox(
            height: 5,
          ),
          CustomText(
            'logoLbl'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          const CustomSizedBox(
            height: 5,
          ),
          imagePicker(
            imageController: pickLogoImage,
            oldImage: providerData?.user?.image ?? '',
            hintLabel:
                "${"addLbl".translate(context: context)} ${"logoLbl".translate(context: context)}",
            imageType: 'logoImage',
          ),
          const CustomSizedBox(
            height: 10,
          ),
          CustomText(
            'bannerImgLbl'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          const CustomSizedBox(
            height: 5,
          ),
          imagePicker(
            imageController: pickBannerImage,
            oldImage: providerData?.providerInformation?.banner ?? '',
            hintLabel:
                "${"addLbl".translate(context: context)} ${"bannerImgLbl".translate(context: context)}",
            imageType: 'bannerImage',
          ),
          const CustomSizedBox(height: 10),
          CustomText(
            'otherImages'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          const CustomSizedBox(height: 5),
          //other image picker builder
          ValueListenableBuilder(
            valueListenable: pickedOtherImages,
            builder: (BuildContext context, Object? value, Widget? child) {
              final bool isThereAnyImage = pickedOtherImages.value.isNotEmpty ||
                  (previouslyAddedOtherImages != null &&
                      previouslyAddedOtherImages!.isNotEmpty);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: CustomSizedBox(
                  height: isThereAnyImage ? 150 : 100,
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CustomInkWellContainer(
                          onTap: () async {
                            try {
                              final FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                allowMultiple: true,
                                type: FileType.image,
                              );
                              if (result != null) {
                                if (previouslyAddedOtherImages != null &&
                                    previouslyAddedOtherImages!.isNotEmpty) {
                                  previouslyAddedOtherImages = null;
                                }
                                for (int i = 0; i < result.files.length; i++) {
                                  if (!pickedOtherImages.value
                                      .contains(result.files[i].path)) {
                                    pickedOtherImages.value =
                                        List.from(pickedOtherImages.value)
                                          ..insert(0, result.files[i].path!);
                                  }
                                }
                                //       pickedOtherImages.notifyListeners();
                              } else {
                                // User canceled the picker
                              }
                            } catch (_) {}
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: isThereAnyImage ? 5 : 0,
                            ),
                            child: SetDottedBorderWithHint(
                              height: double.maxFinite,
                              width: isThereAnyImage
                                  ? 100
                                  : MediaQuery.sizeOf(context).width - 35,
                              radius: 7,
                              str: (isThereAnyImage
                                      ? previouslyAddedOtherImages != null &&
                                              previouslyAddedOtherImages!
                                                  .isNotEmpty
                                          ? "changeImages"
                                          : "addImages"
                                      : "chooseImages")
                                  .translate(context: context),
                              strPrefix: '',
                              borderColor:
                                  Theme.of(context).colorScheme.blackColor,
                            ),
                          ),
                        ),
                        if (isThereAnyImage &&
                            pickedOtherImages.value.isNotEmpty)
                          for (int i = 0;
                              i < pickedOtherImages.value.length;
                              i++)
                            CustomContainer(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              height: double.maxFinite,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .blackColor
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Image.file(
                                      File(
                                        pickedOtherImages.value[i],
                                      ),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional.topEnd,
                                    child: CustomInkWellContainer(
                                      onTap: () {
                                        //assigning new list, because listener will not notify if we remove the values only to the list
                                        pickedOtherImages.value =
                                            List.from(pickedOtherImages.value)
                                              ..removeAt(i);
                                      },
                                      child: CustomContainer(
                                        height: 20,
                                        width: 20,
                                        color: AppColors.whiteColors
                                            .withValues(alpha: 0.5),
                                        child: const Center(
                                          child: Icon(
                                            Icons.clear_rounded,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                        if (isThereAnyImage &&
                            previouslyAddedOtherImages != null &&
                            previouslyAddedOtherImages!.isNotEmpty)
                          for (int i = 0;
                              i < previouslyAddedOtherImages!.length;
                              i++)
                            CustomContainer(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              height: double.maxFinite,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .blackColor
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Center(
                                child: CustomCachedNetworkImage(
                                  imageUrl: previouslyAddedOtherImages![i],
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const CustomSizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget form3() {
    return Wrap(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(bottom: 0, left: 15, right: 15, top: 10),
          child: CustomText(
            'companyDescription'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
        ),
        SingleChildScrollView(
          child: CustomHTMLEditor(
            controller: htmlController,
            initialHTML: longDescription,
            hint: 'describeCompanyInDetail'.translate(context: context),
          ),
        ),
      ],
    );
  }

  Widget form6() {
    return Form(
      key: formKey6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'locationInformation'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          const CustomDivider(thickness: 1),
          const CustomSizedBox(
            height: 10,
          ),
          CustomInkWellContainer(
            onTap: () async {
              UiUtils.removeFocus();
              //
              String latitude = latitudeController.text.trim();
              String longitude = longitudeController.text.trim();
              if (latitude == '' && longitude == '') {
                await GetLocation().requestPermission(
                  onGranted: (Position position) {
                    latitude = position.latitude.toString();
                    longitude = position.longitude.toString();
                  },
                  allowed: (Position position) {
                    latitude = position.latitude.toString();
                    longitude = position.longitude.toString();
                  },
                  onRejected: () {},
                );
              }
              if (mounted) {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (BuildContext context) => BlocProvider(
                      create: (context) => FetchUserCurrentLocationCubit(),
                      child: GoogleMapScreen(
                        latitude: latitude,
                        longitude: longitude,
                      ),
                    ),
                  ),
                ).then((value) {
                  latitudeController.text = value['selectedLatitude'];
                  longitudeController.text = value['selectedLongitude'];
                  addressController.text = value['selectedAddress'];
                  cityController.text = value['selectedCity'];
                });
              }
            },
            child: CustomContainer(
              margin: const EdgeInsets.only(
                bottom: 15,
              ),
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.lightGreyColor,
                ),
                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.my_location_sharp,
                    color: Theme.of(context).colorScheme.accentColor,
                  ),
                  Text(
                    'chooseYourLocation'.translate(context: context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.accentColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.accentColor,
                  ),
                ],
              ),
            ),
          ),
          CustomTextFormField(
            labelText: 'cityLbl'.translate(context: context),
            controller: cityController,
            currNode: cityFocus,
            nextFocus: latitudeFocus,
            validator: (String? cityValue) =>
                Validator.nullCheck(context, cityValue),
          ),
          CustomTextFormField(
            labelText: 'latitudeLbl'.translate(context: context),
            controller: latitudeController,
            currNode: latitudeFocus,
            nextFocus: longitudeFocus,
            textInputType: TextInputType.number,
            validator: (String? latitude) =>
                Validator.validateLatitude(context, latitude),
            allowOnlySingleDecimalPoint: true,
          ),
          CustomTextFormField(
            labelText: 'longitudeLbl'.translate(context: context),
            controller: longitudeController,
            currNode: longitudeFocus,
            nextFocus: addressFocus,
            textInputType: TextInputType.number,
            validator: (String? longitude) =>
                Validator.validateLongitude(context, longitude),
            allowOnlySingleDecimalPoint: true,
          ),
          CustomTextFormField(
            labelText: 'addressLbl'.translate(context: context),
            controller: addressController,
            currNode: addressFocus,
            textInputType: TextInputType.multiline,
            expands: true,
            minLines: 3,
            validator: (String? addressValue) =>
                Validator.nullCheck(context, addressValue),
          ),
        ],
      ),
    );
  }

  Widget form4() {
    return Form(
      key: formKey4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'workingDaysLbl'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          const CustomDivider(thickness: 1),
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: daysOfWeek.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  setRow(titleTxt: daysOfWeek[index], indexVal: index),
                  if (isChecked[index])
                    setTimerPickerRow(index)
                  else
                    const CustomSizedBox(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget form5() {
    return Form(
      key: formKey5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'bankDetailsLbl'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          const CustomDivider(thickness: 1),
          const CustomSizedBox(
            height: 10,
          ),
          CustomTextFormField(
            labelText: 'bankNmLbl'.translate(context: context),
            controller: bankNameController,
            currNode: bankNameFocus,
            nextFocus: bankCodeFocus,
            validator: (String? name) => Validator.nullCheck(context, name),
          ),
          CustomTextFormField(
            labelText: 'bankCodeLbl'.translate(context: context),
            controller: bankCodeController,
            currNode: bankCodeFocus,
            nextFocus: accountNameFocus,
            validator: (String? bankCode) =>
                Validator.nullCheck(context, bankCode),
          ),
          CustomTextFormField(
            labelText: 'accountName'.translate(context: context),
            controller: accountNameController,
            currNode: accountNameFocus,
            nextFocus: accountNumberFocus,
            validator: (String? accountName) =>
                Validator.nullCheck(context, accountName),
          ),
          CustomTextFormField(
            labelText: 'accNumLbl'.translate(context: context),
            controller: accountNumberController,
            currNode: accountNumberFocus,
            nextFocus: taxNameFocus,
            textInputType: TextInputType.phone,
            validator: (String? accountNumber) =>
                Validator.nullCheck(context, accountNumber),
          ),
          CustomTextFormField(
            labelText: 'taxName'.translate(context: context),
            controller: taxNameController,
            currNode: taxNameFocus,
            nextFocus: taxNumberFocus,
            validator: (String? mobileNumber) =>
                Validator.nullCheck(context, mobileNumber),
          ),
          CustomTextFormField(
            labelText: 'taxNumber'.translate(context: context),
            controller: taxNumberController,
            currNode: taxNumberFocus,
            nextFocus: swiftCodeFocus,
            validator: (String? taxName) =>
                Validator.nullCheck(context, taxName),
            textInputType: const TextInputType.numberWithOptions(decimal: true),
          ),
          CustomTextFormField(
            labelText: 'swiftCode'.translate(context: context),
            controller: swiftCodeController,
            currNode: swiftCodeFocus,
            validator: (String? swiftCode) =>
                Validator.nullCheck(context, swiftCode),
          ),
        ],
      ),
    );
  }

  Widget setRow({required String titleTxt, required int indexVal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: CustomInkWellContainer(
        onTap: () {
          setState(
            () {
              pickedLocalImages = pickedLocalImages;
              isChecked[indexVal] = !isChecked[indexVal];
            },
          );
        },
        showSplashEffect: false,
        child: Row(
          children: [
            Expanded(
              child: CustomText(
                titleTxt,
                color: Theme.of(context).colorScheme.blackColor,
              ),
            ),
            const Spacer(),
            CustomSizedBox(
              height: 25,
              width: 25,
              child: CustomCheckBox(
                value: isChecked[indexVal],
                onChanged: (bool? checked) {
                  setState(
                    () {
                      pickedLocalImages = pickedLocalImages;
                      isChecked[indexVal] = checked!;
                      // show/hide timePicker
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget setTimerPickerRow(int indexVal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomRoundedButton(
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
          widthPercentage: 0.3,
          // format time as AM/PM
          buttonTitle: DateFormat.jm().format(
            DateTime.parse(
              "2020-07-20T${selectedStartTime[indexVal].hour.toString().padLeft(2, "0")}:${selectedStartTime[indexVal].minute.toString().padLeft(2, "0")}:00",
            ),
          ),
          showBorder: true,
          borderColor: Theme.of(context).colorScheme.lightGreyColor,
          radius: 10,
          textSize: 16,
          titleColor: Theme.of(context).colorScheme.blackColor,
          onTap: () {
            _selectTime(
              selectedTime: selectedStartTime[indexVal],
              indexVal: indexVal,
              isTimePickerForStarTime: true,
            );
          },
        ),
        CustomText(
          'toLbl'.translate(context: context),
          color: Theme.of(context).colorScheme.lightGreyColor,
          fontWeight: FontWeight.w400,
        ),
        CustomRoundedButton(
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
          widthPercentage: 0.3,
          buttonTitle:
              "${DateFormat.jm().format(DateTime.parse("2020-07-20T${selectedEndTime[indexVal].hour.toString().padLeft(2, "0")}:${selectedEndTime[indexVal].minute.toString().padLeft(2, "0")}:00"))} ",
          showBorder: true,
          borderColor: Theme.of(context).colorScheme.lightGreyColor,
          textSize: 16,
          titleColor: Theme.of(context).colorScheme.blackColor,
          onTap: () {
            _selectTime(
              selectedTime: selectedEndTime[indexVal],
              indexVal: indexVal,
              isTimePickerForStarTime: false,
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectTime({
    required TimeOfDay selectedTime,
    required int indexVal,
    required bool isTimePickerForStarTime,
  }) async {
    try {
      final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedTime, //TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        },
      );
      //

      if (isTimePickerForStarTime) {
        //
        final bool isStartTimeBeforeOfEndTime = timeOfDay!.hour <=
                (selectedEndTime[indexVal].hour == 00
                    ? 24
                    : selectedEndTime[indexVal].hour) &&
            timeOfDay.minute <= selectedEndTime[indexVal].minute;
        //
        if (isStartTimeBeforeOfEndTime) {
          selectedStartTime[indexVal] = timeOfDay;
        } else if (mounted) {
          UiUtils.showMessage(
            context,
            message: 'companyStartTimeCanNotBeAfterOfEndTime'
                .translate(context: context),
            type: ToastificationType.warning,
          );
        }
      } else {
        //
        final bool isEndTimeAfterOfStartTime = timeOfDay!.hour >=
                (selectedStartTime[indexVal].hour == 00
                    ? 24
                    : selectedStartTime[indexVal].hour) &&
            timeOfDay.minute >= selectedStartTime[indexVal].minute;
        //
        if (isEndTimeAfterOfStartTime) {
          selectedEndTime[indexVal] = timeOfDay;
        } else {
          if (mounted) {
            UiUtils.showMessage(
              context,
              message: 'companyEndTimeCanNotBeBeforeOfStartTime'
                  .translate(context: context),
              type: ToastificationType.warning,
            );
          }
        }
      }
    } catch (_) {}

    setState(() {
      pickedLocalImages = pickedLocalImages;
    });
  }

  Widget idImageWidget({
    required String titleTxt,
    required String imageHintText,
    required PickImage imageController,
    required String imageType,
    required String oldImage,
  }) {
    return Column(
      children: [
        CustomText(
          titleTxt,
        ),
        const CustomSizedBox(height: 5),
        imagePicker(
          imageType: imageType,
          imageController: imageController,
          oldImage: oldImage,
          hintLabel: imageHintText,
          width: 100,
        ),
      ],
    );
  }

  Widget imagePicker({
    required PickImage imageController,
    required String oldImage,
    required String hintLabel,
    required String imageType,
    double? width,
  }) {
    return imageController.ListenImageChange(
      (BuildContext context, image) {
        if (image == null) {
          if (pickedLocalImages[imageType] != '') {
            return GestureDetector(
              onTap: () {
                showCameraAndGalleryOption(
                  imageController: imageController,
                  title: hintLabel,
                );
              },
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CustomSizedBox(
                      height: 200,
                      width: width ?? MediaQuery.sizeOf(context).width,
                      child: Image.file(
                        File(pickedLocalImages[imageType]!),
                      ),
                    ),
                  ),
                  CustomSizedBox(
                    height: 210,
                    width: (width ?? MediaQuery.sizeOf(context).width - 5) + 5,
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
          if (oldImage.isNotEmpty) {
            return GestureDetector(
              onTap: () {
                showCameraAndGalleryOption(
                  imageController: imageController,
                  title: hintLabel,
                );
              },
              child: Stack(
                children: [
                  CustomSizedBox(
                    height: 210,
                    width: width ?? MediaQuery.sizeOf(context).width,
                    child: DashedRect(
                      color: Theme.of(context).colorScheme.blackColor,
                      strokeWidth: 2.0,
                      gap: 4.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CustomSizedBox(
                      height: 200,
                      width: (width ?? MediaQuery.sizeOf(context).width) - 5.0,
                      child: CustomCachedNetworkImage(imageUrl: oldImage),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: CustomInkWellContainer(
              onTap: () {
                showCameraAndGalleryOption(
                  imageController: imageController,
                  title: hintLabel,
                );
              },
              child: SetDottedBorderWithHint(
                height: 100,
                width: width ?? MediaQuery.sizeOf(context).width - 35,
                radius: 7,
                str: hintLabel,
                strPrefix: '',
                borderColor: Theme.of(context).colorScheme.blackColor,
              ),
            ),
          );
        }
        //
        pickedLocalImages[imageType] = image?.path;
        //
        return GestureDetector(
          onTap: () {
            showCameraAndGalleryOption(
              imageController: imageController,
              title: hintLabel,
            );
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: CustomSizedBox(
                  height: 200,
                  width: width ?? MediaQuery.sizeOf(context).width,
                  child: Image.file(
                    File(image.path),
                  ),
                ),
              ),
              CustomSizedBox(
                height: 210,
                width: (width ?? MediaQuery.sizeOf(context).width - 5) + 5,
                child: DashedRect(
                  color: Theme.of(context).colorScheme.blackColor,
                  strokeWidth: 2.0,
                  gap: 4.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDropDown(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    required String initialValue,
    String? value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title,
          color: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.w400,
        ),
        const CustomSizedBox(
          height: 10,
        ),
        CustomFormDropdown(
          onTap: () {
            onTap.call();
          },
          initialTitle: initialValue,
          selectedValue: value,
          validator: (String? p0) {
            return Validator.nullCheck(context, p0);
          },
        ),
      ],
    );
  }

  Future showCameraAndGalleryOption({
    required PickImage imageController,
    required String title,
  }) {
    return UiUtils.showModelBottomSheets(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      context: context,
      child: ShowImagePickerOptionBottomSheet(
        title: title,
        onCameraButtonClick: () {
          imageController.pick(source: ImageSource.camera);
        },
        onGalleryButtonClick: () {
          imageController.pick(source: ImageSource.gallery);
        },
      ),
    );
  }

  Future<void> selectCompanyTypes() async {
    final List<Map<String, dynamic>> itemList = [
      {
        'title': 'Individual'.translate(context: context),
        'id': '0',
        "isSelected": selectCompanyType?['value'] == "0"
      },
      {
        'title': 'Organisation'.translate(context: context),
        'id': '1',
        "isSelected": selectCompanyType?['value'] == "1"
      }
    ];
    UiUtils.showModelBottomSheets(
      context: context,
      child: SelectableListBottomSheet(
          bottomSheetTitle: "selectType", itemList: itemList),
    ).then((value) {
      if (value != null) {
        selectCompanyType = {
          'title': value["selectedItemName"],
          'value': value["selectedItemId"]
        };

        if (value?['selectedItemName'] == 'Individual') {
          numberOfMemberController.text = '1';
          isIndividualType = true;
        } else {
          isIndividualType = false;
        }
        setState(() {
          pickedLocalImages = pickedLocalImages;
        });
      }
    });
  }
}
