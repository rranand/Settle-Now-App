import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/auth/auth_bloc.dart';
import 'package:settlenow/constant/ui_constant.dart';
import 'package:settlenow/cubit/room/room_settle/room_settle_cubit.dart';
import 'package:settlenow/model/room_settle_model.dart';
import 'package:settlenow/model/user_model.dart';
import 'package:settlenow/util/card/settle_card.dart';
import 'package:settlenow/util/functions/additional_function.dart';
import 'package:settlenow/util/widgets/widgets.dart';

class RoomSettleScreen extends StatefulWidget {
  final String roomID;
  const RoomSettleScreen({super.key, required this.roomID});

  @override
  State<RoomSettleScreen> createState() => _RoomSettleScreenState();
}

class _RoomSettleScreenState extends State<RoomSettleScreen> {
  UserModel _loggedInUser = UserModel.empty();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraint) {
        final cardSizeInfo = calculateCrossAspectRatio(
          constraint.crossAxisExtent,
          EdgeInsets.zero,
        );

        return BlocBuilder<RoomSettleCubit, RoomSettleState>(
          builder: (context, state) {
            List<RoomSettleModel> data = [];
            if (state is RoomSettleSuccess) {
              data = state.data;
            } else {
              data = List.filled(11, RoomSettleModel.empty());
            }

            if (data.isEmpty) {
              return SliverToBoxAdapter(
                child: noRecordFoundWidget("No Record Found", context),
              );
            }

            return SliverGrid.builder(
              itemCount: data.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: cardSizeInfo[0],
                mainAxisSpacing: UiConstant.spaceBetweenCard,
                crossAxisSpacing: UiConstant.spaceBetweenCard,
                childAspectRatio: cardSizeInfo[1],
              ),
              itemBuilder: (BuildContext context, int index) {
                return SettleCard(
                  roomID: widget.roomID,
                  screenWidth: cardSizeInfo[0],
                  data: data[index],
                  loggedInUser: _loggedInUser,
                );
              },
            );
          },
        );
      },
    );
  }
}
