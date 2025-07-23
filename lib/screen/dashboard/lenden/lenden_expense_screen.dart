import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/room/lenden_room_bloc.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/filter/filter_cubit.dart';
import 'package:settlenow_v2/cubit/lenden/create_room/create_room_cubit.dart';
import 'package:settlenow_v2/model/lenden_room_model.dart';
import 'package:settlenow_v2/model/lenden_user_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/card/lenden_expense_card.dart';
import 'package:settlenow_v2/util/card/lenden_summary_card.dart';
import 'package:settlenow_v2/util/enum/transaction_type.dart';
import 'package:settlenow_v2/util/filter/filter_sheet.dart';
import 'package:settlenow_v2/util/handler/filter_sort.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/gradient_widget.dart';
import 'package:settlenow_v2/util/widgets/image_widget.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class LendenExpenseScreen extends StatefulWidget {
  final String id;
  final String? roomName;

  const LendenExpenseScreen({super.key, required this.id, this.roomName});

  @override
  State<LendenExpenseScreen> createState() => _LendenExpenseScreenState();
}

class _LendenExpenseScreenState extends State<LendenExpenseScreen> {
  final ValueNotifier<bool> isSearchEnabled = ValueNotifier(false);
  final TextEditingController _searchController = TextEditingController();
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  UserModel _loggedInUser = UserModel.empty();
  String currentRoute = "";
  late final StreamSubscription _createRoomListener;

  void _blocListenerHandler(BuildContext context, LendenRoomState state) {
    if (state is LendenRoomFailure) {
      showNormalSnackBar(context, state.error);
    }
  }

  List<LendenTransactionModel> generateShimmerData() {
    return List.generate(11, (i) {
      LendenTransactionModel tempData = LendenTransactionModel.empty();
      if (i % 2 == 0) {
        tempData.createdBy.id = _loggedInUser.id;
      }
      return tempData;
    });
  }

