import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/graph/linear_graph_card.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class PersonalExpenseScreen extends StatefulWidget {
  final String id;
  const PersonalExpenseScreen({super.key, required this.id});

  @override
  State<PersonalExpenseScreen> createState() => _PersonalExpenseScreenState();
}

class _PersonalExpenseScreenState extends State<PersonalExpenseScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  final List<double> amountData = [
    120.0,
    95.5,
    110.0,
    130.2,
    105.0,
    99.9,
    142.3,
    125.0,
    98.0,
    114.0,
    150.0,
    97.3,
    121.0,
    135.6,
    100.0,
    92.4,
    160.0,
    145.2,
    118.0,
    106.6,
    102.0,
    134.3,
    141.0,
    123.9,
    108.0,
    117.0,
    139.0,
    127.4,
    112.0,
    149.0,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id),
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            toolbarHeight: 400,
            automaticallyImplyLeading: false,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: LinearGraphCard(expenses: amountData, monthName: "April"),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(height: 100, color: Colors.yellow, width: 100),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
