import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) {
      return const NotificationScreen();
    },);
  }

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  void fetchNotifications() {
    context.read<NotificationsCubit>().fetchNotifications();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (BuildContext context, NotificationsState state) {
          if (state is NotificationsInProgress) {
            return ShimmerLoadingContainer(
                child: ListView(
              children: List.generate(
                  5,
                  (int index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomShimmerContainer(
                          borderRadius: UiUtils.borderRadiusOf10,
                          width: MediaQuery.sizeOf(context).width,
                          height: 92,
                        ),
                      ),).toList(),
            ),);
          }
          if (state is NotificationFetchFailure) {
            return Center(
                child: ErrorContainer(
                    onTapRetry: () {
                      fetchNotifications();
                    },
                    errorMessage: state.toString().translate(context: context),),);
          }
          if (state is NotificationFetchSuccess) {
            if (state.notifications.isEmpty) {
              return NoDataContainer(titleKey: 'noDataFound'.translate(context: context));
            }

            return ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (BuildContext context, int i) {
                  return const SizedBox.shrink();

                },);
          }
          return const CustomContainer();
        },
      ),
    );
  }
}