  void filterModelBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: const EdgeInsets.all(
            16.0,
          ).add(EdgeInsets.only(bottom: keyboardHeight)),
          child: FilterSheet(
            id: widget.id,
            transactionType: TransactionType.lenden,
          ),
        );
      },
    );
  }

  void _closeRoomPopupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Close Room"),
          content: Text("Are You Sure?", style: TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                context.read<LendenRoomBloc>().add(
                  LendenCloseRoom(
                    authToken: _loggedInUser.authToken,
                    uid: _loggedInUser.id,
                  ),
                );
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, List<LendenUserModel> oldUsers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        return BlocBuilder<LendenRoomBloc, LendenRoomState>(
          builder: (context, state) {
            bool showAddPerson = false;
            List<LendenUserModel> users = [];
            if (state is LendenRoomFetchSuccess) {
              users = state.roomData.users;
              if (state.roomData.status == "Open" && users.length == 1) {
                showAddPerson = true;
              }
            } else {
              users = oldUsers;
            }
            return Padding(
              padding: const EdgeInsets.all(
                16.0,
              ).add(EdgeInsets.only(bottom: keyboardHeight)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 60,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Users",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Visibility(
                        visible: showAddPerson,
                        child: IconButton(
                          icon: Icon(Iconsax.user_add),
                          onPressed: () async {
                            CreateRoomCubit createRoomCubit =
                                context.read<CreateRoomCubit>();
                            ScaffoldMessengerState scaffoldMessengerState =
                                ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);

                            final userDataFromScreen =
                                await context.push(
                                      currentRoute +
                                          RouterConstants.inviteMember,
                                      extra: {
                                        "transactionType":
                                            TransactionType.lenden,
                                      },
                                    )
                                    as List<UserModel>?;
                            if (userDataFromScreen != null &&
                                userDataFromScreen.isNotEmpty &&
                                userDataFromScreen.first.hasData) {
                              navigator.pop();
                              createRoomCubit.inviteMember(
                                widget.id,
                                userDataFromScreen.first,
                                _loggedInUser.authToken,
                                scaffoldMessengerState,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: List.generate(users.length, (index) {
                        return ListTile(
                          leading: imageWidgetForCachedNetworkImage(
                            users[index].profileImage,
                            width: 45,
                            height: 45,
                            boxShape: BoxShape.circle,
                          ),
                          title: Text(users[index].name),
                          subtitle: Text(
                            users[index].isClosed ? "Closed" : "Open",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing:
                              _loggedInUser.id == users[index].id &&
                                      !users[index].isClosed
                                  ? IconButton(
                                    icon: Icon(Iconsax.unlock),
                                    onPressed: () => _closeRoomPopupDialog(),
                                  )
                                  : null,
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: InkWell(
                      onTap: () => context.pop(),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * .9,
                        child: GradientWidget(
                          text: "Close",
                          gradientColors:
                              GradientColorConstant.coolIndigoToBlue,
                          textSize: 14,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
    currentRoute =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      context.read<FilterCubit>().updateState(
        FilterState(id: widget.id),
        _loggedInUser.id,
        TransactionType.lenden,
      );

      final state = context.read<LendenRoomBloc>().state;

      if (!(state is LendenRoomFetchSuccess && state.id == widget.id)) {
        context.read<LendenRoomBloc>().add(
          LendenRoomFetch(id: widget.id, authToken: _loggedInUser.authToken),
        );
      }
    }

    _createRoomListener = context.read<CreateRoomCubit>().stream.listen((
      state,
    ) {
      if (mounted && state is CreateRoomFailure) {
        showNormalSnackBar(context, state.error);
      }
    });
  }

  Widget transactionCardDisplay(
    List<LendenTransactionModel> data,
    bool isEditable,
  ) {
    return SliverList.builder(
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == data.length - 1 ? UiConstant.spaceAtBottom : 0,
          ),
          child: LendenExpenseCard(
            lendenID: widget.id,
            data: data[index],
            loggedInUser: _loggedInUser,
            isEditable: isEditable,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _createRoomListener.cancel();
    super.dispose();
  }

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(context, "Please re-login...Session expired!");
      return;
    }
    context.read<LendenRoomBloc>().add(
      LendenRoomFetch(id: widget.id, authToken: _loggedInUser.authToken),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final state = context.watch<LendenRoomBloc>().state;
    if (state is LendenRoomFetchSuccess) {
      return AppBar(
        title: Text(state.roomData.roomName),
        titleSpacing: _mainScreenPadding.left,
        centerTitle: false,
        leading: appBarBackButton(context),
        actions: appBarActionButton(context, [
          IconButton(
            onPressed: () => _showBottomSheet(context, state.roomData.users),
            icon: Icon(Iconsax.profile_2user),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              isSearchEnabled.value = !isSearchEnabled.value;
              _searchController.text = "";
            },
          ),
          IconButton(
            icon: BlocBuilder<FilterCubit, FilterState>(
              builder: (context, state) {
                bool haveFilter = state.isFilterApplied;
                return Icon(
                  haveFilter ? Iconsax.filter_tick : Iconsax.filter,
                  color: haveFilter ? Colors.green : null,
                );
              },
            ),
            onPressed: () => filterModelBottomSheet(context),
          ),
        ]),
      );
    } else {
      return AppBar(
        title:
            widget.roomName == null
                ? CustomShimmerEffect.textWidget(width: 180, fontSize: 20)
                : Text(widget.roomName!),
        titleSpacing: _mainScreenPadding.left,
        centerTitle: false,
        leading: appBarBackButton(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= UiConstant.maxWidth;
    EdgeInsets paddingInsets = _mainScreenPadding;
    if (!isWide) {
      paddingInsets = EdgeInsets.symmetric(horizontal: 8);
    }
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: BlocConsumer<LendenRoomBloc, LendenRoomState>(
          listener: _blocListenerHandler,
          builder: (context, state) {
            List<LendenTransactionModel> lendenTransactionData = [];
            LendenUserModel loggedInUserData = LendenUserModel.empty();
            bool isEditable = false;
            bool isLoaded = false;

            if (state is LendenRoomFetchSuccess) {
              isLoaded = true;
              lendenTransactionData = state.data;
              loggedInUserData = state.roomData.users.firstWhere(
                (ele) => ele.id == _loggedInUser.id,
              );

              isEditable = !loggedInUserData.isClosed;

              context.read<FilterCubit>().updateState(
                FilterState(id: state.id, data: state.data),
                loggedInUserData.id,
                TransactionType.lenden,
              );

              if (lendenTransactionData.isEmpty) {
                return noRecordFoundWidget("No Transaction Found", context);
              }
            }

            return CustomScrollView(
              slivers:
                  isLoaded
                      ? [
                        ValueListenableBuilder(
                          valueListenable: isSearchEnabled,
                          builder: (BuildContext context, _, _) {
                            if (!isSearchEnabled.value) {
                              return SliverToBoxAdapter(
                                child: SizedBox.shrink(),
                              );
                            }
                            return SliverPadding(
                              padding: _mainScreenPadding,
                              sliver: SliverAppBar(
                                automaticallyImplyLeading: false,
                                pinned: isSearchEnabled.value,
                                backgroundColor: Colors.white,
                                surfaceTintColor: Colors.white,
                                title: CustomFormField.searchBar(
                                  "Search",
                                  isSearchEnabled,
                                  _searchController,
                                ),
                              ),
                            );
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: isSearchEnabled,
                          builder: (context, _, _) {
                            return BlocBuilder<FilterCubit, FilterState>(
                              builder: (context, filterState) {
                                if (filterState.isFilterApplied ||
                                    isSearchEnabled.value) {
                                  return SliverToBoxAdapter(
                                    child: SizedBox.shrink(),
                                  );
                                }
                                return SliverPadding(
                                  padding: paddingInsets.add(
                                    EdgeInsets.only(
                                      bottom: UiConstant.spaceBetweenSection,
                                    ),
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: LendenSummaryCard(
                                      data: lendenTransactionData,
                                      loggedInUser: _loggedInUser,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        SliverPadding(
                          padding: _mainScreenPadding,
                          sliver: BlocBuilder<FilterCubit, FilterState>(
                            builder: (context, filterState) {
                              return ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _searchController,
                                builder: (context, _, _) {
                                  List<LendenTransactionModel> searchedData =
                                      filterState.data
                                          .cast<LendenTransactionModel>();

                                  searchedData = FilterSort.filteredSearchText(
                                    _searchController.text,
                                    searchedData,
                                    (transData) {
                                      String searchStr = transData.description;
                                      searchStr +=
                                          " ${transData.createdBy.name}";
                                      searchStr += " ${transData.amount}";
                                      return searchStr;
                                    },
                                  );

                                  if (searchedData.isEmpty) {
                                    return SliverToBoxAdapter(
                                      child: noRecordFoundWidget(
                                        "No Matching Records",
                                        context,
                                      ),
                                    );
                                  }
                                  return transactionCardDisplay(
                                    searchedData,
                                    isEditable,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ]
                      : [
                        transactionCardDisplay(
                          generateShimmerData(),
                          isEditable,
                        ),
                      ],
            );
          },
        ),
      ),
      floatingActionButton: BlocBuilder<LendenRoomBloc, LendenRoomState>(
        builder: (context, state) {
          if (state is LendenRoomFetchSuccess) {
            LendenUserModel loggedInUserData = state.roomData.users.firstWhere(
              (ele) => ele.id == _loggedInUser.id,
            );
            if (loggedInUserData.isClosed) {
              return SizedBox.shrink();
            } else {
              return CustomButton.customFloatingButton(Iconsax.add, () {
                context.push(
                  "${RouterConstants.lendenRouteName}/${widget.id}${RouterConstants.lendenAddExpenseRouteName}",
                );
              });
            }
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
