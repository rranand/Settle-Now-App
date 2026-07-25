import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/firebase/firebase_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/util_core.dart';

class AuthGate extends StatelessWidget {
  final Widget child;
  const AuthGate({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseRemote>(
      builder: (context, firebaseRemote, _) {
        context.read<UpdateInfoBloc>().add(
          UpdateInfoFetchRequested(firebaseRemote),
        );
        return BlocConsumer<UpdateInfoBloc, UpdateInfoState>(
          listener: updateStateListener,
          builder: (context, state) {
            return BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthInitial) {
                  while (context.canPop()) {
                    context.pop();
                  }
                  return context.pushReplacement(
                    RouterConstants.loginRouteName,
                  );
                }
              },
              builder: (context, state) {
                if (state is AuthLoginSuccess) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<PreferenceProvider>().updatePref(
                      state.preferenceData,
                    );
                  });
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
      },
    );
  }
}
