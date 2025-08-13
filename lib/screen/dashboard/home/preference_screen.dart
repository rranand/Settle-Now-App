import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/cubit/user/preference/preference_cubit.dart';
import 'package:settlenow_v2/model/preference_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  UserModel _loggedInUser = UserModel.empty();
  PreferenceModel _preferenceData = PreferenceModel.empty();
  ValueNotifier<PreferenceModel> preferenceNotifier = ValueNotifier(
    PreferenceModel.empty(),
  );

  final List<String> themeOptions = ["system", "light", "dark"];
  final List<String> prefernceOption = ["Room", "Quicksplit", "Lenden"];

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
      _preferenceData = authState.preferenceData;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        preferenceNotifier.value = _preferenceData;
      });
    }
  }

  bool getSettledValue(int index) {
    switch (index) {
      case 0:
        {
          return preferenceNotifier.value.room.isSettled;
        }
      case 1:
        {
          return preferenceNotifier.value.quicksplit.isSettled;
        }
      case 2:
        {
          return preferenceNotifier.value.lenden.isSettled;
        }
      default:
        {
          return false;
        }
    }
  }

  void setSettledValue(int index, bool value) {
    final pref = preferenceNotifier.value;

    switch (index) {
      case 0:
        preferenceNotifier.value = pref.copyWith(
          room: pref.room.copyWith(isSettled: value),
        );
        break;
      case 1:
        preferenceNotifier.value = pref.copyWith(
          quicksplit: pref.quicksplit.copyWith(isSettled: value),
        );
        break;
      case 2:
        preferenceNotifier.value = pref.copyWith(
          lenden: pref.lenden.copyWith(isSettled: value),
        );
        break;
    }
  }

  Widget _buildSection(int index) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        children: [
          ListTile(
            title: Text(
              prefernceOption[index],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text("Show Settled"),
            value: getSettledValue(index),
            onChanged: (value) {
              setSettledValue(index, value);
            },
          ),
        ],
      ),
    );
  }

  IconData _themeIconHandler(String theme) {
    switch (theme) {
      case "system":
        {
          return Iconsax.autobrightness_copy;
        }
      case "light":
        {
          return Iconsax.sun_1_copy;
        }
      case "dark":
        {
          return Iconsax.moon_copy;
        }
      default:
        {
          return Iconsax.sun_1_copy;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preference"),
        titleSpacing: _mainScreenPadding.left,
        centerTitle: false,
        leading: appBarBackButton(context),
      ),
      body: SingleChildScrollView(
        padding: _mainScreenPadding,
        child: ValueListenableBuilder(
          valueListenable: preferenceNotifier,
          builder: (context, _, _) {
            return ListView(
              shrinkWrap: true,
              children: [
                ...List.generate(
                  prefernceOption.length,
                  (index) => _buildSection(index),
                ),
                Visibility(
                  visible: false,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: ListTile(
                      title: const Text("Theme"),
                      trailing: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: preferenceNotifier.value.theme,
                        items:
                            themeOptions.map((theme) {
                              return DropdownMenuItem(
                                value: theme,
                                child: Row(
                                  children: [
                                    Icon(_themeIconHandler(theme)),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(capatilizeFirstLetter(theme)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            preferenceNotifier.value = preferenceNotifier.value
                                .copyWith(theme: value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(
                    16.0,
                  ).add(EdgeInsets.only(bottom: UiConstant.spaceAtBottom)),
                  child: CustomButton.customElevatedButton(
                    "Save",
                    buttonHeight: 40,
                    onPressed: () {
                      context.read<PreferenceCubit>().savePreferenceData(
                        preferenceNotifier.value,
                        _loggedInUser,
                        ScaffoldMessenger.of(context),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
