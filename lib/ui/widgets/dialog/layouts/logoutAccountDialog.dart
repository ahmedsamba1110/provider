import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class LogoutAccountDialog extends StatelessWidget {
  const LogoutAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDialogLayout(
      showProgressIndicator: false,
      icon: CustomContainer(
          height: 70,
          width: 70,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryColor,
              borderRadius: BorderRadius.circular(50)),
          child: Icon(Icons.help, color: Theme.of(context).colorScheme.accentColor, size: 70)),
      title: "confirmLogout",
      description: "areYouSureYouWantToLogout",
      //
      cancelButtonName: "cancel",
      cancelButtonBackgroundColor: Theme.of(context).colorScheme.secondaryColor,
      cancelButtonPressed: () {
        Navigator.of(context).pop();
      },
      //
      confirmButtonName: "logoutLbl",
      confirmButtonBackgroundColor: AppColors.redColor,
      confirmButtonPressed: () async {
        try {
          await context
              .read<UpdateFCMCubit>()
              .updateFCMId(fcmID: "", platform: Platform.isAndroid ? "android" : "ios");
        } catch (_) {}

        await AuthRepository().logout(context);
      },
    );
  }
}
