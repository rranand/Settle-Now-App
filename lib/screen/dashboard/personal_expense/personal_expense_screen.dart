import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class PersonalExpenseScreen extends StatefulWidget {
  final String id;
  const PersonalExpenseScreen({super.key, required this.id});

  @override
  State<PersonalExpenseScreen> createState() => _PersonalExpenseScreenState();
}

class _PersonalExpenseScreenState extends State<PersonalExpenseScreen> {
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
      appBar: AppBar(
        title: Text(widget.id),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
      ),
    );
  }
}
