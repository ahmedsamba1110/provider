import 'package:edemand_partner/cubits/getProviderDetails.dart';
import 'package:edemand_partner/data/repository/chat/chatNotificationRepository.dart';
import 'package:edemand_partner/ui/screens/jobRequest/jobRequestScreen.dart';
import 'package:edemand_partner/utils/Notification/chatNotificationsUtils.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/generalImports.dart';

class MainActivity extends StatefulWidget {
  const MainActivity({super.key});

  @override
  State<MainActivity> createState() => MainActivityState();

  static Route<MainActivity> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MainActivity(key: UiUtils.bottomNavigationBarGlobalKey),
    );
  }
}

class MainActivityState extends State<MainActivity>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  ValueNotifier<int> selectedIndexOfBottomNavigationBar = ValueNotifier(0);
  ValueNotifier<String> nameOfSelectedIndexOfBottomNavigationBar =
      ValueNotifier('');

  late PageController pageController;

  List<ScrollController> scrollControllerList = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    //
    for (int i = 0; i < 5; i++) {
      scrollControllerList.add(ScrollController());
    }
    //
    AppQuickActions.initAppQuickActions();
    AppQuickActions.createAppQuickActions();
    //

    Future.delayed(
      Duration.zero,
      () {
        LocalAwesomeNotification.init(context);
        //
        nameOfSelectedIndexOfBottomNavigationBar.value =
            'homeTabTitleLbl'.translate(context: context);
        try {
          context.read<GetProviderDetailsCubit>().getProviderDetails();
        } catch (_) {}
      },
    );

    pageController = PageController();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final backgroundChatMessages = await ChatNotificationsRepository()
          .getBackgroundChatNotificationData();

      if (backgroundChatMessages.isNotEmpty) {
        //empty any old data and stream new once
        ChatNotificationsRepository()
            .setBackgroundChatNotificationData(data: []);
        for (int i = 0; i < backgroundChatMessages.length; i++) {
          ChatNotificationsUtils.addChatStreamValue(
              chatData: backgroundChatMessages[i]);
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    pageController.dispose();
    for (int i = 0; i < 5; i++) {
      scrollControllerList[i].dispose();
    }
    super.dispose();
  }

  String _getUserName() {
    return context
            .watch<ProviderDetailsCubit>()
            .providerDetails
            .user
            ?.username ??
        '';
  }

  String _getEmail() {
    return context.watch<ProviderDetailsCubit>().providerDetails.user?.email ??
        '';
  }

  dynamic getProfileImage() {
    return context.watch<ProviderDetailsCubit>().providerDetails.user?.image ??
        '';
  }

  bool doUserHasProfileImage() {
    return context.watch<ProviderDetailsCubit>().providerDetails.user?.image !=
            '' ||
        context.watch<ProviderDetailsCubit>().providerDetails.user?.image !=
            null;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: PopScope(
        canPop: selectedIndexOfBottomNavigationBar.value == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            return;
          } else {
            if (selectedIndexOfBottomNavigationBar.value != 0) {
              selectedIndexOfBottomNavigationBar.value = 0;
              pageController
                  .jumpToPage(selectedIndexOfBottomNavigationBar.value);
            }
          }
        },
        child: BlocListener<GetProviderDetailsCubit, GetProviderDetailsState>(
          listener: (context, state) {
            if (state is GetProviderDetailsSuccessState) {
              HiveRepository.setUserData(state.providerDetails.toJsonData());
              context
                  .read<ProviderDetailsCubit>()
                  .setUserInfo(state.providerDetails);
            } else {
              //get the locally stored provider details and update the cubit
              context
                  .read<ProviderDetailsCubit>()
                  .setUserInfo(HiveRepository.getProviderDetails());
            }
          },
          child: Scaffold(
            bottomNavigationBar: bottomBar(),
            appBar: selectedIndexOfBottomNavigationBar.value != 2
                ? AppBar(
                    iconTheme: IconThemeData(
                        color: Theme.of(context).colorScheme.accentColor),
                    title: ValueListenableBuilder(
                      valueListenable: nameOfSelectedIndexOfBottomNavigationBar,
                      builder:
                          (BuildContext context, Object? value, Widget? child) {
                        return Text(
                          nameOfSelectedIndexOfBottomNavigationBar.value,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.blackColor,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryColor,
                    surfaceTintColor:
                        Theme.of(context).colorScheme.secondaryColor,
                    elevation: 1,
                    centerTitle:
                        nameOfSelectedIndexOfBottomNavigationBar.value ==
                                'jobRequestTitleLbl'.translate(context: context)
                            ? false
                            : true,
                  )
                : null,
            onDrawerChanged: (bool a) {
              FocusManager.instance.primaryFocus?.unfocus();
              FocusScope.of(context).unfocus();
            },
            drawer:
                selectedIndexOfBottomNavigationBar.value != 2 ? drawer() : null,
            body: ValueListenableBuilder(
              valueListenable: selectedIndexOfBottomNavigationBar,
              builder: (BuildContext context, Object? value, Widget? child) {
                return PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  onPageChanged: onItemTapped,
                  children: [
                    HomeScreen(
                      scrollController: scrollControllerList[0],
                      navigateToTab: navigateToTab,
                    ),
                    BookingScreen(
                      scrollController: scrollControllerList[1],
                    ),
                    JobRequestScreen(scrollController: scrollControllerList[2]),
                    ServicesScreen(scrollController: scrollControllerList[3]),
                    ReviewsScreen(scrollController: scrollControllerList[4]),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void navigateToTab(int index) {
    selectedIndexOfBottomNavigationBar.value = index;
    pageController.jumpToPage(index);
  }

  void onItemTapped(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    final int previousSelectedIndex = selectedIndexOfBottomNavigationBar.value;

    switch (index) {
      case 1:
        nameOfSelectedIndexOfBottomNavigationBar.value =
            'bookingsTitleLbl'.translate(context: context);
        break;
      case 2:
        nameOfSelectedIndexOfBottomNavigationBar.value =
            'jobRequestTitleLbl'.translate(context: context);
        break;
      case 3:
        nameOfSelectedIndexOfBottomNavigationBar.value =
            'servicesTitleLbl'.translate(context: context);
        break;
      case 4:
        nameOfSelectedIndexOfBottomNavigationBar.value =
            'reviewsTitleLbl'.translate(context: context);
        break;

      default: //index = 0
        nameOfSelectedIndexOfBottomNavigationBar.value =
            'homeTabTitleLbl'.translate(context: context);
        break;
    }
    setState(() {
      selectedIndexOfBottomNavigationBar.value = index;
    });

    pageController.jumpToPage(selectedIndexOfBottomNavigationBar.value);
    try {
      if (previousSelectedIndex == index &&
          scrollControllerList[index].positions.isNotEmpty) {
        scrollControllerList[index].animateTo(0,
            duration: const Duration(milliseconds: 500), curve: Curves.linear);
      }
    } catch (_) {}
  }

  Widget drawer() {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryColor,
            ),
            child: CustomInkWellContainer(
              onTap: () {
                Navigator.pushNamed(context, Routes.registration,
                    arguments: {'isEditing': true});
              },
              child: Row(
                children: [
                  CustomContainer(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsetsDirectional.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).colorScheme.blackColor),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(UiUtils.borderRadiusOf50),
                      child: doUserHasProfileImage()
                          ? CustomCachedNetworkImage(
                              imageUrl: getProfileImage(),
                            )
                          : const CustomSvgPicture("dr_profile"),
                    ),
                  ),
                  const CustomSizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          _getUserName(),
                          color: Theme.of(context).colorScheme.blackColor,
                          fontWeight: FontWeight.w700,
                        ),
                        CustomText(
                          _getEmail(),
                          color: Theme.of(context).colorScheme.blackColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          maxLines: 2,
                        )
                      ],
                    ),
                  ),
                  CustomContainer(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .blackColor
                          .withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(UiUtils.borderRadiusOf5),
                    ),
                    child: Icon(Icons.edit,
                        color: Theme.of(context).colorScheme.blackColor,
                        size: 16),
                  ),
                ],
              ),
            ),
          ),
          // buildDrawerItem(
          //   icon: 'dr_categories',
          //   title: 'categoriesLbl'.translate(context: context),
          //   onItemTap: () {
          //     Navigator.of(context).pop();
          //     Navigator.of(context).pushNamed(Routes.categories);
          //   },
          // ),
          buildDrawerItem(
            icon: 'dr_promocode',
            title: 'promoCodeLbl'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Routes.promoCode);
            },
          ),
          buildDrawerItem(
            icon: 'dr_cashcollection',
            title: 'cashCollection'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Routes.cashCollection);
            },
          ),
          buildDrawerItem(
            icon: 'dr_settelmenthistory',
            title: 'settlementHistory'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(
                Routes.settlementHistoryScreen,
              );
            },
          ),
          buildDrawerItem(
            icon: 'dr_withdrawalrequest',
            title: 'withdrawalRequest'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Routes.withdrawalRequests);
            },
          ),
          buildDrawerItem(
            icon: 'dr_booking_payment',
            title: 'bookingPaymentManagement'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Routes.bookingPaymentDataScreen);
            },
          ),
          buildDrawerItem(
            icon: 'dr_chat',
            title: 'chat'.translate(context: context),
            isSubscription: false,
            onItemTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, Routes.chatUsersList);
            },
          ),
          buildDrawerItem(
            icon: 'dr_subscription',
            title: 'subscriptions'.translate(context: context),
            isSubscription: true,
            onItemTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Routes.subscriptionScreen,
                  arguments: {"from": "drawer"});
            },
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          buildGroupTitle('appPrefsTitleLbl'.translate(context: context)),
          buildDrawerItem(
            icon: 'dr_language',
            title: 'languageLbl'.translate(context: context),
            onItemTap: () {
              final List<Map<String, dynamic>> values =
                  appLanguages.map((element) {
                return {
                  "title": element.languageName,
                  "id": element.languageCode,
                  "isSelected":
                      context.read<LanguageCubit>().getCurrentLanguageCode() ==
                          element.languageCode
                };
              }).toList();

              UiUtils.showModelBottomSheets(
                context: context,
                enableDrag: true,
                child: SelectableListBottomSheet(
                    bottomSheetTitle: "selectLanguage", itemList: values),
              ).then((value) {
                if (value != null) {
                  context
                      .read<LanguageCubit>()
                      .changeLanguage(value["selectedItemId"]);
                }
              });
            },
          ),
          buildDrawerItem(
            icon: 'dr_theme',
            title: 'darkThemeLbl'.translate(context: context),
            isSwitch: true,
            onItemTap: () {
              context.read<AppThemeCubit>().toggleTheme();
            },
          ),
          buildDrawerItem(
            icon: 'dr_changepass',
            title: 'changePassword'.translate(context: context),
            onItemTap: () async {
              await UiUtils.showModelBottomSheets(
                context: context,
                enableDrag: true,
                isScrollControlled: true,
                child: const ChangePasswordBottomSheet(),
              );
            },
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          buildGroupTitle('helpPrivacyTitleLbl'.translate(context: context)),
          buildDrawerItem(
            icon: 'dr_contactus',
            title: 'contactUs'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();

              Navigator.pushNamed(
                context,
                Routes.contactUsRoute,
              );
            },
          ),
          buildDrawerItem(
            icon: 'dr_aboutus',
            title: 'aboutUs'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();

              Navigator.pushNamed(context, Routes.appSettings,
                  arguments: {'title': 'aboutUs'});
            },
          ),
          buildDrawerItem(
            icon: 'dr_privacypolicy',
            title: 'privacyPolicyLbl'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();

              Navigator.pushNamed(
                context,
                Routes.appSettings,
                arguments: {'title': 'privacyPolicyLbl'},
              );
            },
          ),
          buildDrawerItem(
            icon: 'dr_termsconditions',
            title: 'termsConditionLbl'.translate(context: context),
            onItemTap: () {
              Navigator.of(context).pop();

              Navigator.pushNamed(
                context,
                Routes.appSettings,
                arguments: {'title': 'termsConditionLbl'},
              );
            },
          ),
          buildDrawerItem(
            icon: 'dr_shareapp',
            title: 'shareApp'.translate(context: context),
            onItemTap: () {
              if (Platform.isAndroid) {
                // ignore: prefer_interpolation_to_compose_strings
                Share.share(
                    context.read<FetchSystemSettingsCubit>().getPlayStoreURL());
              } else {
                Share.share(
                    context.read<FetchSystemSettingsCubit>().getAppStoreURL());
              }
            },
          ),
          buildDrawerItem(
            icon: 'dr_logout',
            title: 'logoutLbl'.translate(context: context),
            onItemTap: () => UiUtils.showAnimatedDialog(
                context: context, child: const LogoutAccountDialog()),
          ),
          ListTile(
            tileColor: Colors.redAccent.withValues(alpha: 0.05),

            visualDensity: const VisualDensity(vertical: -4),
            //change -4 to required one TO INCREASE SPACE BTWN ListTiles
            leading: const CustomSvgPicture(
              "dr_deleteacoount",
              color: AppColors.redColor,
              height: 20,
              width: 20,
            ),
            title: CustomText(
              'deleteAccount'.translate(context: context),
              fontSize: 15.0,
              color: AppColors.redColor,
            ),
            selectedTileColor: Theme.of(context).colorScheme.lightGreyColor,
            onTap: () async {
              UiUtils.showAnimatedDialog(
                  context: context,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<DeleteProviderAccountCubit>(
                        create: (BuildContext context) =>
                            DeleteProviderAccountCubit(),
                      ),
                      BlocProvider<SignInCubit>(
                        create: (BuildContext context) => SignInCubit(),
                      ),
                    ],
                    child: DeleteProviderAccountDialog(),
                  ));
              //  await _deleteProviderAccount();
            },
            hoverColor: Theme.of(context).colorScheme.lightGreyColor,
            horizontalTitleGap: 0,
          )
        ],
      ),
    );
  }

  Widget buildGroupTitle(String titleTxt) {
    return CustomContainer(
      padding: const EdgeInsetsDirectional.only(start: 10, top: 10, bottom: 10),
      child: CustomText(
        titleTxt,
        fontSize: 14,
        color: Theme.of(context).colorScheme.blackColor,
      ),
    );
  }

  Widget buildDrawerItem({
    required String? icon,
    required String title,
    required VoidCallback onItemTap,
    bool? isSwitch,
    bool? isSubscription,
  }) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -4),
      //change -4 to required one TO INCREASE SPACE BTWN ListTiles
      leading: CustomSvgPicture(
        icon!,
        color: (title == 'logoutLbl'.translate(context: context))
            ? AppColors.redColor
            : Theme.of(context).colorScheme.accentColor,
        height: 20,
        width: 20,
      ),
      trailing: isSwitch ?? false
          ? CustomSwitch(
              thumbColor:
                  context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                      ? Colors.green
                      : Colors.red,
              value: context.watch<AppThemeCubit>().state.appTheme ==
                  AppTheme.dark,
              onChanged: (bool val) {
                onItemTap.call();
              },
            )
          : isSubscription ?? false
              ? CustomContainer(
                  padding: const EdgeInsets.all(5),
                  color: context
                              .read<ProviderDetailsCubit>()
                              .providerDetails
                              .subscriptionInformation
                              ?.isSubscriptionActive ==
                          "active"
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                  borderRadius: 5,
                  child: CustomText(
                    (context
                                    .read<ProviderDetailsCubit>()
                                    .providerDetails
                                    .subscriptionInformation
                                    ?.isSubscriptionActive ==
                                "active"
                            ? "active"
                            : "deactive")
                        .translate(context: context),
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.blackColor,
                  ),
                )
              : const CustomSizedBox(),
      title: CustomText(
        title,
        fontWeight: (icon != '') ? FontWeight.w500 : FontWeight.normal,
        fontSize: 16.0,
        color: (title == 'logoutLbl'.translate(context: context))
            ? AppColors.redColor
            : Theme.of(context).colorScheme.blackColor,
      ),
      selectedTileColor: Theme.of(context).colorScheme.lightGreyColor,
      onTap: onItemTap,
      hoverColor: Theme.of(context).colorScheme.lightGreyColor,
      horizontalTitleGap: 0,
    );
  }

  void bottomState(int index) {
     setState(() {
       selectedIndexOfBottomNavigationBar.value = index;
      pageController.jumpToPage(index);
    });
  }

  static Widget bottomBarTextButton(
      BuildContext context,
      int selectedIndex,
      int index,
      void Function() onPressed,
      String? imgName,
      String? iconTitle) {
    return InkWell(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomSvgPicture(
              imgName!,
              color: selectedIndex != index
                  ? Theme.of(context).colorScheme.lightGreyColor
                  : Theme.of(context).colorScheme.accentColor,
            ),
            selectedIndex == index
                ? const SizedBox(height: 2)
                : const SizedBox(),
            Text(iconTitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selectedIndex != index
                        ? Theme.of(context).colorScheme.lightGreyColor
                        : Theme.of(context).colorScheme.accentColor))
          ],
        ),
      ),
      onTap: () => onPressed(),
    );
  }

  Widget bottomBar() {
    return NavigationBar(
      height: kBottomNavigationBarHeight + 10,
      destinations: [
        bottomBarTextButton(
            context, selectedIndexOfBottomNavigationBar.value, 0, () {
          bottomState(0);
        }, "home", 'homeTab'.translate(context: context)),
        bottomBarTextButton(
            context, selectedIndexOfBottomNavigationBar.value, 1, () {
          bottomState(1);
        }, "booking", 'bookingTab'.translate(context: context)),
        bottomBarTextButton(
            context, selectedIndexOfBottomNavigationBar.value, 2, () {
          bottomState(2);
        }, "briefcase", 'jobRequestTab'.translate(context: context)),
        bottomBarTextButton(
            context, selectedIndexOfBottomNavigationBar.value, 3, () {
          bottomState(3);
        }, "services", 'serviceTab'.translate(context: context)),
        bottomBarTextButton(
            context, selectedIndexOfBottomNavigationBar.value, 4, () {
          bottomState(4);
        }, "reviews", 'reviewsTab'.translate(context: context))
      ],
      backgroundColor: Theme.of(context).colorScheme.secondaryColor,
      surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
      selectedIndex: selectedIndexOfBottomNavigationBar.value,
      onDestinationSelected: (value) => onItemTapped(value),
      indicatorColor: Theme.of(context).colorScheme.secondaryColor,
    );
  }

  Widget setBottomNavigationbarItem(
    int index,
    String imgName,
    String nameTxt,
  ) {
    return NavigationDestination(
      tooltip: nameTxt,
      icon: CustomContainer(
        child: CustomSvgPicture(
          imgName,
          color: selectedIndexOfBottomNavigationBar.value != index
              ? Theme.of(context).colorScheme.lightGreyColor
              : Theme.of(context).colorScheme.accentColor,
        ),
      ),
      label: nameTxt,
    );
  }

  // Widget setBottomNavigationjobRequestbarItem(
  //     int index, String imgName, String nameTxt) {
  //   return NavigationDestination(
  //     tooltip: nameTxt,
  //     icon: CustomContainer(
  //       padding: const EdgeInsets.all(6),
  //       height: 35,
  //       width: 35,
  //       decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(50),
  //           color: selectedIndexOfBottomNavigationBar.value != index
  //               ? Theme.of(context).colorScheme.accentColor.withValues(alpha: 0.12)
  //               : Theme.of(context).colorScheme.accentColor,
  //           border:
  //               Border.all(color: Theme.of(context).colorScheme.accentColor)),
  //       child: CustomSvgPicture(
  //         imgName,
  //         color: selectedIndexOfBottomNavigationBar.value != index
  //             ? Theme.of(context).colorScheme.accentColor
  //             : Theme.of(context).colorScheme.shimmerContentColor,
  //       ),
  //     ),
  //     label: "" /*nameTxt*/,
  //   );
  // }
}
