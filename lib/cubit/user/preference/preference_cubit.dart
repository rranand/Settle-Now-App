import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'preference_state.dart';

class PreferenceCubit extends Cubit<PreferenceState> {
  final AuthRepository _repo;
  final AuthBloc _authBloc;
  PreferenceCubit(this._repo, this._authBloc) : super(PreferenceInitial());

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
      await _repo.savePreference(data);
      _authBloc.add(AuthProfileUpdateRequested(loggedInUser, data));
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
