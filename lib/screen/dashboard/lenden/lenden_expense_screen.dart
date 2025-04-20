import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/lenden_expense_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/lenden_expense_card.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class LendenExpenseScreen extends StatefulWidget {
  final String id;
  const LendenExpenseScreen({super.key, required this.id});

  @override
  State<LendenExpenseScreen> createState() => _LendenExpenseScreenState();
}

class _LendenExpenseScreenState extends State<LendenExpenseScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;

  final List<Map<String, dynamic>> transactions = [
    {
      'amount': 250.0,
      'direction': 'gave',
      'description': 'Dinner at Olive',
      'createdOn':
          DateTime.now().subtract(Duration(days: 1, hours: 2)).toString(),
      'createdBy': {'id': '1', 'name': 'Rohit Anand'},
      'modifiedOn': DateTime.now().toString(),
    },
    {
      'amount': 100.0,
      'direction': 'owe',
      'description': 'Shared cab',
      'createdOn':
          DateTime.now().subtract(Duration(days: 1, hours: 6)).toString(),
      'createdBy': {'id': '2', 'name': 'RA'},
      'modifiedOn': DateTime.now().toString(),
    },
    {
      'amount': 40.0,
      'direction': 'gave',
      'description': 'Snacks at the mall',
      'createdOn':
          DateTime.now().subtract(Duration(days: 2, hours: 4)).toString(),
      'createdBy': {'id': '1', 'name': 'Rohit Anand'},
      'modifiedOn': DateTime.now().toString(),
    },
    {
      'amount': 300.0,
      'direction': 'gave',
      'description': 'Weekend Airbnb',
      'createdOn':
          DateTime.now().subtract(Duration(days: 3, hours: 1)).toString(),
      'createdBy': {'id': '1', 'name': 'Rohit Anand'},
      'modifiedOn': DateTime.now().toString(),
    },
    {
      'amount': 80.0,
      'direction': 'owe',
      'description': 'Fuel split',
      'createdOn':
          DateTime.now().subtract(Duration(days: 3, hours: 2)).toString(),
      'createdBy': {'id': '2', 'name': 'RA'},
      'modifiedOn': DateTime.now().toString(),
    },
    {
      'amount': 20.0,
      'direction': 'gave',
      'description': 'Ice cream 🍦',
      'createdOn':
          DateTime.now().subtract(Duration(days: 4, hours: 5)).toString(),
      'createdBy': {'id': '1', 'name': 'Rohit Anand'},
      'modifiedOn': DateTime.now().toString(),
    },
    {
      'amount': 60.0,
      'direction': 'owe',
      'description': 'Lunch at CCD',
      'createdOn':
          DateTime.now().subtract(Duration(days: 5, hours: 3)).toString(),
      'createdBy': {'id': '2', 'name': 'RA'},
      'modifiedOn': DateTime.now().toString(),
    },
    {
      'amount': 90.0,
      'direction': 'gave',
      'description': 'Board games',
      'createdOn':
          DateTime.now().subtract(Duration(days: 5, hours: 4)).toString(),
      'createdBy': {'id': '1', 'name': 'Rohit Anand'},
      'modifiedOn': DateTime.now().toString(),
    },
    {
      'amount': 150.0,
      'direction': 'owe',
      'description':
          'Concert tickets and Country Foods, Concert tickets and Country Foods 🎵',
      'createdOn':
          DateTime.now().subtract(Duration(days: 6, hours: 2)).toString(),
      'createdBy': {'id': '2', 'name': 'RA'},
      'modifiedOn': DateTime.now().toString(),
    },
    {
      'amount': 110.0,
      'direction': 'gave',
      'description': 'Groceries',
      'createdOn':
          DateTime.now().subtract(Duration(days: 7, hours: 5)).toString(),
      'createdBy': {'id': '1', 'name': 'Rohit Anand'},
      'modifiedOn': DateTime.now().toString(),
    },
    {
      'amount': 45.0,
      'direction': 'owe',
      'description': 'Tea & Snacks',
      'createdOn':
          DateTime.now().subtract(Duration(days: 8, hours: 1)).toString(),
      'createdBy': {'id': '2', 'name': 'RA'},
      'modifiedOn': DateTime.now().toString(),
    },
    {
      'amount': 35.0,
      'direction': 'gave',
      'description': 'Auto fare',
      'createdOn':
          DateTime.now().subtract(Duration(days: 8, hours: 3)).toString(),
      'createdBy': {'id': '1', 'name': 'Rohit Anand'},
      'modifiedOn': DateTime.now().toString(),
    },
    {
      'amount': 200.0,
      'direction': 'gave',
      'description': 'Shopping at Dmart',
      'createdOn':
          DateTime.now().subtract(Duration(days: 9, hours: 6)).toString(),
      'createdBy': {'id': '1', 'name': 'Rohit Anand'},
      'modifiedOn': DateTime.now().toString(),
    },
    {
      'amount': 30.0,
      'direction': 'owe',
      'description': 'Late night Maggie',
      'createdOn':
          DateTime.now().subtract(Duration(days: 9, hours: 7)).toString(),
      'createdBy': {'id': '2', 'name': 'RA'},
      'modifiedOn': DateTime.now().toString(),
    },
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
          SliverList.builder(
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom:
                      index == transactions.length - 1
                          ? UiConstant.spaceAtBottom
                          : 0,
                ),
                child: LendenExpenseCard(
                  expense: LenDenModel.fromMap(transactions[index]),
                  loggedInUser: UserModel.fromBasicInfoMap({
                    'id': '1',
                    'name': 'Rohit Anand',
                  }),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: CustomButton.customFloatingButton(
        Iconsax.add,
        () {},
      ),
    );
  }
}
