import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/auth/auth_bloc.dart';
import 'package:settlenow/data/repository/auth_repository.dart';
import 'package:settlenow/model/preference_model.dart';
import 'package:settlenow/model/user_model.dart';
import 'package:settlenow/provider/preference_provider.dart';
import 'package:settlenow/util/widgets/shimmer_effect.dart';
import 'package:settlenow/util/widgets/snackbar.dart';
import 'package:settlenow/util/widgets/widgets.dart';

part 'preference_state.dart';

class PreferenceCubit extends Cubit<PreferenceState> {
  final AuthRepository repo;
  final AuthBloc authBloc;
  PreferenceCubit(this.repo, this.authBloc) : super(PreferenceInitial());

  void savePreferenceData(
    PreferenceModel data,
    UserModel loggedInUser,
    BuildContext context,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final prefProvider = context.read<PreferenceProvider>();

    showSnackbarWithChildWidget(
      "Saving Preference",
      child: CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
      duration: Duration(minutes: 2),
      scaffoldMessenger: scaffoldMessenger,
    );

    try {
      await repo.savePreference(data);
      authBloc.add(AuthProfileUpdateRequested(loggedInUser, data));
      scaffoldMessenger.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        "Preference Saved",
        child: snackbarSuccessIcon(),
        scaffoldMessenger: scaffoldMessenger,
      );
      prefProvider.updatePref(data);
      return emit(PreferenceSuccess());
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      return emit(PreferenceFailure(e.toString()));
    }
  }
}
