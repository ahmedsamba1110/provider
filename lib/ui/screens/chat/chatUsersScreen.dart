import 'package:edemand_partner/app/generalImports.dart';
import 'package:edemand_partner/cubits/chat/chatUsersCubit.dart';
import 'package:edemand_partner/data/model/chat/chatUser.dart';
import 'package:edemand_partner/ui/screens/chat/widgets/chatUserItem.dart';
import 'package:edemand_partner/ui/widgets/customLoadingMoreContainer.dart';
import 'package:flutter/material.dart';

class ChatUsersScreen extends StatefulWidget {
  const ChatUsersScreen({
    super.key,
  });

  @override
  State<ChatUsersScreen> createState() => _ChatUsersScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => const ChatUsersScreen(),
    );
  }
}

class _ChatUsersScreenState extends State<ChatUsersScreen> {
  late final ScrollController _scrollController = ScrollController()
    ..addListener(_chatUserScrollListener);

  void _chatUserScrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
      if (context.read<ChatUsersCubit>().hasMore()) {
        context.read<ChatUsersCubit>().fetchMoreChatUsers();
      }
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      fetchChatUsers();
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_chatUserScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void fetchChatUsers() {
    context.read<ChatUsersCubit>().fetchChatUsers();
  }

  Widget _buildShimmerLoader() {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return SizedBox(
          height: double.maxFinite,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _buildOneChatUserShimmerLoader();
            },
          ),
        );
      },
    );
  }

  Widget _buildOneChatUserShimmerLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: ShimmerLoadingContainer(
        child: CustomShimmerContainer(
          height: 80,
          borderRadius: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondaryColor,
        surfaceTintColor: Theme.of(context).colorScheme.secondaryColor,
        title: CustomText(
          'chat'.translate(context: context),
          color: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.bold,
        ),
        leading: const CustomBackArrow(),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 15),
            child: Tooltip(
              message: "customerSupport".translate(context: context),
              child: CustomInkWellContainer(
                onTap: () {
                  Navigator.pushNamed(context, Routes.chatMessages, arguments: {
                    "chatUser": ChatUser(
                      id: "-",
                      name: "customerSupport".translate(context: context),
                      receiverType: "0",
                      unReadChats: 0,
                      bookingId: "-1",
                      senderId:
                          context.read<ProviderDetailsCubit>().providerDetails.user?.id ?? "0",
                    ),
                  });
                },
                child: Icon(
                  Icons.support_agent,
                  color: context.colorScheme.blackColor,
                ),
              ),
            ),
          )
        ],
      ),
      body: BlocBuilder<ChatUsersCubit, ChatUsersState>(
        builder: (context, state) {
          if (state is ChatUsersFetchSuccess) {
            return state.chatUsers.isEmpty
                ? Center(
                    child: NoDataContainer(
                      titleKey: "noChatsFound".translate(context: context),
                    ),
                  )
                : CustomRefreshIndicator(
                    displacment: 12,
                    onRefresh: () {
                      fetchChatUsers();
                    },
                    child: SizedBox(
                      height: double.maxFinite,
                      width: double.maxFinite,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            ...List.generate(
                              state.chatUsers.length,
                              (index) {
                                final currentChatUser = state.chatUsers[index];

                                return ChatUserItemWidget(
                                  chatUser: currentChatUser.copyWith(
                                    receiverType: "2",
                                    unReadChats: 0,
                                    id: state.chatUsers[index].id,
                                    bookingId: state.chatUsers[index].bookingId.toString(),
                                    bookingStatus: state.chatUsers[index].bookingStatus.toString(),
                                    name: state.chatUsers[index].name.toString(),
                                    profile: state.chatUsers[index].profile,
                                    senderId: context
                                            .read<ProviderDetailsCubit>()
                                            .providerDetails
                                            .user
                                            ?.id ??
                                        "0",
                                  ),
                                );
                              },
                            ),
                            if (state.moreChatUserFetchProgress) _buildOneChatUserShimmerLoader(),
                            if (state.moreChatUserFetchError && !state.moreChatUserFetchProgress)
                              CustomLoadingMoreContainer(
                                isError: true,
                                onErrorButtonPressed: () {
                                  context.read<ChatUsersCubit>().fetchMoreChatUsers();
                                },
                              ),
                            const SizedBox(
                              height: 80,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
          }
          if (state is ChatUsersFetchFailure) {
            return Center(
              child: ErrorContainer(
                errorMessage: state.errorMessage,
                onTapRetry: () {
                  fetchChatUsers();
                },
              ),
            );
          }
          return _buildShimmerLoader();
        },
      ),
    );
  }
}
