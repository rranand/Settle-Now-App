import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/lenden/room/lenden_room_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/lenden/lenden_room_name/lenden_room_name_cubit.dart';
import 'package:settlenow_v2/model/lenden_room_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/lenden_expense_card.dart';
import 'package:settlenow_v2/util/card/lenden_summary_card.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
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
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  UserModel loggedInUser = UserModel.fromMap({
    'id': 'user_1',
    'name': 'Rohit Anand',
  });

  void _blocListenerHandler(BuildContext context, LendenRoomState state) {
    if (state is LendenRoomFailure) {
      showNormalSnackBar(context, state.error);
    }
  }

  List<LendenRoomModel> generateShimmerData() {
    return List.generate(11, (i) {
      LendenRoomModel tempData = LendenRoomModel.empty();
      if (i % 2 == 0) {
        tempData.createdBy.id = loggedInUser.id;
      }
      return tempData;
    });
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
    final state = context.read<LendenRoomBloc>().state;

    if (!(state is LendenRoomFetchSuccess && state.roomID == widget.id)) {
      context.read<LendenRoomBloc>().add(LendenRoomFetch(id: widget.id));
    }
    context.read<LendenRoomNameCubit>().fetchName(widget.id, widget.roomName);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= UiConstant.maxWidth;
    EdgeInsets paddingInsets = _mainScreenPadding;
    if (!isWide) {
      paddingInsets = EdgeInsets.symmetric(horizontal: 8);
    }
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<LendenRoomNameCubit, LendenRoomNameState>(
          builder: (context, state) {
            if (state is LendenRoomNameSuccess) {
              return Text(state.roomName);
            } else if (state is LendenRoomNameFailure) {
              showNormalSnackBar(context, state.error);
              return Text(widget.id);
            } else {
              return CustomShimmerEffect.textWidget(width: 180, fontSize: 20);
            }
          },
        ),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
      ),
      body: BlocConsumer<LendenRoomBloc, LendenRoomState>(
        listener: _blocListenerHandler,
        builder: (context, state) {
          List<LendenRoomModel> lendenRoomData = [];
          if (state is LendenRoomFetchSuccess) {
            lendenRoomData = state.data;
          } else {
            lendenRoomData = generateShimmerData();
          }
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: paddingInsets.add(
                  EdgeInsets.only(bottom: UiConstant.spaceBetweenSection),
                ),
                sliver: SliverToBoxAdapter(
                  child:
                      state is LendenRoomLoading
                          ? CustomShimmerEffect.placeHolderShimmerEffect(
                            Container(
                              height: 95,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                            ),
                          )
                          : LendenSummaryCard(
                            data: lendenRoomData,
                            loggedInUser: loggedInUser,
                          ),
                ),
              ),
              SliverPadding(
                padding: _mainScreenPadding,
                sliver: SliverList.builder(
                  itemCount: lendenRoomData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom:
                            index == lendenRoomData.length - 1
                                ? UiConstant.spaceAtBottom
                                : 0,
                      ),
                      child: LendenExpenseCard(
                        data: lendenRoomData[index],
                        loggedInUser: loggedInUser,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: CustomButton.customFloatingButton(
        Iconsax.add,
        () {},
      ),
    );
  }
}
