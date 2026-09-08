import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/provider/provider_core.dart';
import 'package:settlenow/util/util_core.dart';

class BankTransactionScreen extends StatefulWidget {
  const BankTransactionScreen({super.key});

  @override
  State<BankTransactionScreen> createState() => _BankTransactionScreenState();
}

class _BankTransactionScreenState extends State<BankTransactionScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  UserModel _loggedInUser = UserModel.empty();

  List<BankTransactionModel> allTransactions = [];
  List<String> bankNameFound = [];
  List<String> transactionMode = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getAllSms() async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final SmsQuery query = SmsQuery();

      final messages = await query.querySms(
        count: 10000000,
        kinds: [SmsQueryKind.inbox],
      );

      List<dynamic> temp = await filterSMS(messages);

      allTransactions = temp[0];
      bankNameFound = temp[1];
      transactionMode = temp[2];
    } else {
      await Permission.sms.request();
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _loggedInUser = authState.userData;
      getAllSms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bank Transactions")),
      body: ListView.builder(
        itemCount: allTransactions.length,
        itemBuilder: (context, index) {
          final transaction = allTransactions[index];

          return Column(
            children: [
              ListTile(
                title: Text(transaction.receiver),
                subtitle: Text(transaction.toString()),
              ),
              SizedBox(height: 10),
              Padding(
                padding: _mainScreenPadding,
                child: Text(transaction.rawMessage),
              ),
            ],
          );
        },
      ),
    );
  }
}
