import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/bloc/add_to_personal_expense/add_to_personal_expense_bloc.dart';
import 'package:settlenow/bloc/lenden/dashboard/lenden_dashboard_bloc.dart';
import 'package:settlenow/bloc/lenden/room/lenden_room_bloc.dart';
import 'package:settlenow/bloc/notification/notification_bloc.dart';
import 'package:settlenow/bloc/notification_action/notification_action_bloc.dart';
import 'package:settlenow/bloc/personal_expense/dashboard/personal_expense_dashboard_bloc.dart';
import 'package:settlenow/bloc/personal_expense/monthly_expense/personal_expense_bloc.dart';
import 'package:settlenow/bloc/quicksplit/quicksplit_bloc.dart';
import 'package:settlenow/bloc/room/dashboard/room_dashboard_bloc.dart';
import 'package:settlenow/bloc/room/each_room/room_bloc.dart';
import 'package:settlenow/bloc/update_info/update_info_bloc.dart';
import 'package:settlenow/constant/ui_constant.dart';
import 'package:settlenow/cubit/lenden/create_room/create_room_cubit.dart';
import 'package:settlenow/cubit/new_transaction/new_transaction_cubit.dart';
import 'package:settlenow/cubit/room/create_join_room/create_join_room_cubit.dart';
import 'package:settlenow/cubit/room/room_close/room_close_cubit.dart';
import 'package:settlenow/cubit/room/room_close_request/room_close_request_cubit.dart';
import 'package:settlenow/cubit/room/room_info/room_info_cubit.dart';
import 'package:settlenow/cubit/room/room_settle/room_settle_cubit.dart';
import 'package:settlenow/cubit/room/room_settle_upsert/room_settle_upsert_cubit.dart';
import 'package:settlenow/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow/cubit/user/friend/friend_cubit.dart';
import 'package:settlenow/cubit/user/user_login_activity/user_login_activity_cubit.dart';
import 'package:settlenow/cubit/user/user_update_profile/user_update_profile_cubit.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/widgets/snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

double calculateCardHeight(
  BuildContext context,
  double baseHeight, {
  double weight = 0.5,
}) {
  final relativeChange =
      (MediaQuery.of(context).textScaler.scale(1) - .85) / .85;
  return baseHeight * (1 + relativeChange * weight);
}

List<double> calculateCrossAspectRatio(
  BuildContext context,
  double screenWidth,
  EdgeInsets mainScreenPadding, {
  double cardHeight = UiConstant.cardFixedHeight,
  double cardWidth = -1,
}) {
  final isWide = screenWidth >= UiConstant.maxWidth;
  final dynamicHeight = calculateCardHeight(context, cardHeight);

  if (cardWidth > 0) {
    bool isWide = screenWidth >= UiConstant.maxWidth;
    final boxWidth =
        isWide
            ? cardWidth
            : (screenWidth / 2) -
                UiConstant.spaceBetweenCard * .5 -
                mainScreenPadding.left;

    return [boxWidth, boxWidth / dynamicHeight];
  } else {
    final boxWidth =
        isWide
            ? (screenWidth / 2) -
                UiConstant.spaceBetweenCard -
                mainScreenPadding.left
            : screenWidth;

    return [boxWidth, boxWidth / dynamicHeight];
  }
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'open':
      return Colors.green;
    case 'closed':
      return Colors.red;
    case 'partially closed':
      return Colors.amber;
    default:
      return Colors.grey.shade200;
  }
}

bool isDateTimeSame(DateTime d1, DateTime d2) {
  DateTime dC1 = DateTime(d1.year, d1.month, d1.day, d1.hour, d1.minute);
  DateTime dC2 = DateTime(d2.year, d2.month, d2.day, d2.hour, d2.minute);
  return dC1 == dC2;
}

int roundUpToPowerOfTen(int number) {
  if (number == 0) {
    return 0;
  }
  int digits = log(number) ~/ ln10;
  int base = pow(10, digits).toInt();

  if (number % base == 0) return number;

  return ((number ~/ base) + 1) * base;
}

void resetAllBlocs(BuildContext context) {
  context.read<AddToPersonalExpenseBloc>().add(AddToPersonalExpenseReset());
  context.read<LendenDashboardBloc>().add(LendenDashboardReset());
  context.read<LendenRoomBloc>().add(LendenRoomReset());
  context.read<NotificationBloc>().add(NotificationReset());
  context.read<NotificationActionBloc>().add(NotificationActionReset());
  context.read<PersonalExpenseDashboardBloc>().add(
    PersonalExpenseDashboardReset(),
  );
  context.read<PersonalMonthlyExpenseBloc>().add(PersonalMonthlyExpenseReset());
  context.read<QuicksplitBloc>().add(QuicksplitReset());
  context.read<RoomDashboardBloc>().add(RoomDashboardReset());
  context.read<RoomBloc>().add(RoomBlocReset());
  context.read<CreateRoomCubit>().reset();
  context.read<NewTransactionCubit>().reset();
  context.read<FriendCubit>().reset();
  context.read<UserLoginActivityCubit>().reset();
  context.read<UserUpdateProfileCubit>().reset();
  context.read<CreateJoinRoomCubit>().reset();
  context.read<RoomCloseCubit>().reset();
  context.read<RoomCloseRequestCubit>().reset();
  context.read<RoomInfoCubit>().reset();
  context.read<RoomSettleCubit>().reset();
  context.read<RoomSettleUpsertCubit>().reset();
  context.read<RoomUserCubit>().reset();
}

void updateStateListener(BuildContext context, UpdateInfoState updateState) {
  if (updateState is UpdateInfoSuccess) {
    if (updateState.data.maintenance) {
      while (context.canPop()) {
        context.pop();
      }
      context.pushReplacement(RouterConstants.maintenancePage);
    } else if (updateState.data.isUpdateRequired()) {
      if (updateState.data.important) {
        while (context.canPop()) {
          context.pop();
        }
        context.pushReplacement(
          RouterConstants.updatePage,
          extra: updateState.data,
        );
      } else {
        showSnackbarForUpdate(ScaffoldMessenger.of(context));
      }
    }
  }
}

void updateHandler() {
  launchUrl(
    Uri.parse(
      "https://play.google.com/store/apps/details?id=com.rohit.settlenow",
    ),
    mode: LaunchMode.externalApplication,
  );
}

double getPrecisedAmount(double amount) {
  return (amount * 100).round() / 100;
}
