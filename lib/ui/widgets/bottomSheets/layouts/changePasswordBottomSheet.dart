
import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  @override
  State<ChangePasswordBottomSheet> createState() => _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  //
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //
  final TextEditingController _oldPasswordTextController = TextEditingController();
  final TextEditingController _newPasswordTextController = TextEditingController();
  final TextEditingController _confirmNewPasswordTextController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordTextController.dispose();
    _newPasswordTextController.dispose();
    _confirmNewPasswordTextController.dispose();
    super.dispose();
  }

  //
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (BuildContext context, ChangePasswordState state) async {
        if (state is ChangePasswordSuccess) {
          //
          _oldPasswordTextController.clear();
          _newPasswordTextController.clear();
          _confirmNewPasswordTextController.clear();
          //
          UiUtils.showMessage(context,message:  state.errorMessage,type:  ToastificationType.success);
          //
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pop(context);
          }
          //
        } else if (state is ChangePasswordFailure) {
          UiUtils.showMessage(context,message:  state.errorMessage,type:  ToastificationType.error);
        }
      },
      builder: (BuildContext context, ChangePasswordState state) {
        Widget? child;
        if (state is ChangePasswordInProgress) {
          child = CustomCircularProgressIndicator(
            color: AppColors.whiteColors,
          );
        }
        return BottomSheetLayout(
            title: "changePassword",
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextFormField(
                          bottomPadding: 15,
                          controller: _oldPasswordTextController,
                          isPswd: true,
                          labelText: 'oldPassword'.translate(context: context),
                          validator: (String? value) => Validator.nullCheck(context, value),
                        ),
                        CustomTextFormField(
                          bottomPadding: 15,
                          controller: _newPasswordTextController,
                          isPswd: true,
                          labelText: 'newPassword'.translate(context: context),
                          validator: (String? value) => Validator.nullCheck(context, value),
                        ),
                        CustomTextFormField(
                          bottomPadding: 15,
                          controller: _confirmNewPasswordTextController,
                          isPswd: true,
                          labelText: 'confirmPasswordLbl'.translate(context: context),
                          validator: (String? value) => Validator.nullCheck(context, value),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: 10 + MediaQuery.of(context).viewInsets.bottom, top: 10),
                    child: CustomRoundedButton(
                      widthPercentage: 1,
                      backgroundColor: Theme.of(context).colorScheme.accentColor,
                      buttonTitle: 'changePassword'.translate(context: context),
                      titleColor: AppColors.whiteColors,
                      showBorder: false,
                      child: child,
                      onTap: () {
                        UiUtils.removeFocus();
                        final FormState? form = formKey.currentState; //default value
                        if (form == null) return;
                        form.save();
                        if (form.validate()) {
                          final String newPassword = _newPasswordTextController.text.trim();
                          final String confirmNewPassword =
                              _confirmNewPasswordTextController.text.trim();
                          final String oldPassword = _oldPasswordTextController.text.trim();

                          final bool isNewAndConfirmPasswordAreSame =
                              newPassword == confirmNewPassword;
                          if (isNewAndConfirmPasswordAreSame) {
                            if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable()) {
                              UiUtils.showDemoModeWarning(context: context);
                              return;
                            }
                            context.read<ChangePasswordCubit>().changePassword(
                                  oldPassword: oldPassword,
                                  newPassword: newPassword,
                                );
                          } else {
                            UiUtils.showMessage(
                              context,
                              message:  'passwordDoesNotMatch'.translate(context: context),
                              type:  ToastificationType.warning,
                            );
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
            ));
      },
    );
  }
}
