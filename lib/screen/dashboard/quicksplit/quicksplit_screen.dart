import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/transaction_card.dart';

class QuicksplitScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const QuicksplitScreen({super.key, required this.isSearchEnabled});

  @override
  State<QuicksplitScreen> createState() => _QuicksplitScreenState();
}

class _QuicksplitScreenState extends State<QuicksplitScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainScreenPadding = context.watch<ScreenSizeProvider>().getPadding;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: _mainScreenPadding.add(
          EdgeInsets.symmetric(vertical: UiConstant.spaceBetweenSection),
        ),
        child: ListView.separated(
          itemBuilder: (context, index) {
            return TransactionCard();
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: 20,
        ),
      ),
    );
  }
}
