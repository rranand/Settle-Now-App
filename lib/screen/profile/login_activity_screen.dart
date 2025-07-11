import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/user/user_login_activity/user_login_activity_cubit.dart';
import 'package:settlenow_v2/model/login_activity_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/login_activity_card.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

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
        context.read<UserLoginActivityCubit>().fetchLoginData(_loggedInUser);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Activity"),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
      ),
      body: BlocConsumer<UserLoginActivityCubit, UserLoginActivityState>(
        listener: _blocListenerHandler,
        builder: (context, state) {
          List<LoginActivityModel> data = List.filled(
            10,
            LoginActivityModel.empty(),
          );

          if (!state.isLoading) {
            data = state.data;
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
    );
  }
}
