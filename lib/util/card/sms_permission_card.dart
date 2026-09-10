import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/router/router_constant.dart';
import 'package:settlenow/util/util_core.dart';

class SMSPermissionCard extends StatefulWidget {
  const SMSPermissionCard({super.key});

  @override
  State<SMSPermissionCard> createState() => _SMSPermissionCardState();
}

class _SMSPermissionCardState extends State<SMSPermissionCard> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;

    if (mounted) {
      setState(() {});
    }
  }

  void moveBackToPreviousScreen() {
    context.pushReplacement(RouterConstants.bankTransactionPage);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bank Transactions"),
        titleSpacing: _mainScreenPadding.left,
        centerTitle: false,
        leading: appBarBackButton(context),
      ),
      body: SafeArea(
        child: Padding(
          padding: _mainScreenPadding.add(const EdgeInsets.all(15.0)),
          child: Column(
            children: [
              const Spacer(flex: 2),

              Image.asset(
                'assets/Images/sms_permission.png',
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 32),

              Text(
                'Automatically track expenses',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Allow SMS access to find bank transactions and import them into Settle Now. Your SMS messages are processed on your device and are never stored on our servers.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () async {
                    await Permission.sms.request();
                    moveBackToPreviousScreen();
                  },
                  child: const Text(
                    'Allow SMS Access',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 46,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      side: BorderSide(
                        color: theme.primaryColor.withAlpha(100),
                        width: 1.0,
                      ),
                    ),
                    onPressed: () async {
                      context.pop();
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
