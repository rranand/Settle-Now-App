import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/personal_expense_card.dart';
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
              "Search",
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
                  return PersonalExpenseCard(index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
