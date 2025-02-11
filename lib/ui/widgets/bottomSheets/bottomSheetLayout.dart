import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/material.dart';

class BottomSheetLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const BottomSheetLayout({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: Theme.of(context).colorScheme.primaryColor,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(UiUtils.borderRadiusOf20),
            topLeft: Radius.circular(UiUtils.borderRadiusOf20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomContainer(
            width: MediaQuery.sizeOf(context).width,
            padding: const EdgeInsets.all(15.0),
            color: Theme.of(context).colorScheme.secondaryColor,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(UiUtils.borderRadiusOf20),
                  topLeft: Radius.circular(UiUtils.borderRadiusOf20)),
            ),
            child: CustomText(
               title.translate(context: context),
              fontSize: 20.0,
              maxLines: 1,
              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              textAlign: TextAlign.start,
            ),
          ),
          CustomContainer(
            padding: const EdgeInsets.only(top: 5),
            color: Theme.of(context).colorScheme.primaryColor,
            child: child,
          ),
        ],
      ),
    );
  }
}
