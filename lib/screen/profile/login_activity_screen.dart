import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/util/util_core.dart';

class LoginActivityScreen extends StatefulWidget {
  const LoginActivityScreen({super.key});

  @override
  State<LoginActivityScreen> createState() => _LoginActivityScreenState();
}

class _LoginActivityScreenState extends State<LoginActivityScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  UserModel _loggedInUser = UserModel.empty();

  void _blocListenerHandler(
    BuildContext context,
    UserLoginActivityState state,
  ) {
    if (state.error != null) {
      showNormalSnackBar(context, state.error!);
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

      final state = context.read<UserLoginActivityCubit>().state;

      if (state.data.isEmpty) {
        context.read<UserLoginActivityCubit>().fetchLoginData();
      }
    }
  }

  Future<void> onRefresh() async {
    if (!_loggedInUser.hasData) {
      showNormalSnackBar(
        context,
        SnackbarMessageConstant.sessionExpiredMessage,
      );
      return;
    }
    context.read<UserLoginActivityCubit>().fetchLoginData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Activity"),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: BlocConsumer<UserLoginActivityCubit, UserLoginActivityState>(
          listener: _blocListenerHandler,
          builder: (context, state) {
            List<LoginActivityModel> data = List.filled(
              10,
              LoginActivityModel.empty(),
            );

            if (!state.isLoading) {
              data = state.data;
            }

            if (data.isEmpty) {
              return noRecordFoundWidget(
                "Something Went Wrong, Refresh!",
                context,
              );
            }

            return ListView.separated(
              padding: _mainScreenPadding.add(
                EdgeInsets.only(
                  top: UiConstant.spaceBetweenSection,
                  bottom: UiConstant.spaceAtBottom,
                ),
              ),
              itemBuilder:
                  (context, index) => LoginActivityCard(data: data[index]),
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: .5 * UiConstant.spaceBetweenSection);
              },
              itemCount: data.length,
            );
          },
        ),
      ),
    );
  }
}
