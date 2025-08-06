import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/room/lenden_room_bloc.dart';
import 'package:settlenow_v2/bloc/notification/notification_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow_v2/cubit/user/friend/friend_cubit.dart';
import 'package:settlenow_v2/model/notification_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/enum/transaction_type.dart';
import 'package:settlenow_v2/util/handler/filter_sort.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class InviteMember extends StatefulWidget {
  final List<String> userID;
  final TransactionType transactionType;
  final bool inviteMember;
  const InviteMember({
    super.key,
    required this.userID,
    required this.transactionType,
    required this.inviteMember,
  });

  @override
  State<InviteMember> createState() => _InviteMemberState();
}

class _InviteMemberState extends State<InviteMember> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final double _userCardWidth = 110;
  final double _userImageRadius = 50;
  UserModel _loggedInUser = UserModel.empty();
  final ValueNotifier<Set<String>> _selectedUserIDs = ValueNotifier({});
  final ValueNotifier<Set<String>> _alreadyInvited = ValueNotifier({});
  final ValueNotifier<bool> _isLoaded = ValueNotifier(false);
  final ValueNotifier<bool> isSearchEnabled = ValueNotifier(false);
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    if (mounted) {
      setState(() {});
    }
  }

  void _fetchFriendData() {
    final friendCubitState = context.read<FriendCubit>().state;
    if (!(friendCubitState is FriendSuccess ||
        friendCubitState is FriendLoading)) {
      context.read<FriendCubit>().fetchLoginData(_loggedInUser);
    }
  }

  void _toggleSelectedUser(user) {
    if (widget.transactionType == TransactionType.lenden) {
      if (_alreadyInvited.value.isNotEmpty) {
        return;
      }
      _selectedUserIDs.value = {user.id};
    } else if (!_alreadyInvited.value.contains(user.id)) {
      final oldUserIDs = Set<String>.from(_selectedUserIDs.value);

      if (oldUserIDs.contains(user.id)) {
        oldUserIDs.remove(user.id);
      } else {
        oldUserIDs.add(user.id);
      }

      _selectedUserIDs.value = oldUserIDs;
    }
  }

  Widget _userCardWidget(UserModel user) {
    if (!user.hasData) {
      return Center(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomShimmerEffect.imageWidget(
                  radius: 50,
                  shape: BoxShape.circle,
                ),
                SizedBox(height: 8),
                CustomShimmerEffect.textWidget(width: 100),
              ],
            ),
            Positioned(
              left: _userImageRadius / 2 + 10,
              top: 0,
              bottom: 0,
              right: 0,
              child:
                  _selectedUserIDs.value.contains(user.id)
                      ? Icon(Icons.check_circle, color: Colors.green, size: 24)
                      : SizedBox.shrink(),
            ),
          ],
        ),
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () => _toggleSelectedUser(user),
      child: Center(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                overlapUserImageWidget(context, [user], 1, imageRadius: 50),
                SizedBox(height: 8),
                Text(
                  user.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            Positioned(
              left: _userImageRadius / 2 + 10,
              top: 0,
              bottom: 0,
              right: 0,
              child:
                  _selectedUserIDs.value.contains(user.id) ||
                          _alreadyInvited.value.contains(user.id)
                      ? Icon(
                        Icons.check_circle,
                        color:
                            _alreadyInvited.value.contains(user.id)
                                ? Colors.grey
                                : Colors.green,
                        size: 24,
                      )
                      : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  List<UserModel> _memberFetchController() {
    List<UserModel> users = [];
    _isLoaded.value = false;

    if (widget.transactionType == TransactionType.room) {
      switch (widget.inviteMember) {
        case true:
          {
            final roomUserState = context.watch<RoomUserCubit>().state;
            final notificationState = context.watch<NotificationBloc>().state;
            List<NotificationModel> notificationData = [];
            if (notificationState is NotificationFetchSuccess) {
              notificationData = notificationState.data;
            }
            Set<String> alreadyMember = {};
            Set<String> alreadyInvited = {};
            String roomID = "";

            if (roomUserState is RoomUserSuccess) {
              roomID = roomUserState.id;
              for (int i = 0; i < roomUserState.data.length; i++) {
                alreadyMember.add(roomUserState.data[i].user.id);
              }
            }
            for (int i = 0; i < notificationData.length; i++) {
              if (notificationData[i].roomID == roomID) {
                alreadyInvited.add(notificationData[i].user.id);
              }
            }
            _alreadyInvited.value = Set.from(alreadyInvited);

            final friendState = context.watch<FriendCubit>().state;
            if (friendState is FriendLoading) {
              users = [];
            } else {
              if (friendState is FriendSuccess) {
                for (int i = 0; i < friendState.data.length; i++) {
                  if (!alreadyMember.contains(friendState.data[i].id)) {
                    users.add(friendState.data[i]);
                  }
                }
              } else if (friendState is FriendFailure) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showNormalSnackBar(context, friendState.error);
                });
              }
              _isLoaded.value = true;
            }
          }
        case false:
          {
            final roomUserState = context.watch<RoomUserCubit>().state;
            if (roomUserState is RoomUserSuccess) {
              for (int i = 0; i < roomUserState.data.length; i++) {
                if (roomUserState.data[i].user.id != _loggedInUser.id &&
                    roomUserState.data[i].active) {
                  users.add(roomUserState.data[i].user);
                }
              }
              _isLoaded.value = true;
            }
          }
      }
    } else if (widget.transactionType == TransactionType.quicksplit) {
      final friendState = context.watch<FriendCubit>().state;
      if (friendState is FriendLoading) {
        users = [];
      } else {
        if (friendState is FriendSuccess) {
          users = friendState.data;
        } else if (friendState is FriendFailure) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showNormalSnackBar(context, friendState.error);
          });
        }
        _isLoaded.value = true;
      }
    } else if (widget.transactionType == TransactionType.lenden) {
      final notificationState = context.watch<NotificationBloc>().state;
      final lendenRoomState = context.watch<LendenRoomBloc>().state;

      List<NotificationModel> notificationData = [];
      if (notificationState is NotificationFetchSuccess) {
        notificationData = notificationState.data;
      }
      String roomID = "";
      if (lendenRoomState is LendenRoomFetchSuccess) {
        roomID = lendenRoomState.id;
      }
      Set<String> alreadyInvited = {};
      for (int i = 0; i < notificationData.length; i++) {
        if (notificationData[i].roomID == roomID) {
          alreadyInvited.add(notificationData[i].user.id);
        }
      }
      _alreadyInvited.value = Set.from(alreadyInvited);

      final friendState = context.watch<FriendCubit>().state;
      if (friendState is FriendLoading) {
        users = [];
      } else {
        if (friendState is FriendSuccess) {
          users = friendState.data;
        } else if (friendState is FriendFailure) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showNormalSnackBar(context, friendState.error);
          });
        }
        _isLoaded.value = true;
      }
    }

    return users;
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      if (TransactionType.quicksplit == widget.transactionType ||
          widget.inviteMember) {
        _fetchFriendData();
      }

      _selectedUserIDs.value.addAll(widget.userID);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<UserModel> users = _memberFetchController();
    return ValueListenableBuilder(
      valueListenable: _isLoaded,
      builder: (context, isLoaded, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Invite Member"),
            centerTitle: false,
            titleSpacing: _mainScreenPadding.left,
            leading: appBarBackButton(context),
            actions:
                isLoaded && users.isNotEmpty
                    ? [
                      IconButton(
                        onPressed: () {
                          isSearchEnabled.value = !isSearchEnabled.value;
                          _searchController.text = "";
                        },
                        icon: Icon(Icons.search),
                      ),
                      IconButton(
                        onPressed: () {
                          List<UserModel> toBePassed = [];
                          for (int i = 0; i < users.length; i++) {
                            if (_selectedUserIDs.value.contains(users[i].id)) {
                              toBePassed.add(users[i]);
                            }
                          }
                          context.pop(toBePassed);
                        },
                        icon: Icon(Icons.check),
                      ),
                    ]
                    : null,
          ),
          body:
              isLoaded && users.isEmpty
                  ? noRecordFoundWidget("No User Found", context)
                  : SingleChildScrollView(
                    padding: _mainScreenPadding.add(
                      EdgeInsets.only(bottom: UiConstant.spaceAtBottom),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraint) {
                        final double screenWidth = constraint.maxWidth;
                        final double spacing = 12.0;
                        final int columns =
                            (screenWidth / (_userCardWidth + spacing)).ceil();

                        if (!isLoaded) {
                          users = List.filled(columns * 4, UserModel.empty());
                        }
                        return ValueListenableBuilder(
                          valueListenable: isSearchEnabled,
                          builder: (context, _, _) {
                            return Column(
                              children: [
                                isSearchEnabled.value
                                    ? CustomFormField.searchBar(
                                      "Search",
                                      isSearchEnabled,
                                      _searchController,
                                    )
                                    : SizedBox.shrink(),
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _searchController,
                                  builder: (context, _, _) {
                                    List<UserModel> filterData =
                                        FilterSort.filteredSearchText(
                                          _searchController.text,
                                          users,
                                          (user) => user.name,
                                        );

                                    if (filterData.isEmpty) {
                                      return noRecordFoundWidget(
                                        "No Matching Records",
                                        context,
                                      );
                                    }

                                    return GridView.builder(
                                      padding: EdgeInsets.only(
                                        top:
                                            isSearchEnabled.value
                                                ? 0
                                                : UiConstant
                                                    .spaceBetweenSection,
                                      ),
                                      shrinkWrap: true,
                                      itemCount: filterData.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: columns,
                                            mainAxisSpacing: spacing,
                                            crossAxisSpacing: spacing,
                                          ),
                                      itemBuilder: (context, index) {
                                        UserModel user = filterData[index];
                                        return ValueListenableBuilder(
                                          valueListenable: _selectedUserIDs,
                                          builder: (
                                            BuildContext context,
                                            _,
                                            _,
                                          ) {
                                            return _userCardWidget(user);
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
        );
      },
    );
  }
}
