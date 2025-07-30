import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/update_info/update_info_bloc.dart';
import 'package:settlenow_v2/router/router_constant.dart';
import 'package:settlenow_v2/util/card/loading_card.dart';
import 'package:settlenow_v2/util/functions/additional_function.dart';

class AuthGate extends StatelessWidget {
  final Widget child;
  const AuthGate({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateInfoBloc, UpdateInfoState>(
      listener: updateStateListener,
      builder: (context, state) {
        return BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthInitial) {
              while (context.canPop()) {
                context.pop();
              }
              return context.pushReplacement(RouterConstants.loginRouteName);
            }
          },
          builder: (context, state) {
            if (state is AuthLoginSuccess) {
              return child;
            }
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
              ),
              body: LoadingPage(),
            );
          },
        );
      },
    );
  }
}
