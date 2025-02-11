import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomBackArrow extends StatelessWidget {
  final bool? canGoBack;
  final VoidCallback? onTap;

  const CustomBackArrow({super.key, this.canGoBack, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      icon: CustomSvgPicture(
        context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
            ? Directionality.of(context).toString().contains(TextDirection.RTL.value.toLowerCase())
                ? 'back_arrow_dark_ltr'
                : 'back_arrow_dark'
            : Directionality.of(context).toString().contains(TextDirection.RTL.value.toLowerCase())
                ? 'back_arrow_light_ltr'
                : 'back_arrow_light',
        boxFit: BoxFit.scaleDown,
        color: Theme.of(context).colorScheme.blackColor,
      ),
      onPressed: onTap ??
          () {
            if (canGoBack ?? true) {
              Navigator.of(context).pop();
            }
          },
    );
  }
}
