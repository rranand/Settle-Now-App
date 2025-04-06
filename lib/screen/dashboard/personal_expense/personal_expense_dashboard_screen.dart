import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/card/personal_expense_card.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';

class PersonalExpenseDashboardScreen extends StatefulWidget {
  final ValueNotifier<bool> isSearchEnabled;
  const PersonalExpenseDashboardScreen({
    super.key,
    required this.isSearchEnabled,
  });

  @override
  State<PersonalExpenseDashboardScreen> createState() =>
      _PersonalExpenseDashboardScreenState();
}

class _PersonalExpenseDashboardScreenState
    extends State<PersonalExpenseDashboardScreen> {
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
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: _mainScreenPadding,
              child: CustomFormField.searchBar(
                "Search",
                widget.isSearchEnabled,
                _searchController,
                (value) {
                  // Add filter logic if needed
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: _mainScreenPadding.add(
                  EdgeInsets.only(
                    top: UiConstant.spaceBetweenSection,
                    bottom: 2 * UiConstant.spaceBetweenSection,
                  ),
                ),
                child: Wrap(
                  spacing: UiConstant.spaceBetweenCard,
                  runSpacing: UiConstant.spaceBetweenCard,
                  children: List.generate(
                    11,
                    (index) => SizedBox(
                      width: 240,
                      height: 180,
                      child: PersonalExpenseCard(index: index),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
