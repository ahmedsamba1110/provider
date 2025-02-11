import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:open_filex/open_filex.dart';

import '../../../app/generalImports.dart';

class ManageService extends StatefulWidget {
  const ManageService({
    super.key,
    this.service,
  });

  final ServiceModel? service;

  @override
  ManageServiceState createState() => ManageServiceState();

  static Route<ManageService> route(RouteSettings routeSettings) {
    final Map? arguments = routeSettings.arguments as Map?;

    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (BuildContext context) => CreateServiceCubit(),
        child: ManageService(service: arguments?['service']),
      ),
    );
  }
}

class ManageServiceState extends State<ManageService> {
  int currIndex = 1;
  int totalForms = 4;

  //form 1
  bool isOnSiteAllowed = false;
  bool isPayLaterAllowed = true;
  bool isCancelAllowed = false;
  bool isDoorStepAllowed = false;
  bool isStoreAllowed = false;
  bool serviceStatus = true;

  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();

  ScrollController scrollController = ScrollController();

  late TextEditingController serviceTitleController = TextEditingController(
    text: widget.service?.title,
  );
  late TextEditingController serviceTagController = TextEditingController();
  late TextEditingController serviceDescrController = TextEditingController(
    text: widget.service?.description,
  );

  late TextEditingController cancelBeforeController = TextEditingController(
    text: widget.service?.cancelableTill,
  );
  FocusNode serviceTitleFocus = FocusNode();
  FocusNode serviceTagFocus = FocusNode();
  FocusNode serviceDescrFocus = FocusNode();

  FocusNode cancelBeforeFocus = FocusNode();

  late int selectedCategory = 0;
  String? selectedCategoryTitle;
  late int selectedTax = 0;
  String selectedTaxTitle = '';
  late int selectedSubCategory = 0;
  Map? selectedPriceType;

  //form 2
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

  late TextEditingController priceController =
      TextEditingController(text: widget.service?.price);
  late TextEditingController discountPriceController =
      TextEditingController(text: widget.service?.discountedPrice);
  late TextEditingController memReqTaskController =
      TextEditingController(text: widget.service?.numberOfMembersRequired);
  late TextEditingController durationTaskController =
      TextEditingController(text: widget.service?.duration);
  late TextEditingController qtyAllowedTaskController =
      TextEditingController(text: widget.service?.maxQuantityAllowed);

  FocusNode priceFocus = FocusNode();
  FocusNode discountPriceFocus = FocusNode();
  FocusNode memReqTaskFocus = FocusNode();
  FocusNode durationTaskFocus = FocusNode();
  FocusNode qtyAllowedTaskFocus = FocusNode();

  List<String> tagsList = [];
  List<Map<String, dynamic>> finalTagList = [];
  PickImage imagePicker = PickImage();

  Map priceTypeFilter = {'0': 'included', '1': 'excluded'};
  String pickedServiceImage = '';
  ValueNotifier<List<String>> pickedOtherImages = ValueNotifier([]);
  ValueNotifier<List<String>> pickedFiles = ValueNotifier([]);
  bool fileTapLoading = false;

  final GlobalKey<FormState> formKey3 = GlobalKey<FormState>();
  ValueNotifier<List<TextEditingController>> faqQuestionTextEditors =
      ValueNotifier([]);
  ValueNotifier<List<TextEditingController>> faqAnswersTextEditors =
      ValueNotifier([]);

  final HtmlEditorController controller = HtmlEditorController();
  String? longDescription;

  @override
  void dispose() {
    pickedOtherImages.dispose();
    pickedFiles.dispose();
    faqAnswersTextEditors.dispose();
    faqQuestionTextEditors.dispose();
    serviceTitleController.dispose();
    serviceTagController.dispose();
    serviceDescrController.dispose();
    cancelBeforeController.dispose();
    serviceTitleFocus.dispose();
    serviceTagFocus.dispose();
    serviceDescrFocus.dispose();
    cancelBeforeFocus.dispose();
    priceController.dispose();
    discountPriceController.dispose();
    memReqTaskController.dispose();
    durationTaskController.dispose();
    qtyAllowedTaskController.dispose();
    priceFocus.dispose();
    discountPriceFocus.dispose();
    memReqTaskFocus.dispose();
    durationTaskFocus.dispose();
    qtyAllowedTaskFocus.dispose();
    super.dispose();
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

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () {
        if (context.read<ProviderDetailsCubit>().getProviderType() == "0") {
          memReqTaskController.text = "1";
        }
      },
    );
    selectedCategory = int.parse(widget.service?.categoryId ?? '0');
    selectedCategoryTitle = widget.service?.categoryName;

    selectedTax = int.parse(widget.service?.taxId ?? '0');
    selectedTaxTitle = widget.service?.taxId == null
        ? ''
        : '${widget.service?.taxTitle} (${widget.service?.taxPercentage}%)';

    if (widget.service?.isCancelable != null) {
      isCancelAllowed = widget.service?.isCancelable == '0' ? false : true;
    }
    if (widget.service?.isPayLaterAllowed != null) {
      isPayLaterAllowed =
          widget.service?.isPayLaterAllowed == '0' ? false : true;
    }

