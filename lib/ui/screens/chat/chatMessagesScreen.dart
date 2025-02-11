import 'package:edemand_partner/app/generalImports.dart';
import 'package:edemand_partner/cubits/chat/chatMessagesCubit.dart';
import 'package:edemand_partner/cubits/chat/chatUsersCubit.dart';
import 'package:edemand_partner/data/model/chat/chatMessage.dart';
import 'package:edemand_partner/data/model/chat/chatUser.dart';
import 'package:edemand_partner/data/repository/chat/chatRepository.dart';
import 'package:edemand_partner/ui/screens/chat/widgets/attachmentBottomsheetWidget.dart';
import 'package:edemand_partner/ui/screens/chat/widgets/messageSendingWidget.dart';
import 'package:edemand_partner/ui/screens/chat/widgets/singleMessageItem.dart';
import 'package:edemand_partner/utils/Notification/chatNotificationsUtils.dart';
import 'package:edemand_partner/utils/dateTimeExtension.dart';
import 'package:flutter/material.dart';

class ChatMessagesScreen extends StatefulWidget {
  final ChatUser chatUser;

  const ChatMessagesScreen({
    super.key,
    required this.chatUser,
  });

  @override
  State<ChatMessagesScreen> createState() => _ChatMessagesScreenState();

  static Route route(RouteSettings routeSettings) {
    final Map<String, dynamic> arguments =
        routeSettings.arguments as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) => BlocProvider<ChatMessagesCubit>(
        create: (context) => ChatMessagesCubit(
          ChatRepository(),
        ),
        child: ChatMessagesScreen(
          chatUser: arguments["chatUser"] ?? ChatUser.fromJson({}),
        ),
      ),
    );
  }
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  final _chatMessageSendTextController = TextEditingController();

  late final ScrollController _scrollController = ScrollController()
    ..addListener(_notificationsScrollListener);

  //to check sent or received messages
  String senderId = '-1';

  void _notificationsScrollListener() {
    //
    if (context.read<ChatMessagesCubit>().hasMore()) {
      final nextPageTrigger = 0.7 * _scrollController.position.maxScrollExtent;

      if (_scrollController.position.pixels > nextPageTrigger) {
        if (mounted) {
          context.read<ChatMessagesCubit>().fetchMoreChatMessages(
                bookingId: widget.chatUser.bookingId.toString(),
                type: widget.chatUser.receiverType,
                customerId: widget.chatUser.id.toString(),
              );
        }
      }
    }
  }

  @override
  void initState() {
    Routes.currentRoute = Routes.chatMessages;

    Future.delayed(Duration.zero, () {
      fetchChatMessages();
      senderId = widget.chatUser.senderId ?? "0";
    });
    //register user id with which the current user is talking with
    ChatNotificationsUtils.currentChattingUserHashCode =
        widget.chatUser.hashCode;
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_notificationsScrollListener);
    _scrollController.dispose();
    _chatMessageSendTextController.dispose();

    super.dispose();
  }

  void fetchChatMessages() {
    context.read<ChatMessagesCubit>().fetchChatMessages(
          bookingId: widget.chatUser.bookingId.toString(),
          type: widget.chatUser.receiverType.toString(),
          chatUsersCubitArgument: context.read<ChatUsersCubit>(),
          customerId: widget.chatUser.id,
        );
  }

  Widget _buildShimmerLoader() {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return SizedBox(
          height: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                15,
                (index) => _buildOneChatShimmerLoader(boxConstraints),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOneChatShimmerLoader(BoxConstraints boxConstraints) {
    final bool isStart = Random().nextBool();
    return Align(
      alignment: isStart
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: ShimmerLoadingContainer(
          child: CustomShimmerContainer(
            height: 30,
            width: boxConstraints.maxWidth * 0.8,
            borderRadius: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDateLabel({required DateTime date}) {
    return CustomText(
      date.isToday()
          ? "today".translate(context: context)
          : date.isYesterday()
              ? "yesterday".translate(context: context)
              : date.toString().split(" ").first.formatDate(),
      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
      fontSize: 12,
    );
  }

  Widget _loadingMoreChatsWidget() {
    return CustomContainer(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      borderRadius: 12,
      color: Theme.of(context).colorScheme.secondaryColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CustomCircularProgressIndicator(
              color: Theme.of(context).colorScheme.accentColor,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: CustomText(
              "loadingMoreChats".translate(context: context),
              maxLines: 1,
              fontSize: 12,
              color: Theme.of(context).colorScheme.lightGreyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingMoreErrorWidget({required Function() onTapRetry}) {
    return GestureDetector(
      onTap: onTapRetry,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.secondaryColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              size: 16,
              color: Theme.of(context).colorScheme.accentColor,
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: CustomText(
                "errorLoadingMoreRetry".translate(context: context),
                maxLines: 1,
                fontSize: 12,
                color: AppColors.redColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        //removing currently talking user's id
        ChatNotificationsUtils.currentChattingUserHashCode = null;

        //clearing current route when going back to make the onTap of notification routing properly work
        Routes.currentRoute = "";
      },
      child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
            automaticallyImplyLeading: false,
            toolbarHeight: size.height * .08,
            elevation: 1,
            titleSpacing: 2,
            backgroundColor: Theme.of(context).colorScheme.secondaryColor,
            leading: const CustomBackArrow(),
            title: SizedBox(
              width: double.maxFinite,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //it means customer chatting with customer
                  if (widget.chatUser.receiverType == "2") ...[
                    Expanded(
                      flex: 1,
                      child: CustomContainer(
                        clipBehavior: Clip.antiAlias,
                        height: 40,
                        width: 40,
                        borderRadius: 50,
                        child: widget.chatUser.avatar.trim().isEmpty ||
                                widget.chatUser.avatar.toLowerCase() == "null"
                            ? const CustomSvgPicture("d_profile")
                            : CustomCachedNetworkImage(
                                imageUrl: widget.chatUser.avatar,
                                fit: BoxFit.fill,
                                height: 40,
                                width: 40,
                              ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                  ],

                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                            widget.chatUser.userName
                                .translate(context: context),
                            color: Theme.of(context).colorScheme.blackColor,
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                            fontSize: 18.0),
                        if (widget.chatUser.receiverType == "2") ...[
                          if (widget.chatUser.bookingId != "0") ...[
                            CustomText(
                                "${"bookingId".translate(context: context)}- ${widget.chatUser.bookingId}",
                                color: Theme.of(context)
                                    .colorScheme
                                    .lightGreyColor,
                                fontSize: 14.0),
                          ] else ...[
                            CustomText(
                              "preBookingEnquiry".translate(context: context),
                              color:
                                  Theme.of(context).colorScheme.lightGreyColor,
                              fontSize: 14.0,
                            ),
                          ]
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: (widget.chatUser.bookingStatus?.toLowerCase() !=
                      "cancelled" &&
                  widget.chatUser.bookingStatus?.toLowerCase() != "completed")
              ? Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  color: Theme.of(context).colorScheme.secondaryColor,
                  child: ChatMessageSendingWidget(
                    onMessageSend: () {
                      if (_chatMessageSendTextController.text
                          .trim()
                          .isNotEmpty) {
                        context.read<ChatMessagesCubit>().sendChatMessage(
                            context: context,
                            chatMessage: ChatMessage(
                              messageType: ChatMessageType.textMessage,
                              files: [],
                              message:
                                  _chatMessageSendTextController.text.trim(),
                              isLocallyStored: true,
                              id: DateTime.now()
                                  .microsecondsSinceEpoch
                                  .toString(),
                              sendOrReceiveDateTime: DateTime.now(),
                              receiverId: widget.chatUser.providerId,
                              senderId: senderId,
                              senderDetails: SenderDetails.fromJson({}),
                            ),
                            receiverId: widget.chatUser.id.toString(),
                            chatUserCubit: context.read<ChatUsersCubit>(),
                            chattingWith: widget.chatUser,
                            bookingId: widget.chatUser.bookingId);
                        _chatMessageSendTextController.clear();
                      }
                    },
                    onAttachmentTap: () {
                      UiUtils.showModelBottomSheets(
                          context: context,
                          child: AttachmentDialogWidget(
                            onCancel: () {
                              Navigator.pop(context);
                            },
                            onItemSelected: (selectedFilePaths, isImage) {
                              Navigator.pop(context);
                              context.read<ChatMessagesCubit>().sendChatMessage(
                                  context: context,
                                  chatMessage: ChatMessage(
                                    messageType: isImage
                                        ? ChatMessageType.imageMessage
                                        : ChatMessageType.fileMessage,
                                    message: "",
                                    files: selectedFilePaths.map((e) {
                                      return MessageDocument(
                                          fileName: e.fileName,
                                          fileSize: e.fileSize,
                                          fileType: e.fileType,
                                          fileUrl: e.fileUrl);
                                    }).toList(),
                                    isLocallyStored: true,
                                    id: DateTime.now()
                                        .microsecondsSinceEpoch
                                        .toString(),
                                    sendOrReceiveDateTime: DateTime.now(),
                                    receiverId: widget.chatUser.providerId,
                                    senderId: senderId,
                                    senderDetails: SenderDetails.fromJson({}),
                                  ),
                                  receiverId: widget.chatUser.id.toString(),
                                  chatUserCubit: context.read<ChatUsersCubit>(),
                                  chattingWith: widget.chatUser,
                                  bookingId: widget.chatUser.bookingId);
                            },
                          ));
                      return;
                    },
                    textController: _chatMessageSendTextController,
                  ),
                )
              : CustomContainer(
                  borderRadius: 12,
                  padding: const EdgeInsets.all(10),
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  color: Theme.of(context)
                      .colorScheme
                      .accentColor
                      .withValues(alpha: 0.3),
                  child: CustomText(
                    "youCantMessageToProviderMessage"
                        .translate(context: context),
                    color: Theme.of(context).colorScheme.accentColor,
                    fontSize: 12,
                    textAlign: TextAlign.center,
                  ),
                ),
          body: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 8,
              end: 8,
            ),
            child: BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
              builder: (context, state) {
                if (state is ChatMessagesFetchSuccess) {
                  return Stack(
                    children: [
                      state.chatMessages.isEmpty
                          ? widget.chatUser.bookingStatus?.toLowerCase() !=
                                      "cancelled" &&
                                  widget.chatUser.bookingStatus
                                          ?.toLowerCase() !=
                                      "completed"
                              ? _emptyChatWidget()
                              : Center(
                                  child: NoDataContainer(
                                      titleKey: "noChatHistoryFound"
                                          .translate(context: context)))
                          : ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: state.chatMessages.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    //if it's 1st item - reverse scroll so last then show date label
                                    //or if an item's date is not the same as next item, show date label
                                    if (index == (state.chatMessages.length - 1) ||
                                        (!state.chatMessages[index]
                                            .sendOrReceiveDateTime
                                            .isSameAs(state
                                                .chatMessages[index ==
                                                        (state.chatMessages
                                                                .length -
                                                            1)
                                                    ? (state.chatMessages
                                                            .length -
                                                        1)
                                                    : index + 1]
                                                .sendOrReceiveDateTime)))
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 5),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Divider(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              _buildDateLabel(
                                                  date: state
                                                      .chatMessages[index]
                                                      .sendOrReceiveDateTime),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Divider(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ],
                                          )),
                                    SingleChatMessageItem(
                                      key: ValueKey(
                                          state.chatMessages[index].id),
                                      senderId: senderId,
                                      //if it's 1st item, show time by default, if sender id and time is not same show time, otherwise don't show time
                                      showTime: index == 0
                                          ? true
                                          : !(UiUtils.formatTimeWithDateTime(
                                                    state.chatMessages[index]
                                                        .sendOrReceiveDateTime,
                                                  ) ==
                                                  UiUtils
                                                      .formatTimeWithDateTime(
                                                    state
                                                        .chatMessages[index - 1]
                                                        .sendOrReceiveDateTime,
                                                  ) &&
                                              state.chatMessages[index]
                                                      .senderId ==
                                                  state.chatMessages[index - 1]
                                                      .senderId),
                                      chatMessage: state.chatMessages[index],
                                      isLoading: state.loadingIds.contains(
                                          state.chatMessages[index].id),
                                      isError: state.errorIds.contains(
                                          state.chatMessages[index].id),
                                      onRetry: (ChatMessage chatMessage) {
                                        context
                                            .read<ChatMessagesCubit>()
                                            .sendChatMessage(
                                              context: context,
                                              chatMessage: chatMessage,
                                              receiverId:
                                                  widget.chatUser.id.toString(),
                                              chatUserCubit: context
                                                  .read<ChatUsersCubit>(),
                                              chattingWith: widget.chatUser,
                                              bookingId:
                                                  widget.chatUser.bookingId,
                                              isRetry: true,
                                            );
                                      },
                                    ),
                                    if (index == 0) //padding to latest message
                                      const SizedBox(
                                        height: 10,
                                      ),
                                  ],
                                );
                              }),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 25,
                          ),
                          child: state.moreChatMessageFetchProgress
                              ? _loadingMoreChatsWidget()
                              : state.moreChatMessageFetchError
                                  ? _loadingMoreErrorWidget(onTapRetry: () {
                                      context
                                          .read<ChatMessagesCubit>()
                                          .fetchMoreChatMessages(
                                            bookingId: widget.chatUser.bookingId
                                                .toString(),
                                            type: widget.chatUser.receiverType
                                                .toString(),
                                            customerId:
                                                widget.chatUser.id.toString(),
                                          );
                                    })
                                  : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  );
                }
                if (state is ChatMessagesFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessage: state.errorMessage,
                      onTapRetry: () {
                        fetchChatMessages();
                      },
                    ),
                  );
                }
                return _buildShimmerLoader();
              },
            ),
          )),
    );
  }

  Widget _emptyChatWidget() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomContainer(
              borderRadius: 50,
              height: 80,
              width: 80,
              color: Theme.of(context)
                  .colorScheme
                  .accentColor
                  .withValues(alpha: 0.3),
              child: Icon(
                Icons.question_answer_rounded,
                color: Theme.of(context).colorScheme.accentColor,
                size: 45,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            CustomText(
              (widget.chatUser.receiverType == "2"
                      ? "customerChatEmptyScreenHeading"
                      : "adminChatEmptyScreenHeading")
                  .translate(context: context),
              fontWeight: FontWeight.w600,
              fontSize: 20,
              textAlign: TextAlign.center,
            ),
            if (UiUtils.chatPredefineMessagesForProvider.isNotEmpty &&
                widget.chatUser.receiverType == "2") ...[
              const SizedBox(
                height: 20,
              ),
              ListView.separated(
                shrinkWrap: true,
                itemCount: UiUtils.chatPredefineMessagesForProvider.length,
                itemBuilder: (context, index) {
                  return _buildPredefineMessageWidget(
                    message: UiUtils.chatPredefineMessagesForProvider[index],
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                  height: 10,
                ),
              ),
            ],
            if (UiUtils.chatPredefineMessagesForAdmin.isNotEmpty &&
                widget.chatUser.receiverType == "0") ...[
              const SizedBox(
                height: 20,
              ),
              ListView.separated(
                shrinkWrap: true,
                itemCount: UiUtils.chatPredefineMessagesForProvider.length,
                itemBuilder: (context, index) {
                  return _buildPredefineMessageWidget(
                    message: UiUtils.chatPredefineMessagesForAdmin[index],
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                  height: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPredefineMessageWidget({required String message}) {
    return GestureDetector(
      onTap: () {
        context.read<ChatMessagesCubit>().sendChatMessage(
            context: context,
            chatMessage: ChatMessage(
              messageType: ChatMessageType.textMessage,
              files: [],
              message: message.translate(context: context),
              isLocallyStored: true,
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              sendOrReceiveDateTime: DateTime.now(),
              receiverId: widget.chatUser.providerId,
              senderId: senderId,
              senderDetails: SenderDetails.fromJson({}),
            ),
            receiverId: widget.chatUser.id.toString(),
            chatUserCubit: context.read<ChatUsersCubit>(),
            chattingWith: widget.chatUser,
            bookingId: widget.chatUser.bookingId);
      },
      child: Align(
        alignment: Alignment.center,
        child: CustomContainer(
          color:
              Theme.of(context).colorScheme.accentColor.withValues(alpha: 0.1),
          borderRadius: 12,
          padding: const EdgeInsets.all(10),
          child: CustomText(
            message.translate(context: context),
            color: Theme.of(context).colorScheme.accentColor,
            textAlign: TextAlign.center,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
