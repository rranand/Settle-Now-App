import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';

class NotificationBellNavBarIcon extends StatelessWidget {
  final IconData iconData;
  const NotificationBellNavBarIcon({super.key, required this.iconData});

  @override
  Widget build(BuildContext context) {
    final hasUnreadList = context.select<NotificationBloc, bool>((bloc) {
      final state = bloc.state;
      return state is NotificationFetchSuccess && state.data.isNotEmpty;
    });

    final hasUnreadCount = context.select<UnreadNotificationCountCubit, bool>((
      cubit,
    ) {
      final state = cubit.state;
      return state is UnreadNotificationCountSuccess && state.count > 0;
    });

    final hasNotifications = hasUnreadList || hasUnreadCount;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(iconData),
        if (hasNotifications) const Positioned(top: 0, right: 0, child: _Dot()),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}
