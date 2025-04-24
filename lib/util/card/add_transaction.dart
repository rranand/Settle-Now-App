import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:settlenow_v2/constant/gradient_color_constant.dart';
import 'package:settlenow_v2/constant/home_ui_constant.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/provider/screen_size_provider.dart';
import 'package:settlenow_v2/util/functions/text_function.dart';
import 'package:settlenow_v2/util/widgets/custom_button.dart';
import 'package:settlenow_v2/util/widgets/custom_form_field.dart';
import 'package:settlenow_v2/util/widgets/gradient_widget.dart';
import 'package:settlenow_v2/util/widgets/stacked_image.dart';
import 'package:settlenow_v2/util/widgets/widgets.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  EdgeInsets _mainScreenPadding = EdgeInsets.zero;
  final double _userCardWidth = 110;
  final double _userCardHeight = 110;
  final double _userImageRadius = 50;

  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _creationDateController = TextEditingController();

  final List<String> _splitType = ["Equal", "Partial", "Self"];
  final ValueNotifier<int> _categoryIndex = ValueNotifier(0);
  final ValueNotifier<int> _splitTypeIndex = ValueNotifier(0);
  final ValueNotifier<Set<String>> _selectedUserIDs = ValueNotifier({});

  Widget _userCardWidget(UserModel user, Set<String> selectedUserIDs) {
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstant.cardBorderRadius),
      onTap: () {
        final current = Set<String>.from(_selectedUserIDs.value);
        if (current.contains(user.id)) {
          current.remove(user.id);
        } else {
          current.add(user.id);
        }
        _selectedUserIDs.value = current;
      },
      child: Center(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                overlapUserImageWidget(context, [user], 1, imageRadius: 50),
                SizedBox(height: 8),
                Text(
                  user.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            Positioned(
              left: _userImageRadius / 2 + 10,
              top: 0,
              bottom: 0,
              right: 0,
              child:
                  selectedUserIDs.contains(user.id)
                      ? Icon(Icons.check_circle, color: Colors.green, size: 24)
                      : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Category", style: TextStyle(fontSize: 20)),
        SizedBox(height: .5 * UiConstant.spaceBetweenSection),
        ValueListenableBuilder(
          valueListenable: _categoryIndex,
          builder: (context, value, _) {
            return Wrap(
              spacing: UiConstant.spaceBetweenCard,
              runSpacing: UiConstant.spaceBetweenCard,
              children: List.generate(
                categoryIcons.length,
                (index) => InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => _categoryIndex.value = index,
                  child: GradientBorderCard(
                    borderRadius: 100,
                    borderWidth: 1,
                    gradientColors:
                        index == value
                            ? GradientColorConstant.vibrantGradient
                            : [Colors.grey.shade300, Colors.grey.shade300],
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          colouredIcon(
                            Icon(categoryIcons[index]),
                            UiConstant.colorsWithShade100[index],
                            radius: 40,
                          ),
                          SizedBox(width: 8),
                          Text(expenseCategories[index]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _splitTypeCardWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Split Type", style: TextStyle(fontSize: 20)),
        SizedBox(height: .5 * UiConstant.spaceBetweenSection),
        ValueListenableBuilder(
          valueListenable: _splitTypeIndex,
          builder: (context, value, _) {
            return Wrap(
              spacing: UiConstant.spaceBetweenCard,
              runSpacing: UiConstant.spaceBetweenCard,
              children: List.generate(
                _splitType.length,
                (index) => InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => _splitTypeIndex.value = index,
                  child: GradientBorderCard(
                    borderRadius: 100,
                    borderWidth: 1,
                    gradientColors:
                        index == value
                            ? GradientColorConstant.vibrantGradient
                            : [Colors.grey.shade300, Colors.grey.shade300],
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(_splitType[index]),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

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
        title: Text("Add New Expense"),
        centerTitle: false,
        titleSpacing: _mainScreenPadding.left,
        leading: appBarBackButton(context),
      ),
      body: SingleChildScrollView(
        padding: _mainScreenPadding.add(
          EdgeInsets.only(
            top: UiConstant.spaceBetweenSection,
            bottom: UiConstant.spaceAtBottom,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomFormField.textFormField(
                _amountController,
                textInputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                hintText: 'Amount',
                labelText: 'Amount',
                inputDecoration: TextFormFieldInputBorder.underLine,
                borderColor: Colors.black87,
                suffixIcon: Icon(
                  IconData(
                    UiConstant.indianRupeeSymbol,
                    fontFamily: 'MaterialIcons',
                  ),
                ),
              ),
              SizedBox(height: UiConstant.spaceBetweenSection),
              CustomFormField.textFormField(
                _descriptionController,
                hintText: 'Description',
                labelText: 'Description',
                inputDecoration: TextFormFieldInputBorder.underLine,
                borderColor: Colors.black87,
                maxLines: 2,
              ),
              SizedBox(height: UiConstant.spaceBetweenSection),
              CustomFormField.textFormField(
                _creationDateController,
                readOnly: true,
                labelText: 'Creation Date',
                hintText: 'Creation Date',
                inputDecoration: TextFormFieldInputBorder.underLine,
                borderColor: Colors.black87,
                suffixIcon: Icon(Iconsax.calendar),
                onTap: () async {
                  DateTime? dateTime = await showOmniDateTimePicker(
                    context: context,
                    is24HourMode: false,
                    isShowSeconds: false,
                    borderRadius: BorderRadius.circular(16.0),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  );
                  if (dateTime != null && mounted) {
                    _creationDateController.text = convertDateTimeFormat(
                      dateTime,
                    );
                  }
                },
              ),
              SizedBox(height: UiConstant.spaceBetweenSection),
              _splitTypeCardWidget(),
              SizedBox(height: UiConstant.spaceBetweenSection),
              ValueListenableBuilder(
                valueListenable: _splitTypeIndex,
                builder: (context, value, child) {
                  if (_splitType[value].contains("Partial")) {
                    return child!;
                  } else {
                    return SizedBox.shrink();
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Members", style: TextStyle(fontSize: 20)),
                    SizedBox(height: .5 * UiConstant.spaceBetweenSection),
                    LayoutBuilder(
                      builder: (context, constraint) {
                        final double screenWidth = constraint.maxWidth;
                        final double spacing = 8.0;
                        final int columns =
                            (screenWidth / (_userCardWidth + spacing)).floor();
                        final double adjustedWidth =
                            (screenWidth - ((columns - 1) * spacing)) / columns;
                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: UiConstant.users.length,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: adjustedWidth,
                                mainAxisSpacing: spacing,
                                childAspectRatio:
                                    adjustedWidth / _userCardHeight,
                              ),
                          itemBuilder: (context, index) {
                            UserModel user = UiConstant.users[index];
                            return ValueListenableBuilder(
                              valueListenable: _selectedUserIDs,
                              builder: (
                                BuildContext context,
                                Set<String> value,
                                Widget? child,
                              ) {
                                return _userCardWidget(user, value);
                              },
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: UiConstant.spaceBetweenSection),
                  ],
                ),
              ),
              _categoryWidget(),
              SizedBox(height: UiConstant.spaceBetweenSection),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: GradientBorderCard(
                    borderRadius: 100,
                    borderWidth: 1,
                    gradientColors: GradientColorConstant.vibrantGradient,
                    child: CustomButton.customOutlinedButton(
                      "Add Expense",
                      buttonHeight: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
