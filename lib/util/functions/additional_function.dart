import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/util_core.dart';
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

Color getStatusColor(RoomStatus status) {
  switch (status) {
    case RoomStatus.open:
      return Colors.green;
    case RoomStatus.closed:
      return Colors.red;
    case RoomStatus.partiallyClosed:
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

void logDebug(String text) {
  if (kDebugMode) {
    developer.log(text);
  }
}

void addPaginationListener<B extends StateStreamable<S>, S>({
  required ScrollController scrollController,
  required BuildContext context,
  required bool Function(S state) hasMore,
  required bool Function(S state) isLoadingMore,
  required void Function() onFetch,
  double threshold = 0.85,
}) {
  scrollController.addListener(() {
    final position = scrollController.position;
    final thresholdPixels = position.maxScrollExtent * threshold;

    if (position.pixels >= thresholdPixels) {
      final state = context.read<B>().state;
      if (!isLoadingMore(state) && hasMore(state)) {
        onFetch();
      }
    }
  });
}
