import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/dashboard/lenden_dashboard_bloc.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/lenden/create_room/create_room_cubit.dart';
import 'package:settlenow_v2/model/lenden_dashboard_model.dart';
import 'package:settlenow_v2/model/preference_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/lenden_card.dart';
import 'package:settlenow_v2/util/enum/enums.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';
import 'package:settlenow_v2/util/functions/validator.dart';
import 'package:settlenow_v2/util/handler/filter_sort.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/gradient_widget.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class LendenDashboardScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const LendenDashboardScreen({super.key, required this.isSearchEnabled});

  @override
  State<LendenDashboardScreen> createState() => _LendenDashboardScreenState();
}

class _LendenDashboardScreenState extends State<LendenDashboardScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _createRoomKey = GlobalKey<FormState>();
  final TextEditingController _createRoomController = TextEditingController();
  UserModel _loggedInUser = UserModel.empty();
  PreferenceModel _preferenceData = PreferenceModel.empty();

  void _blocListenerHandler(BuildContext context, LendenDashboardState state) {
    if (state is LendenDashboardFailure) {
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
      _preferenceData = authState.preferenceData;

      final state = context.read<LendenDashboardBloc>().state;

      if (state is! LendenDashboardFetchSuccess) {
        context.read<LendenDashboardBloc>().add(
          LendenDashboardFetch(authToken: _loggedInUser.authToken),
        );
      }
    }
    widget.isSearchEnabled.addListener(() {
      _searchController.text = "";
    });
  }

  void _createRoomHandler() {
    if (_createRoomKey.currentState!.validate()) {
      context.read<CreateRoomCubit>().createNewRoom(
        context,
        _createRoomController.text,
      );

      if (context.canPop()) {
        _createRoomController.text = "";
        context.pop();
      }
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(height: 4, width: 60, color: Colors.grey[300]),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Create Room",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Form(
                  key: _createRoomKey,
                  child: CustomFormField.textFormField(
                    _createRoomController,
                    hintText: "",
                    labelText: "Room Name",
                    validator: CustomValidator.validateRoomName,
                    inputDecoration:
                        TextFormFieldInputBorder.outlineInputBorder,
                    borderColor: Colors.black12,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: InkWell(
                  onTap: _createRoomHandler,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: GradientWidget(
                      text: "Create",
                      gradientColors: GradientColorConstant.coolIndigoToBlue,
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
  }

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(context, "Please re-login...Session expired!");
      return;
    }
    context.read<LendenDashboardBloc>().add(
      LendenDashboardFetch(authToken: _loggedInUser.authToken),
    );
  }

  List<LendenDashboardModel> filterDataByPreference(
    List<LendenDashboardModel> oldData,
  ) {
    PreferenceSection pref = _preferenceData.lenden;

    if (pref.isSettled) {
      return oldData;
    }

    List<LendenDashboardModel> data = [];

    for (int i = 0; i < oldData.length; i++) {
      bool isSettledByYou =
          oldData[i].users
              .firstWhere((ele) => ele.id == _loggedInUser.id)
              .isClosed;
      if (pref.isSettled != isSettledByYou) {
        continue;
      }
      data.add(oldData[i]);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final cardSizeInfo = calculateCrossAspectRatio(
      MediaQuery.of(context).size.width,
      _mainScreenPadding,
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        notificationPredicate: (ScrollNotification notification) {
          final state = context.read<LendenDashboardBloc>().state;
          if (state is LendenDashboardFetchSuccess && state.data.isNotEmpty) {
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
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    title: CustomFormField.searchBar(
                      "Search",
                      widget.isSearchEnabled,
                      _searchController,
                    ),
                  ),
                );
              },
            ),
            BlocConsumer<CreateRoomCubit, CreateRoomState>(
              listener: (context, state) {
                if (state is CreateRoomFailure) {
                  showNormalSnackBar(context, state.error);
                }
              },
              builder: (context, state) {
                return BlocConsumer<LendenDashboardBloc, LendenDashboardState>(
                  listener: _blocListenerHandler,
                  builder: (context, state) {
                    List<LendenDashboardModel> lendenData = [];
                    if (state is LendenDashboardFetchSuccess) {
                      lendenData = filterDataByPreference(state.data);
                    } else if (state is LendenDashboardLoading) {
                      lendenData = List.generate(
                        11,
                        (i) => LendenDashboardModel.empty(),
                      );
                    }
                    if (lendenData.isEmpty) {
                      return SliverToBoxAdapter(
                        child: noRecordFoundWidget("No Room Found", context),
                      );
                    } else {
                      return SliverPadding(
                        padding: _mainScreenPadding.add(
                          EdgeInsets.only(
                            top: UiConstant.spaceBetweenSection,
                            bottom: UiConstant.spaceAtBottom,
                          ),
                        ),
                        sliver: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _searchController,
                          builder: (context, _, _) {
                            List<LendenDashboardModel> filterData = lendenData;
                            if (state is LendenDashboardFetchSuccess) {
                              filterData = FilterSort.filteredSearchText(
                                _searchController.text,
                                lendenData,
                                (roomData) {
                                  String searchStr = roomData.roomName;
                                  for (
                                    int i = 0;
                                    i < roomData.users.length;
                                    i++
                                  ) {
                                    if (roomData.users[i].id !=
                                        _loggedInUser.id) {
                                      searchStr += " ${roomData.users[i].name}";
                                    }
                                  }
                                  return searchStr;
                                },
                              );
                            }

                            if (filterData.isEmpty) {
                              return SliverToBoxAdapter(
                                child: noRecordFoundWidget(
                                  "No Matching Records",
                                  context,
                                ),
                              );
                            }
                            return SliverGrid.builder(
                              itemCount: filterData.length,
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: cardSizeInfo[0],
                                    mainAxisSpacing:
                                        UiConstant.spaceBetweenCard,
                                    crossAxisSpacing:
                                        UiConstant.spaceBetweenCard,
                                    childAspectRatio: cardSizeInfo[1],
                                  ),
                              itemBuilder:
                                  (context, index) => SizedBox(
                                    width: cardSizeInfo[0],
                                    child: LendenCard(data: filterData[index]),
                                  ),
                            );
                          },
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: CustomButton.customFloatingButton(
        Iconsax.add_copy,
        () => _showBottomSheet(context),
      ),
    );
  }
}
