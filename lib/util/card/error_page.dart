import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settlenow/constant/ui_constant.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/widgets/custom_button.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({super.key});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 100,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 20),
              Text(
                "404 - Lost in Space",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: UiConstant.cardTitleTextSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Looks like you took a wrong turn... 🚧\n"
                "Even Google Maps can’t find this page.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: UiConstant.cardTitleTextSize),
              ),
              const SizedBox(height: 30),
              CustomButton.customElevatedButton(
                "Take Me Home",
                onPressed: () {
                  while (context.canPop()) {
                    context.pop();
                  }
                  context.pushReplacement(RouterConstants.dashboardRouteName);
                },
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