    if (widget.service?.isDoorStepAllowed != null) {
      isDoorStepAllowed =
          widget.service?.isDoorStepAllowed == '0' ? false : true;
    }
    if (widget.service?.isStoreAllowed != null) {
      isStoreAllowed = widget.service?.isStoreAllowed == '0' ? false : true;
    }
    if (widget.service?.status != null || widget.service?.status != "") {
      serviceStatus = widget.service?.status == "Disable" ? false : true;
    }

    if (widget.service?.tags?.isEmpty ?? false) {
      tagsList = [];
    } else {
      tagsList = widget.service?.tags?.split(',') ?? [];
    }

    if (widget.service != null) {
      if (widget.service!.faqs != null) {
        for (int i = 0; i < widget.service!.faqs!.length; i++) {
          faqQuestionTextEditors.value.add(
            TextEditingController(
              text: widget.service!.faqs![i].question,
            ),
          );
          faqAnswersTextEditors.value.add(
            TextEditingController(
              text: widget.service!.faqs![i].answer,
            ),
          );
        }
      }
      if (widget.service!.longDescription != null) {
        longDescription = widget.service!.longDescription;
      }
    }

    if (faqQuestionTextEditors.value.isEmpty ||
        faqAnswersTextEditors.value.isEmpty) {
      faqQuestionTextEditors.value.add(TextEditingController());
      faqAnswersTextEditors.value.add(TextEditingController());
    }
  }

  @override
  void didChangeDependencies() {
    if (widget.service?.taxType == 'included') {
      selectedPriceType = {
        'title': 'taxIncluded'.translate(context: context),
        'value': '0'
      };
    } else {
      selectedPriceType = {
        'title': 'taxExcluded'.translate(context: context),
        'value': '1'
      };
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (tagsList.isNotEmpty) {
      finalTagList = List.generate(
        tagsList.length,
        (int index) {
          return {
            'id': index,
            'text': tagsList[index],
          };
        },
      );
    }

    return PopScope(
      canPop: currIndex == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        } else {
          if (currIndex != 1) {
            setState(() {
              currIndex--;
            });
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: AppBar(
          elevation: 1,
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.secondaryColor,
          surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
          title: CustomText(
            widget.service?.id != null
                ? 'editServiceLabel'.translate(context: context)
                : 'createServiceTxtLbl'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.bold,
          ),
          leading: CustomBackArrow(
            onTap: () {
              if (currIndex != 1) {
                setState(() {
                  currIndex--;
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          actions: <Widget>[
            PageNumberIndicator(currentIndex: currIndex, total: totalForms)
          ],
        ),
        bottomNavigationBar: bottomNavigation(),
        body: screenBuilder(currIndex),
      ),
    );
  }

  Widget screenBuilder(int currentPage) {
    Widget currentForm = form1();
    switch (currIndex) {
      case 4:
        currentForm = form4();
        break;
      case 3:
        currentForm = form3();
        break;
      case 2:
        currentForm = form2();
        break;
      default:
        currentForm = form1();
        break;
    }
    return currIndex == 4
        ? currentForm
        : SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.all(15),
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
          CustomTextFormField(
            bottomPadding: 10,
            labelText: 'serviceTitleLbl'.translate(context: context),
            controller: serviceTitleController,
            currNode: serviceTitleFocus,
            validator: (String? value) {
              return Validator.nullCheck(context, value);
            },
            nextFocus: serviceTagFocus,
          ),
          CustomTextFormField(
            labelText: 'serviceTagLbl'.translate(context: context),
            controller: serviceTagController,
            currNode: serviceTagFocus,
            forceUnfocus: false,
            bottomPadding: finalTagList.isEmpty ? 15 : 0,
            onSubmit: () {
              if (serviceTagController.text.isNotEmpty) {
                tagsList.add(serviceTagController.text);
              }
              serviceTagController.text = '';
              setState(() {});
            },
            callback: () {},
          ),
          Wrap(
            children: finalTagList.map(
              (Map<String, dynamic> item) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10, top: 5),
                  child: CustomSizedBox(
                    height: 35,
                    child: Chip(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryColor,
                      label: Text(item['text']),
                      onDeleted: () {
                        if (tagsList.isEmpty) {
                          tagsList.clear();
                          finalTagList.clear();
                          setState(() {});
                          return;
                        }
                        tagsList.removeAt(item['id']);
                        if (tagsList.isEmpty) {
                          finalTagList.clear();
                        }
                        setState(() {});
                      },
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.blackColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(UiUtils.borderRadiusOf10),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.lightGreyColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          if (tagsList.isNotEmpty) const CustomSizedBox(height: 15),
          CustomTextFormField(
            labelText: 'serviceDescrLbl'.translate(context: context),
            controller: serviceDescrController,
            expands: true,
            minLines: 5,
            currNode: serviceDescrFocus,
            validator: (String? value) {
              return Validator.nullCheck(context, value);
            },
            textInputType: TextInputType.multiline,
          ),
          _selectDropdown(
            label: 'selectCategoryLbl'.translate(context: context),
            title: selectedCategoryTitle ?? "",
            onSelect: () {
              selectCategoryBottomSheet();
            },
            validator: (String? value) {
              if (selectedCategoryTitle == null) {
                return 'pleaseChooseCategory'.translate(context: context);
              }
              return null;
            },
          ),
          if (context
              .read<FetchSystemSettingsCubit>()
              .isPayLaterAllowedByAdmin()) ...[
            setTitleAndSwitch(
              titleText: 'payLaterAllowedLbl'.translate(context: context),
              isAllowed: isPayLaterAllowed,
            ),
          ],
          if (context.read<FetchSystemSettingsCubit>().isStoreOptionAvailable())
            setTitleAndSwitch(
              titleText: 'atStoreAllowed'.translate(context: context),
              isAllowed: isStoreAllowed,
            ),
          if (context
              .read<FetchSystemSettingsCubit>()
              .isDoorstepOptionAvailable())
            setTitleAndSwitch(
              titleText: 'atDoorstepAllowed'.translate(context: context),
              isAllowed: isDoorStepAllowed,
            ),
          setTitleAndSwitch(
            titleText: 'statusLbl'.translate(context: context),
            isAllowed: serviceStatus,
          ),
          setTitleAndSwitch(
            titleText: 'isCancelableLbl'.translate(context: context),
            isAllowed: isCancelAllowed,
          ),
          if (isCancelAllowed) ...[
            const CustomSizedBox(height: 10),
            CustomTextFormField(
              labelText: 'cancelableBeforeLbl'.translate(context: context),
              controller: cancelBeforeController,
              currNode: cancelBeforeFocus,
              textInputType: TextInputType.number,
              inputFormatters: UiUtils.allowOnlyDigits(),
              hintText: '30',
              validator: (String? value) {
                return Validator.nullCheck(context, value);
              },
              prefix: minutesPrefixWidget(),
            )
          ]
        ],
      ),
    );
  }

  Widget _selectDropdown({
    required String title,
    required String label,
    VoidCallback? onSelect,
    String? Function(String?)? validator,
  }) {
    return CustomTextFormField(
      controller: TextEditingController(
        text: title,
      ),
      suffixIcon: const Icon(Icons.arrow_drop_down_outlined),
      validator: validator,
      callback: onSelect,
      isReadOnly: true,
      hintText: label,
      labelText: label,
    );
  }

  Widget _fileContainer({required String filePath, bool isNetwork = false}) {
    return CustomInkWellContainer(
      onTap: () async {
        if (!fileTapLoading) {
          fileTapLoading = true;
          if (isNetwork) {
            launchUrl(
              Uri.parse(filePath),
              mode: LaunchMode.externalApplication,
            );
          } else {
            OpenFilex.open(filePath);
          }
          fileTapLoading = false;
        }
      },
      child: CustomSizedBox(
        width: 150,
        height: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.file_present_outlined,
            ),
            const CustomSizedBox(
              height: 3,
            ),
            Text(
              filePath.extractFileName(),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.blackColor,
              ),
            ),
          ],
        ),
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
            'serviceImgLbl'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          const CustomSizedBox(height: 10),
          imagePicker.ListenImageChange(
            (BuildContext context, image) {
              if (image == null) {
                if (pickedServiceImage != '') {
                  return GestureDetector(
                    onTap: () {
                      showCameraAndGalleryOption(
                        imageController: imagePicker,
                        title: 'serviceImgLbl'.translate(context: context),
                      );
                    },
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: CustomSizedBox(
                            height: 200,
                            width: MediaQuery.sizeOf(context).width,
                            child: Image.file(
                              File(pickedServiceImage),
                            ),
                          ),
                        ),
                        CustomSizedBox(
                          height: 210,
                          width: (MediaQuery.sizeOf(context).width - 5) + 5,
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
                if (widget.service?.imageOfTheService != null) {
                  return GestureDetector(
                    onTap: () {
                      showCameraAndGalleryOption(
                        imageController: imagePicker,
                        title: 'serviceImgLbl'.translate(context: context),
                      );
                    },
                    child: Stack(
                      children: [
                        CustomSizedBox(
                          height: 210,
                          width: MediaQuery.sizeOf(context).width,
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
                            width: (MediaQuery.sizeOf(context).width) - 5.0,
                            child: CustomCachedNetworkImage(
                              imageUrl: widget.service?.imageOfTheService ?? '',
                            ),
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
                        imageController: imagePicker,
                        title: 'serviceImgLbl'.translate(context: context),
                      );
                    },
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
              //
              pickedServiceImage = image?.path;
              //
              return GestureDetector(
                onTap: () {
                  showCameraAndGalleryOption(
                    imageController: imagePicker,
                    title: 'serviceImgLbl'.translate(context: context),
                  );
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: CustomSizedBox(
                        height: 200,
                        width: MediaQuery.sizeOf(context).width,
                        child: Image.file(
                          File(image.path),
                        ),
                      ),
                    ),
                    CustomSizedBox(
                      height: 210,
                      width: (MediaQuery.sizeOf(context).width - 5) + 5,
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
          ),
          const CustomSizedBox(height: 10),
          CustomText(
            'otherImages'.translate(context: context),
            color: Theme.of(context).colorScheme.blackColor,
          ),
          const CustomSizedBox(height: 10),
          ValueListenableBuilder(
            valueListenable: pickedOtherImages,
            builder: (BuildContext context, Object? value, Widget? child) {
              final bool isThereAnyImage = pickedOtherImages.value.isNotEmpty ||
                  (widget.service != null &&
                      widget.service!.otherImages != null &&
                      widget.service!.otherImages!.isNotEmpty);
              return CustomSizedBox(
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
                              if (widget.service != null &&
                                  widget.service!.otherImages!.isNotEmpty) {
                                widget.service!.otherImages = null;
                              }
                              for (int i = 0; i < result.files.length; i++) {
                                if (!pickedOtherImages.value
                                    .contains(result.files[i].path)) {
                                  //assigning new list, because listener will not notify if we add the values only to the list
                                  pickedOtherImages.value =
                                      List.from(pickedOtherImages.value)
                                        ..insert(0, result.files[i].path!);
                                }
                              }
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
                                    ? widget.service != null &&
                                            widget.service!.otherImages !=
                                                null &&
                                            widget.service!.otherImages!
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
                      if (isThereAnyImage && pickedOtherImages.value.isNotEmpty)
                        for (int i = 0; i < pickedOtherImages.value.length; i++)
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
                                          .withValues(alpha: 0.4),
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
                          widget.service != null &&
                          widget.service!.otherImages != null &&
                          widget.service!.otherImages!.isNotEmpty)
                        for (int i = 0;
                            i < widget.service!.otherImages!.length;
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
                                imageUrl: widget.service!.otherImages![i],
                                fit: BoxFit.fitHeight,
                              ),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                'files'.translate(context: context),
                color: Theme.of(context).colorScheme.blackColor,
              ),
              CustomText(
                " ${'onlyPdfAndDocAllowed'.translate(context: context)}",
                color: Theme.of(context).colorScheme.blackColor,
                fontSize: 12,
              ),
            ],
          ),
          const CustomSizedBox(height: 10),
          ValueListenableBuilder(
            valueListenable: pickedFiles,
            builder: (BuildContext context, Object? value, Widget? child) {
              final bool isThereAnyFile = pickedFiles.value.isNotEmpty ||
                  (widget.service != null &&
                      widget.service!.files != null &&
                      widget.service!.files!.isNotEmpty);
              return CustomSizedBox(
                height: 100,
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
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'doc', 'docx', 'docm'],
                            );
                            if (result != null) {
                              if (widget.service != null &&
                                  widget.service!.files!.isNotEmpty) {
                                widget.service!.files = null;
                              }
                              for (int i = 0; i < result.files.length; i++) {
                                if (!pickedFiles.value
                                    .contains(result.files[i].path)) {
                                  //assigning new list, because listener will not notify if we add the values only to the list
                                  pickedFiles.value =
                                      List.from(pickedFiles.value)
                                        ..insert(0, result.files[i].path!);
                                }
                              }
                            } else {
                              // User canceled the picker
                            }
                          } catch (_) {}
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: isThereAnyFile ? 5 : 0,
                          ),
                          child: SetDottedBorderWithHint(
                            height: double.maxFinite,
                            customIconWidget: Icon(
                              Icons.file_open_outlined,
                              color:
                                  Theme.of(context).colorScheme.lightGreyColor,
                              size: 20,
                            ),
                            width: isThereAnyFile
                                ? 100
                                : MediaQuery.sizeOf(context).width - 35,
                            radius: 7,
                            str:
                                "${(isThereAnyFile ? widget.service != null && widget.service!.files != null && widget.service!.files!.isNotEmpty ? "changeFiles" : "addFiles" : "pickFiles").translate(context: context)}  ",
                            strPrefix: '',
                            borderColor:
                                Theme.of(context).colorScheme.blackColor,
                          ),
                        ),
                      ),
                      if (isThereAnyFile && pickedFiles.value.isNotEmpty)
                        for (int i = 0; i < pickedFiles.value.length; i++)
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
                                  child: _fileContainer(
                                    filePath: pickedFiles.value[i],
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional.topEnd,
                                  child: CustomInkWellContainer(
                                    onTap: () {
                                      //assigning new list, because listener will not notify if we remove the values only to the list
                                      pickedFiles.value =
                                          List.from(pickedFiles.value)
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
                      if (isThereAnyFile &&
                          widget.service != null &&
                          widget.service!.files != null &&
                          widget.service!.files!.isNotEmpty)
                        for (int i = 0; i < widget.service!.files!.length; i++)
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
                              child: _fileContainer(
                                filePath: widget.service!.files![i],
                                isNetwork: true,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              );
            },
          ),
          const CustomSizedBox(height: 20),
          CustomTextFormField(
            controller:
                TextEditingController(text: selectedPriceType?["title"] ?? ""),
            isReadOnly: true,
            labelText: 'priceType'.translate(context: context),
            hintText: 'priceType'.translate(context: context),
            bottomPadding: 0,
            callback: () {
              final List<Map<String, dynamic>> values = [
                {
                  'title': 'taxIncluded'.translate(context: context),
                  'id': '0',
                  "isSelected": selectedPriceType?["value"] == "0"
                },
                {
                  'title': 'taxExcluded'.translate(context: context),
                  'id': '1',
                  "isSelected": selectedPriceType?["value"] == "1"
                }
              ];

              UiUtils.showModelBottomSheets(
                      context: context,
                      child: SelectableListBottomSheet(
                          bottomSheetTitle: "priceType", itemList: values))
                  .then((value) {
                if (value != null) {
                  selectedPriceType = {
                    'title': value["selectedItemName"],
                    'value': value["selectedItemId"]
                  };

                  setState(() {});
                }
              });
            },
            suffixIcon: const Icon(Icons.arrow_drop_down_outlined),
          ),
          const CustomSizedBox(height: 15),
          CustomTextFormField(
            bottomPadding: 0,
            controller: TextEditingController(text: selectedTaxTitle),
            suffixIcon: const Icon(
              Icons.arrow_drop_down_outlined,
            ),
            hintText: 'selectTax'.translate(context: context),
            labelText: 'selectTax'.translate(context: context),
            isReadOnly: true,
            validator: (String? value) {
              if (selectedTaxTitle == '') {
                return 'pleaseSelectTax'.translate(context: context);
              }
              return null;
            },
            callback: () {
              selectTaxesBottomSheet();
            },
          ),
          const CustomSizedBox(height: 10),
          setPriceAndDiscountedPrice(),
          CustomTextFormField(
            bottomPadding: 10,
            labelText: 'membersForTaskLbl'.translate(context: context),
            controller: memReqTaskController,
            currNode: memReqTaskFocus,
            inputFormatters: UiUtils.allowOnlyDigits(),
            nextFocus: durationTaskFocus,
            //if provider type is individual then they can not edit number of members
            isReadOnly:
                context.read<ProviderDetailsCubit>().getProviderType() == "0",
            validator: (String? value) {
              return Validator.nullCheck(context, value);
            },
            textInputType: TextInputType.number,
          ),
          CustomTextFormField(
            bottomPadding: 10,
            labelText: 'durationForTaskLbl'.translate(context: context),
            controller: durationTaskController,
            currNode: durationTaskFocus,
            nextFocus: qtyAllowedTaskFocus,
            inputFormatters: UiUtils.allowOnlyDigits(),
            hintText: '120',
            validator: (String? value) {
              return Validator.nullCheck(context, value);
            },
            prefix: minutesPrefixWidget(),
            textInputType: TextInputType.number,
          ),
          CustomTextFormField(
            bottomPadding: 10,
            labelText: 'maxQtyAllowedLbl'.translate(context: context),
            controller: qtyAllowedTaskController,
            inputFormatters: UiUtils.allowOnlyDigits(),
            currNode: qtyAllowedTaskFocus,
            validator: (String? value) {
              return Validator.nullCheck(context, value);
            },
            textInputType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _singleQuestionItem({required index}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CustomTextFormField(
                  bottomPadding: 0,
                  labelText:
                      "${'question'.translate(context: context)} ${index + 1}",
                  controller: faqQuestionTextEditors.value[index],
                  validator: (String? value) {
                    return Validator.nullCheck(context, value);
                  },
                ),
              ),
              index == 0
                  ? IconButton(
                      onPressed: () {
                        if (faqQuestionTextEditors.value.last.text
                                .trim()
                                .isEmpty ||
                            faqAnswersTextEditors.value.last.text
                                .trim()
                                .isEmpty) {
                          UiUtils.showMessage(
                            context,
                            message: "fillLastFAQToAddMore"
                                .translate(context: context),
                            type: ToastificationType.warning,
                          );
                        } else {
                          //assigning new list, because listener will not notify if we add the values only to the list
                          faqQuestionTextEditors.value =
                              List.from(faqQuestionTextEditors.value)
                                ..add(TextEditingController());
                          faqAnswersTextEditors.value =
                              List.from(faqAnswersTextEditors.value)
                                ..add(TextEditingController());
                        }
                      },
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.blackColor,
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        //assigning new list, because listener will not notify if we add the values only to the list
                        faqQuestionTextEditors.value =
                            List.from(faqQuestionTextEditors.value)
                              ..removeAt(index);
                        faqAnswersTextEditors.value =
                            List.from(faqAnswersTextEditors.value)
                              ..removeAt(index);
                      },
                      icon: const Icon(
                        Icons.close_outlined,
                        color: AppColors.redColor,
                      ),
                    ),
            ],
          ),
        ),
        CustomTextFormField(
          labelText: "${'answer'.translate(context: context)} ${index + 1}",
          bottomPadding: 10,
          controller: faqAnswersTextEditors.value[index],
          textInputType: TextInputType.multiline,
          validator: (String? value) {
            return Validator.nullCheck(context, value);
          },
        ),
        if (index != faqQuestionTextEditors.value.length - 1)
          const CustomDivider(),
        const CustomSizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget form3() {
    return Form(
      key: formKey3,
      child: ValueListenableBuilder(
        valueListenable: faqQuestionTextEditors,
        builder: (context, value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomText(
                'faqs'.translate(context: context),
                color: Theme.of(context).colorScheme.blackColor,
              ),
              const CustomSizedBox(
                height: 15,
              ),
              ...List.generate(
                faqQuestionTextEditors.value.length,
                (index) {
                  return _singleQuestionItem(index: index);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget form4() {
    return BlocConsumer<CreateServiceCubit, CreateServiceCubitState>(
      listener: (BuildContext context, CreateServiceCubitState state) {
        if (state is CreateServiceFailure) {
          UiUtils.showMessage(context,
              message: state.errorMessage.translate(context: context),
              type: ToastificationType.error);
        }

        if (state is CreateServiceSuccess) {
          UiUtils.showMessage(
            context,
            message: widget.service?.id != null
                ? 'serviceEditedSuccessfully'.translate(context: context)
                : 'serviceCreatedSuccessfully'.translate(context: context),
            type: ToastificationType.success,
            onMessageClosed: () {
              Navigator.pop(context);
              context.read<FetchServicesCubit>().fetchServices();
            },
          );
        }
      },
      builder: (BuildContext context, CreateServiceCubitState state) {
        return CustomSizedBox(
          height: double.maxFinite,
          child: CustomHTMLEditor(
            controller: controller,
            initialHTML: longDescription,
            hint: 'describeServiceInDetail'.translate(context: context),
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

  Widget setPriceAndDiscountedPrice() {
    return Row(
      children: [
        Flexible(
          child: CustomTextFormField(
            bottomPadding: 10,
            labelText: 'priceLbl'.translate(context: context),
            allowOnlySingleDecimalPoint: true,
            controller: priceController,
            currNode: priceFocus,
            prefix: Padding(
              padding: const EdgeInsetsDirectional.all(15.0),
              child: CustomText(
                UiUtils.systemCurrency ?? '',
                fontSize: 14.0,
                color: Theme.of(context).colorScheme.blackColor,
              ),
            ),
            nextFocus: discountPriceFocus,
            validator: (String? value) {
              return Validator.nullCheck(context, value);
            },
            textInputType: TextInputType.number,
          ),
        ),
        const CustomSizedBox(width: 20),
        Flexible(
          child: CustomTextFormField(
            bottomPadding: 10,
            labelText: 'discountPriceLbl'.translate(context: context),
            controller: discountPriceController,
            currNode: discountPriceFocus,
            allowOnlySingleDecimalPoint: true,
            prefix: Padding(
              padding: const EdgeInsetsDirectional.all(15.0),
              child: CustomText(
                UiUtils.systemCurrency ?? '',
                fontSize: 14.0,
                color: Theme.of(context).colorScheme.blackColor,
              ),
            ),
            validator: (String? value) {
              if (value != null && value.isNotEmpty) {
                if (num.parse(value) > num.parse(priceController.text)) {
                  return 'discountIsMoreThanPrice'.translate(context: context);
                } else if (num.parse(value) ==
                    num.parse(priceController.text)) {
                  return 'discountPriceCanNotBeEqualToPrice'
                      .translate(context: context);
                }
              }
              return Validator.nullCheck(context, value);
            },
            textInputType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget minutesPrefixWidget() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 10, end: 10),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              'minutesLbl'.translate(context: context),
              fontSize: 15.0,
              color: Theme.of(context).colorScheme.blackColor,
            ),
            VerticalDivider(
              color: Theme.of(context).colorScheme.blackColor.withAlpha(150),
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }

  Future selectCategoryBottomSheet() {
    return UiUtils.showModelBottomSheets(
      context: context,
      enableDrag: true,
      child: BlocBuilder<FetchServiceCategoryCubit, FetchServiceCategoryState>(
        builder: (BuildContext context, FetchServiceCategoryState state) {
          if (state is FetchServiceCategoryFailure) {
            return Center(
              child: ErrorContainer(
                showRetryButton: false,
                onTapRetry: () {},
                errorMessage: state.errorMessage.translate(context: context),
              ),
            );
          }
          if (state is FetchServiceCategorySuccess) {
            if (state.serviceCategories.isEmpty) {
              return NoDataContainer(
                titleKey: 'noDataFound'.translate(context: context),
              );
            }

            final List<Map<String, dynamic>> values =
                state.serviceCategories.map((element) {
              return {
                "title": element.name,
                "id": element.id,
                "isSelected": selectedCategory ==
                    int.parse(
                      element.id ?? '0',
                    )
              };
            }).toList();

            return SelectableListBottomSheet(
              bottomSheetTitle: "selectCategoryLbl",
              itemList: values,
            );
          }
          return Center(
            child: CustomCircularProgressIndicator(
              color: AppColors.whiteColors,
            ),
          );
        },
      ),
    ).then((value) {
      if (value != null) {
        selectedCategory = int.parse(
          value["selectedItemId"].toString(),
        );
        selectedCategoryTitle = value["selectedItemName"];
        setState(() {});
      }
    });
  }

  Future selectTaxesBottomSheet() {
    return UiUtils.showModelBottomSheets(
      context: context,
      enableDrag: true,
      child: BlocBuilder<FetchTaxesCubit, FetchTaxesState>(
        builder: (BuildContext context, FetchTaxesState state) {
          if (state is FetchTaxesFailure) {
            return Center(
              child: ErrorContainer(
                showRetryButton: false,
                onTapRetry: () {},
                errorMessage: state.errorMessage,
              ),
            );
          }
          if (state is FetchTaxesSuccess) {
            if (state.taxes.isEmpty) {
              return NoDataContainer(
                titleKey: 'noDataFound'.translate(context: context),
              );
            }
            final List<Map<String, dynamic>> itemList = [];
            state.taxes.forEach((element) {
              itemList.add({
                "title": "${element.title!} (${element.percentage}%)",
                "id": element.id,
                "isSelected": selectedTax == int.parse(element.id ?? '0'),
              });
            });

            return SelectableListBottomSheet(
                bottomSheetTitle: "chooseTaxes", itemList: itemList);
          }
          return Center(
            child: CustomCircularProgressIndicator(
              color: AppColors.whiteColors,
            ),
          );
        },
      ),
    ).then((value) {
      if (value != null) {
        selectedTax = int.parse(value["selectedItemId"]);
        selectedTaxTitle = value["selectedItemName"];
        setState(() {});
      }
    });
  }

  ListTile listWidget({
    required String title,
    VoidCallback? onTap,
    required bool isSelected,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10)),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.blackColor,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
      onTap: onTap,
      trailing: //remove int.parse while using model
          CustomContainer(
        height: 25,
        width: 25,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.blackColor : null,
          border:
              Border.all(color: Theme.of(context).colorScheme.lightGreyColor),
          shape: BoxShape.circle,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.secondaryColor,
              )
            : const CustomSizedBox(
                height: 25,
                width: 25,
              ),
      ),
    );
  }

  Widget setTitleForDropDown({
    required VoidCallback onTap,
    required String titleTxt,
    required String hintText,
    required Color bgClr,
    required Color txtClr,
    required Color arrowColor,
  }) {
    return CustomInkWellContainer(
      onTap: onTap,
      child: dropDownTextLblWithFrwdArrow(
        titleTxt: titleTxt,
        hintText: hintText,
        txtClr: txtClr,
        arrowColor: arrowColor,
        bgClr: bgClr,
      ),
    );
  }

  Widget dropDownTextLblWithFrwdArrow({
    required String titleTxt,
    required String hintText,
    required Color bgClr,
    required Color txtClr,
    required Color arrowColor,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            titleTxt,
            color: Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.w400,
            fontSize: 18.0,
          ),
          const CustomSizedBox(height: 8),
          CustomContainer(
            height: MediaQuery.sizeOf(context).height * 0.07,
            borderRadius: UiUtils.borderRadiusOf10,
            color: Theme.of(context).colorScheme.secondaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: Text(
                    hintText,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.blackColor,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: arrowColor,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget setTitleAndSwitch({
    required String titleText,
    required bool isAllowed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CustomInkWellContainer(
            showSplashEffect: false,
            onTap: () {
              if (titleText ==
                  'payLaterAllowedLbl'.translate(context: context)) {
                isPayLaterAllowed = !isPayLaterAllowed;
              } else if (titleText ==
                  'isCancelableLbl'.translate(context: context)) {
                isCancelAllowed = !isCancelAllowed;
              } else if (titleText ==
                  'atStoreAllowed'.translate(context: context)) {
                isStoreAllowed = !isStoreAllowed;
              } else if (titleText ==
                  'atDoorstepAllowed'.translate(context: context)) {
                isDoorStepAllowed = !isDoorStepAllowed;
              } else if (titleText == 'statusLbl'.translate(context: context)) {
                serviceStatus = !serviceStatus;
              }

              setState(() {});
            },
            child: CustomText(
              titleText,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.blackColor,
            ),
          ),
        ),
        CustomSwitch(
          thumbColor: isAllowed ? Colors.green : Colors.red,
          value: isAllowed,
          onChanged: (bool val) {
            if (titleText == 'payLaterAllowedLbl'.translate(context: context)) {
              isPayLaterAllowed = val;
            } else if (titleText ==
                'isCancelableLbl'.translate(context: context)) {
              isCancelAllowed = val;
            } else if (titleText ==
                'atStoreAllowed'.translate(context: context)) {
              isStoreAllowed = val;
            } else if (titleText ==
                'atDoorstepAllowed'.translate(context: context)) {
              isDoorStepAllowed = val;
            } else if (titleText == 'statusLbl'.translate(context: context)) {
              serviceStatus = val;
            }

            setState(() {});
          },
        )
      ],
    );
  }

  Padding bottomNavigation() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currIndex > 1) ...[
              Expanded(child: nextPrevBtnWidget(false)),
              const CustomSizedBox(width: 10)
            ],
            Expanded(child: nextButton()),
          ],
        ),
      ),
    );
  }

  CustomRoundedButton nextButton() {
    Widget? child;
    if (context.watch<CreateServiceCubit>().state is CreateServiceInProgress) {
      child = CustomCircularProgressIndicator(
        color: AppColors.whiteColors,
      );
    }

    return CustomRoundedButton(
      textSize: 15,
      widthPercentage: 1,
      backgroundColor: Theme.of(context).colorScheme.accentColor,
      buttonTitle: currIndex < totalForms
          ? 'nxtBtnLbl'.translate(context: context)
          : widget.service?.id != null
              ? 'editServiceBtnLbl'.translate(context: context)
              : 'addServiceBtnLbl'.translate(context: context),
      showBorder: false,
      onTap: () {
        UiUtils.removeFocus();
        onNextPrevBtnClick(true);
      },
      child: child,
    );
  }

  CustomRoundedButton nextPrevBtnWidget(bool isNext) {
    return CustomRoundedButton(
      showBorder: true,
      borderColor: isNext
          ? Colors.transparent
          : Theme.of(context).colorScheme.blackColor,
      radius: 8,
      textSize: 15,
      buttonTitle: isNext && currIndex >= totalForms
          ? 'addServiceBtnLbl'.translate(context: context)
          : isNext
              ? 'nxtBtnLbl'.translate(context: context)
              : 'prevBtnLbl'.translate(context: context),
      titleColor: isNext
          ? Theme.of(context).colorScheme.secondaryColor
          : Theme.of(context).colorScheme.blackColor,
      backgroundColor: isNext
          ? Theme.of(context).colorScheme.blackColor
          : Theme.of(context).colorScheme.secondaryColor,
      widthPercentage: isNext ? 1 : 0.5,
      onTap: () {
        onNextPrevBtnClick(isNext);
      },
    );
  }

  Future<void> onNextPrevBtnClick(bool isNext) async {
    UiUtils.removeFocus();

    if (currIndex == 4) {
      final tempText = await controller.getText();
      if (tempText.trim().isNotEmpty) {
        longDescription = tempText;
      }
      controller.clearFocus();
    }
    if (isNext) {
      FormState? form = formKey1.currentState; //default value
      switch (currIndex) {
        case 3:
          form = formKey3.currentState;
          break;
        case 2:
          form = formKey2.currentState;
          break;
        default:
          form = formKey1.currentState;
          break;
      }
      if (form == null && currIndex != 4) return;

      if (form != null) {
        form.save();
      }

      //not validating the faqs and long description pages
      if (currIndex > 2 || form!.validate()) {
        if (currIndex < totalForms) {
          if (currIndex == 1) {
            if (finalTagList.isEmpty) {
              UiUtils.showMessage(
                context,
                message: 'pleaseAddTags'.translate(context: context),
                type: ToastificationType.error,
              );
              return;
            }
          }
          if (currIndex == 2) {
            if (!(imagePicker.pickedFile != null ||
                widget.service?.imageOfTheService != null ||
                pickedServiceImage != '')) {
              FocusScope.of(context).unfocus();
              UiUtils.showMessage(
                context,
                message:
                    "selectServiceImageToContinue".translate(context: context),
                type: ToastificationType.warning,
              );
              return;
            }
          }
          currIndex++;
          scrollController.jumpTo(0);
          setState(() {});
        } else {
          String tagString = '';
          if (finalTagList.isNotEmpty) {
            for (final Map<String, dynamic> element in finalTagList) {
              tagString += "${element['text']},";
            }
            tagString = tagString.substring(0, tagString.length - 1);
          } else {
            UiUtils.showMessage(context,
                message: 'pleaseAddTags', type: ToastificationType.error);
            return;
          }

          final List<ServiceFaQs> faqsAdded = [];

          for (int i = 0; i < faqQuestionTextEditors.value.length; i++) {
            try {
              if (faqQuestionTextEditors.value[i].text.trim().isNotEmpty &&
                  faqAnswersTextEditors.value[i].text.trim().isNotEmpty) {
                faqsAdded.add(
                  ServiceFaQs(
                    question: faqQuestionTextEditors.value[i].text,
                    answer: faqAnswersTextEditors.value[i].text,
                  ),
                );
              }
            } catch (_) {}
          }

          final CreateServiceModel createServiceModel = CreateServiceModel(
            serviceId: widget.service?.id,
            title: serviceTitleController.text,
            description: serviceDescrController.text,
            price: priceController.text,
            members: memReqTaskController.text,
            maxQty: qtyAllowedTaskController.text,
            duration: int.parse(
              durationTaskController.text,
            ),
            cancelableTill: cancelBeforeController.text.trim().toString(),
            iscancelable: isCancelAllowed ? 1 : 0,
            is_pay_later_allowed: isPayLaterAllowed ? 1 : 0,
            isStoreAllowed: isStoreAllowed ? 1 : 0,
            status: serviceStatus ? "1" : "0",
            isDoorStepAllowed: isDoorStepAllowed ? 1 : 0,
            discounted_price: int.parse(
              discountPriceController.text,
            ),
            image: pickedServiceImage,
            categories: selectedCategory.toString(),
            tax_type: priceTypeFilter[selectedPriceType?['value']],
            tags: tagString,
            taxId: selectedTax.toString(),
            other_images: pickedOtherImages.value,
            files: pickedFiles.value,
            faqs: faqsAdded,
            long_description: longDescription,
          );

          if (imagePicker.pickedFile != null ||
              widget.service?.imageOfTheService != null ||
              pickedServiceImage != '') {
            //
            if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable()) {
              UiUtils.showDemoModeWarning(context: context);
              return;
            }
            //
            if (context.read<CreateServiceCubit>().state
                    is CreateServiceInProgress ||
                context.read<CreateServiceCubit>().state
                    is CreateServiceSuccess) {
              return;
            } else {
              context
                  .read<CreateServiceCubit>()
                  .createService(createServiceModel);
            }
          } else {
            FocusScope.of(context).unfocus();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('imageRequired'.translate(context: context)),
                  content:
                      Text('pleaseSelectImage'.translate(context: context)),
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
    } else if (currIndex > 1) {
      currIndex--;
      setState(() {});
    }
  }
}
