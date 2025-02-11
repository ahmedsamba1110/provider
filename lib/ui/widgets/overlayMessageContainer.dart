import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

Widget MessageContainer({
  required BuildContext context,
  required String text,
  required ToastificationType type,
}) {
  return Material(
    child: ToastAnimation(
      delay: UiUtils.messageDisplayDuration,
      child: Row(
        children: [
          Expanded(
            child: CustomContainer(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
//
                gradient: LinearGradient(
                  stops: const [0.02, 0.02],
                  colors: [
                    messageColors[type]!,
                    messageColors[type]!.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
                border: Border.all(
                  color: messageColors[type]!.withValues(alpha: 0.5),
                ),
              ),
              width: MediaQuery.sizeOf(context).width,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    start: 10,
                    child: CustomContainer(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: messageColors[type],
                      ),
                      child: Icon(
                        messageIcon[type],
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    start: 40,
                    child: CustomSizedBox(
                      width: MediaQuery.sizeOf(context).width - 90,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          text,
                          softWrap: true,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: messageColors[type],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
