import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/internationalization/currency.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';

class PersonalExpenseScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const PersonalExpenseScreen({super.key, required this.isSearchEnabled});

  @override
  State<PersonalExpenseScreen> createState() => _PersonalExpenseScreenState();
}

class _PersonalExpenseScreenState extends State<PersonalExpenseScreen> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final TextEditingController _searchController = TextEditingController();

  List<Color> colors = [
    Colors.red.shade50,
    Colors.green.shade50,
    Colors.blue.shade50,
    Colors.yellow.shade50,
    Colors.orange.shade50,
    Colors.purple.shade50,
    Colors.teal.shade50,
    Colors.pink.shade50,
    Colors.brown.shade50,
    Colors.grey.shade50,
    Colors.indigo.shade50,
    Colors.lime.shade50,
    Colors.cyan.shade50,
    Colors.amber.shade50,
    Colors.deepOrange.shade50,
    Colors.deepPurple.shade50,
    Colors.lightGreen.shade50,
    Colors.lightBlue.shade50,
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
      body: Padding(
        padding: _mainScreenPadding,
        child: Column(
          children: [
            CustomFormField.searchBar(
              "Search...",
              widget.isSearchEnabled,
              _searchController,
              (value) {
                // Add filter logic if needed
              },
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.only(
                  top: UiConstant.spaceBetweenSection,
                  bottom: 2 * UiConstant.spaceBetweenSection,
                ),
                shrinkWrap: true,
                itemCount: 20,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black.withAlpha(51)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(51),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          text: 'December',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(text: '\n2023'),
                            TextSpan(text: '\n\n'),
                            TextSpan(
                              text: formatCurrency(2100, context),
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
