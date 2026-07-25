import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/util/util_core.dart';

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
  final List<String> prefernceOption = [
    "Room",
    "Quicksplit",
    "Lenden",
    "Personal Expense",
  ];

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
      _preferenceData = context.read<PreferenceProvider>().pref;

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
      case 3:
        {
          return preferenceNotifier.value.personalExpense.showEmpty;
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
      case 3:
        preferenceNotifier.value = pref.copyWith(
          personalExpense: pref.personalExpense.copyWith(showEmpty: value),
        );
        break;
    }
  }

  Widget _buildSection(int index) {
    String txt = "Show Settled";
    if (index == 3) {
      txt = "Show Empty Months";
    }
    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
          boxShadow: getContainerBoxShadow(context),
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(
                prefernceOption[index],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SwitchListTile(
              title: Text(txt),
              value: getSettledValue(index),
              onChanged: (value) {
                setSettledValue(index, value);
              },
            ),
          ],
        ),
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
                Card(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(
                        UiConstant.cardBorderRadius,
                      ),
                      boxShadow: getContainerBoxShadow(context),
                    ),
                    child: ListTile(
                      title: const Text("Theme"),
                      trailing: DropdownButton<String>(
                        underline: SizedBox.shrink(),
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
                        context,
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
