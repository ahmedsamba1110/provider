import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/material.dart';

class ChatMessageSendingWidget extends StatelessWidget {
  final Function() onMessageSend;
  final Function() onAttachmentTap;
  final TextEditingController textController;

  const ChatMessageSendingWidget({
    super.key,
    required this.onMessageSend,
    required this.textController,
    required this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onAttachmentTap,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.secondaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset:  Offset.zero,
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: CustomSvgPicture(
                "add_attachment",
                boxFit: BoxFit.contain,
                width: 20,
                height: 20,
                color: Theme.of(context).colorScheme.lightGreyColor,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: textController,
                maxLines: 5,
                minLines: 1,
                maxLength: UiUtils.maxCharactersInATextMessage,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "chatSendHint".translate(context: context),
                  counterText: "",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 14,
                  ),
                ),
                onSubmitted: (value) {
                  onMessageSend();
                },
                cursorColor: Theme.of(context).colorScheme.secondary,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          CustomInkWellContainer(
            onTap: onMessageSend,
            child: CustomContainer(
              borderRadius: 5,
              height: 48,
              width: 48,
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.accentColor,
              child: Center(
                child: CustomSvgPicture(
                  "send_message",
                  boxFit: BoxFit.contain,
                  width: 24,
                  height: 24,
                  color: AppColors.whiteColors,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
