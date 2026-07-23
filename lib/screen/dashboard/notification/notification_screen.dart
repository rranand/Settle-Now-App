import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/auth/auth_bloc.dart';
import 'package:settlenow/bloc/notification/notification_bloc.dart';
import 'package:settlenow/constant/ui_constant.dart';
import 'package:settlenow/model/notification_model.dart';
import 'package:settlenow/model/user_model.dart';
import 'package:settlenow/provider/screen_size_provider.dart';
import 'package:settlenow/util/card/notification_card.dart';
import 'package:settlenow/util/handler/filter_sort.dart';
import 'package:settlenow/util/widgets/custom_form_field.dart';
import 'package:settlenow/util/widgets/snackbar.dart';
import 'package:settlenow/util/widgets/widgets.dart';

class NotificationScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const NotificationScreen({super.key, required this.isSearchEnabled});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  UserModel _loggedInUser = UserModel.empty();
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final TextEditingController _searchController = TextEditingController();

  void _blocListenerHandler(BuildContext context, NotificationState state) {
    if (state is NotificationFailure) {
      showNormalSnackBar(context, state.error);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      final state = context.read<NotificationBloc>().state;

      if (state is! NotificationFetchSuccess) {
        context.read<NotificationBloc>().add(NotificationFetch());
      }
    }
    widget.isSearchEnabled.addListener(() {
      _searchController.text = "";
    });
  }

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(context, "Please re-login...Session expired!");
      return;
    }
    context.read<NotificationBloc>().add(NotificationFetch());
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > UiConstant.maxWidth;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        notificationPredicate: (ScrollNotification notification) {
          final state = context.read<NotificationBloc>().state;
          if (state is NotificationFetchSuccess && state.data.isNotEmpty) {
            return notification.depth == 0;
          } else {
            return notification.depth == 1;
          }
        },
        child: CustomScrollView(
          slivers: [
            ValueListenableBuilder(
              valueListenable: widget.isSearchEnabled,
              builder: (BuildContext context, bool value, Widget? _) {
                if (!value) {
                  return SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverPadding(
                  padding: _mainScreenPadding,
                  sliver: SliverAppBar(
                    automaticallyImplyLeading: false,
                    pinned: value,
                    title: CustomFormField.searchBar(
                      "Search",
                      widget.isSearchEnabled,
                      _searchController,
                    ),
                  ),
                );
              },
            ),
            BlocConsumer<NotificationBloc, NotificationState>(
              listener: _blocListenerHandler,
              builder: (context, state) {
                List<NotificationModel> notificationData = [];
                if (state is NotificationFetchSuccess) {
                  notificationData = state.data;
                } else if (state is NotificationLoading) {
                  notificationData = List.generate(
                    11,
                    (i) => NotificationModel.empty(),
                  );
                }
                if (notificationData.isEmpty) {
                  return SliverToBoxAdapter(
                    child: noRecordFoundWidget(
                      "No Notification Found",
                      context,
                    ),
                  );
                }

                return SliverPadding(
                  padding: _mainScreenPadding.add(
                    EdgeInsets.only(
                      top: UiConstant.spaceBetweenCard,
                      bottom: UiConstant.spaceAtBottom,
                    ),
                  ),
                  sliver: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, _, _) {
                      List<NotificationModel> filterData = notificationData;
                      if (state is NotificationFetchSuccess) {
                        filterData = FilterSort.filteredSearchText(
                          _searchController.text,
                          notificationData,
                          (notificationData) {
                            String searchStr =
                                "${notificationData.roomName} ${notificationData.type}";
                            if (notificationData.by.id != _loggedInUser.id) {
                              searchStr += " ${notificationData.by.name}";
                            }
                            if (notificationData.user.id != _loggedInUser.id) {
                              searchStr += " ${notificationData.user.name}";
                            }
                            return searchStr;
                          },
                        );
                      }

                      if (filterData.isEmpty) {
                        return noRecordFoundWidget(
                          "No Matching Records",
                          context,
                        );
                      }

                      int noOfCardsToBeShown = filterData.length;
                      if (isWide) {
                        noOfCardsToBeShown =
                            (noOfCardsToBeShown / 2).toInt() +
                            noOfCardsToBeShown % 2;
                      }
                      return SliverList.builder(
                        itemCount: noOfCardsToBeShown,
                        itemBuilder: (context, index) {
                          if (isWide) {
                            NotificationModel eachNotificationData =
                                filterData[2 * index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: NotificationCard(
                                    data: eachNotificationData,
                                    loggedInUserID: _loggedInUser.id,
                                  ),
                                ),
                                Expanded(
                                  child:
                                      (index == noOfCardsToBeShown - 1 &&
                                              filterData.length % 2 > 0)
                                          ? SizedBox()
                                          : NotificationCard(
                                            data: filterData[2 * index + 1],
                                            loggedInUserID: _loggedInUser.id,
                                          ),
                                ),
                              ],
                            );
                          } else {
                            return NotificationCard(
                              data: filterData[index],
                              loggedInUserID: _loggedInUser.id,
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
