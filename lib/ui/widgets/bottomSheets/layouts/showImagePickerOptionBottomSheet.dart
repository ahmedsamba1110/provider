import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class ShowImagePickerOptionBottomSheet extends StatelessWidget {
  const ShowImagePickerOptionBottomSheet({
    super.key,
    required this.title,
    required this.onCameraButtonClick,
    required this.onGalleryButtonClick,
  });

  final String title;
  final VoidCallback onCameraButtonClick;
  final VoidCallback onGalleryButtonClick;

  @override
  Widget build(BuildContext context) {
    return BottomSheetLayout(
        title: title,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomContainer(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.lightGreyColor,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);

                        onCameraButtonClick();
                      },
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        size: 50,
                        color: Theme.of(context).colorScheme.blackColor,
                      ),
                    ),
                  ),
                  const CustomSizedBox(
                    height: 5,
                  ),
                  Text(
                    'camera'.translate(context: context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.blackColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const CustomSizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomContainer(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.lightGreyColor,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onGalleryButtonClick();
                      },
                      icon: Icon(
                        Icons.image_outlined,
                        size: 50,
                        color: Theme.of(context).colorScheme.blackColor,
                      ),
                    ),
                  ),
                  const CustomSizedBox(
                    height: 5,
                  ),
                  Text(
                    'gallery'.translate(context: context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.blackColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
