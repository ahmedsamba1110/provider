import 'package:edemand_partner/app/generalImports.dart';
import 'package:edemand_partner/data/model/chat/chatUser.dart';
import 'package:flutter/material.dart';

class ChatUserItemWidget extends StatelessWidget {
  final ChatUser chatUser;
  final bool showCount;

  const ChatUserItemWidget({super.key, required this.chatUser, this.showCount = true});

  final double _chatUserContainerHeight = 80;

  Widget _profileImageBuilder({required String imageUrl, required BuildContext context}) {
    return CustomContainer(
      clipBehavior: Clip.antiAlias,
      borderRadius: 50,
      height: 60,
      width: 60,
      child: imageUrl.trim().isEmpty || imageUrl.toLowerCase() == "null"
          ? const CustomSvgPicture(
              "d_profile",
              boxFit: BoxFit.fill,
            )
          : CustomCachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.fill,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, Routes.chatMessages, arguments: {
            "chatUser": chatUser,
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: CustomContainer(
          height: _chatUserContainerHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          borderRadius: UiUtils.borderRadiusOf10,
          color: Theme.of(context).colorScheme.secondaryColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _profileImageBuilder(
                imageUrl: chatUser.avatar,
                context: context,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      chatUser.name,
                      maxLines: 1,
                      color: Theme.of(context).secondaryHeaderColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    if (chatUser.bookingId == "0") ...[
                      CustomText(
                        "preBookingEnquiry".translate(context: context),
                        color: context.colorScheme.lightGreyColor,
                        fontSize: 12.0,
                      ),
                    ] else ...[
                      CustomText(
                        "${"bookingId".translate(context: context)} - ${chatUser.bookingId}",
                        color: context.colorScheme.lightGreyColor,
                        fontSize: 12.0,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomText(
                          "${"bookingStatus".translate(context: context)} - ${chatUser.bookingStatus.toString().toLowerCase().translate(context: context)}",
                          color: context.colorScheme.lightGreyColor,
                          fontSize: 12.0),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
