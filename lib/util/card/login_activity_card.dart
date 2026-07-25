import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class LoginActivityCard extends StatelessWidget {
  final LoginActivityModel data;
  const LoginActivityCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
          boxShadow: getContainerBoxShadow(context),
        ),
        child: ListTile(
          leading:
              data.hasData
                  ? colouredIcon(
                    DeviceTypeExtension.fromString(data.deviceType).icon,
                    DeviceTypeExtension.fromString(data.deviceType).color,
                  )
                  : CustomShimmerEffect.imageWidget(
                    context,
                    shape: BoxShape.circle,
                    radius: 50,
                  ),
          title:
              data.hasData
                  ? Text(data.deviceName)
                  : CustomShimmerEffect.textWidget(context, width: 80),
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
                  : CustomShimmerEffect.textWidget(
                    context,
                    fontSize: 10,
                    width: 80,
                  ),
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
                    context,
                  ),
        ),
      ),
    );
  }
}
