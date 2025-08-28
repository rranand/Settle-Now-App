import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/cubit/user/user_login_activity/user_login_activity_cubit.dart';
import 'package:settlenow_v2/model/login_activity_model.dart';
import 'package:settlenow_v2/util/enum/device_type.dart';
import 'package:settlenow_v2/util/enum/enums.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/button_with_shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class LoginActivityCard extends StatelessWidget {
  final LoginActivityModel data;
  const LoginActivityCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading:
              data.hasData
                  ? colouredIcon(
                    DeviceTypeExtension.fromString(data.deviceType).icon,
                    DeviceTypeExtension.fromString(data.deviceType).color,
                  )
                  : CustomShimmerEffect.imageWidget(
                    shape: BoxShape.circle,
                    radius: 50,
                  ),
          title:
              data.hasData
                  ? Text(data.deviceName)
                  : CustomShimmerEffect.textWidget(width: 80),
          subtitle:
              data.hasData
                  ? Text.rich(
                    TextSpan(
                      text: data.deviceType,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      children: [
                        TextSpan(text: "\nActive "),
                        TextSpan(text: convertToMoment(data.lastLoggedIn)),
                      ],
                    ),
                  )
                  : CustomShimmerEffect.textWidget(fontSize: 10, width: 80),
          trailing:
              data.hasData
                  ? (data.id.isEmpty
                      ? ButtonWithShimmerEffect(
                        buttonText: "Current",
                        buttonType: CustomButtonType.customElevatedButton,
                        isLoaded: false,
                        buttonHeight: 40,
                        buttonWidth: 100,
                        backgroundColor: Colors.green.shade400,
                        onPressed: () {
                          showNormalSnackBar(
                            context,
                            "Can't Logout Current Device",
                          );
                        },
                      )
                      : ButtonWithShimmerEffect(
                        buttonText: "Log Out",
                        buttonType: CustomButtonType.customElevatedButton,
                        isLoaded: false,
                        buttonHeight: 40,
                        buttonWidth: 100,
                        backgroundColor: Colors.red.shade400,
                        onPressed: () {
                          context.read<UserLoginActivityCubit>().logoutDevice(
                            context,
                            data.id,
                          );
                        },
                      ))
                  : CustomShimmerEffect.placeHolderShimmerEffect(
                    CustomButton.customElevatedButton(
                      "",
                      buttonHeight: 40,
                      buttonWidth: 100,
                    ),
                  ),
        ),
      ),
    );
  }
}
