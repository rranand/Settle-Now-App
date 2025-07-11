import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow_v2/cubit/user/friend/friend_cubit.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/enum/transaction_type.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class InviteMember extends StatefulWidget {
  final List<String> userID;
  final TransactionType transactionType;
  const InviteMember({
    super.key,
    required this.userID,
    required this.transactionType,
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
    final oldUserIDs = Set<String>.from(_selectedUserIDs.value);

    if (oldUserIDs.contains(user.id)) {
      oldUserIDs.remove(user.id);
    } else {
      oldUserIDs.add(user.id);
    }

    _selectedUserIDs.value = oldUserIDs;
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
                  _selectedUserIDs.value.contains(user.id)
                      ? Icon(Icons.check_circle, color: Colors.green, size: 24)
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
      final roomUserState = context.read<RoomUserCubit>().state;
      if (roomUserState is RoomUserSuccess) {
        for (int i = 0; i < roomUserState.data.length; i++) {
          if (roomUserState.data[i].user.id != _loggedInUser.id &&
              roomUserState.data[i].active) {
            users.add(roomUserState.data[i].user);
          }
        }
        _isLoaded.value = true;
      }
    } else if (widget.transactionType == TransactionType.quicksplit) {
      final friendState = context.watch<FriendCubit>().state;
      if (friendState is FriendSuccess) {
        users = friendState.data;
        _isLoaded.value = true;
      } else if (friendState is FriendFailure) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showNormalSnackBar(context, friendState.error);
        });
        _isLoaded.value = true;
      } else {
        users = [];
      }
    }

    return users;
  }

  List<UserModel> _filteredSearchText(
    String searchText,
    List<UserModel> users,
  ) {
    if (searchText.isEmpty) {
      return users;
    }
    searchText = searchText.trim().toLowerCase();
    return users
        .where((ele) => ele.name.toLowerCase().contains(searchText))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;

      if (TransactionType.quicksplit == widget.transactionType) {
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
                  ? noRecordFoundWidget("No User Found")
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
                                      (value) {},
                                    )
                                    : SizedBox.shrink(),
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _searchController,
                                  builder: (context, _, _) {
                                    List<UserModel> filteredUsers =
                                        _filteredSearchText(
                                          _searchController.text,
                                          users,
                                        );

                                    return GridView.builder(
                                      padding: EdgeInsets.only(
                                        top:
                                            isSearchEnabled.value
                                                ? 0
                                                : UiConstant
                                                    .spaceBetweenSection,
                                      ),
                                      shrinkWrap: true,
                                      itemCount: filteredUsers.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: columns,
                                            mainAxisSpacing: spacing,
                                            crossAxisSpacing: spacing,
                                          ),
                                      itemBuilder: (context, index) {
                                        UserModel user = filteredUsers[index];
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
