import 'package:edemand_partner/app/generalImports.dart';
import 'package:edemand_partner/ui/widgets/closeAndConfirmButton.dart';
import 'package:flutter/material.dart';

class CustomDialogLayout extends StatelessWidget {
  final String title;
  final String? description;
  final String confirmButtonName;
  final String cancelButtonName;
  final Color confirmButtonBackgroundColor;
  final Color cancelButtonBackgroundColor;

  ///default it will be false
  final bool? showProgressIndicator;
  final Function cancelButtonPressed;
  final Function confirmButtonPressed;
  final Widget? icon;
  final Widget? confirmButtonChild;
  final Widget? widgetUnderDescription;

  const CustomDialogLayout(
      {final Key? key,
      required this.title,
      this.description,
      required this.confirmButtonName,
      required this.cancelButtonName,
      this.icon,
      required this.cancelButtonPressed,
      required this.confirmButtonPressed,
      required this.confirmButtonBackgroundColor,
      required this.cancelButtonBackgroundColor,
      this.confirmButtonChild,
      this.widgetUnderDescription,
      required this.showProgressIndicator})
      : super(key: key);

  @override
  Widget build(final BuildContext context) => CustomContainer(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryColor,
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const CustomSizedBox(height: 10),
                      ],
                      CustomText(
                        title.translate(context: context),
                        color: Theme.of(context).colorScheme.blackColor,
                        fontSize: 16,
                      ),
                      const CustomSizedBox(height: 10),
                      if (description != null) ...[
                        CustomText(
                          description!.translate(context: context),
                          color: Theme.of(context).colorScheme.lightGreyColor,
                          fontSize: 12,
                          maxLines: 3,
                          textAlign: TextAlign.center,
                        ),
                        const CustomSizedBox(height: 10),
                      ],
                      if (widgetUnderDescription != null) ...[
                        widgetUnderDescription!,
                        const CustomSizedBox(height: 10),
                      ]
                    ],
                  ),
                ),
              ),
              CloseAndConfirmButton(
                closeButtonPressed: cancelButtonPressed.call,
                closeButtonName: cancelButtonName.translate(context: context),
                closeButtonBackgroundColor: cancelButtonBackgroundColor,
                confirmButtonName: confirmButtonName.translate(context: context),
                confirmButtonBackgroundColor: confirmButtonBackgroundColor,
                confirmButtonPressed: confirmButtonPressed.call,
                confirmButtonChild: confirmButtonChild,
                showProgressIndicator: showProgressIndicator,
              ),
            ],
          ),
        ),
      );

  Widget showCircularProgressIndicator({required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: CustomSizedBox(
        height: 30,
        width: 25,
        child: CustomCircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondaryColor,
        ),
      ),
    );
  }
}
