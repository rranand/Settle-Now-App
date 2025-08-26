import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/widgets/gradient_widget.dart';
import 'package:settlenow_v2/util/widgets/image_widget.dart';

class FilterWidget {
  static Widget buildEnumRadioGroup<T extends Enum>(
    String displayValue,
    T enumValue,
    BuildContext context,
    ValueNotifier<T> valueNotifier,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(displayValue),
      leading: Radio<T>(
        activeColor: Theme.of(context).primaryColor,
        value: enumValue,
        groupValue: valueNotifier.value,
        onChanged: (T? value) {
          if (value != null) {
            valueNotifier.value = value;
          }
        },
      ),
    );
  }

  static Widget buildCheckBox<T>(
    String displayValue,
    ValueNotifier<Set<T>> valueNotifier,
    BuildContext context,
    T id,
    int totalData,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(displayValue),
      leading: Checkbox(
        checkColor: Colors.white,
        activeColor: Theme.of(context).primaryColor,
        value: valueNotifier.value.contains(id),
        onChanged: (bool? selected) {
          if (selected != null) {
            final updated = Set<T>.from(valueNotifier.value);
            if (selected) {
              updated.add(id);
            } else {
              updated.remove(id);
            }
            if (totalData == updated.length) {
              valueNotifier.value = {};
            } else {
              valueNotifier.value = updated;
            }
          }
        },
      ),
    );
  }

  static Widget buildCardWidget<T>(
    T eachObject,
    T selected,
    BuildContext context,
    String text, {
    UserModel? user,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GradientBorderCard(
        borderRadius: 50,
        borderWidth: 2,
        gradientColors:
            eachObject == selected
                ? [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor,
                ]
                : [
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child:
            user == null
                ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: imageWidgetForCachedNetworkImage(
                        user.profileImage,
                        boxShape: BoxShape.circle,
                        width: 35,
                        height: 35,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ).add(EdgeInsets.only(right: 8, left: 2)),
                      child: Text(
                        user.name,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  static Future<DateTimeRange?> selectDate(
    BuildContext context,
    DateTimeRange selectedDateRange,
    DateTimeRange dateRange,
    bool isStartDate,
  ) async {
    DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      is24HourMode: false,
      isShowSeconds: false,
      type: OmniDateTimePickerType.date,
      firstDate: dateRange.start,
      lastDate: dateRange.end,
      initialDate: isStartDate ? dateRange.start : dateRange.end,
      borderRadius: BorderRadius.circular(16.0),
      padding: EdgeInsets.symmetric(vertical: 12),
    );
    if (dateTime != null) {
      if (isStartDate) {
        DateTime newDateTime = DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
        );
        selectedDateRange = DateTimeRange(
          start: newDateTime,
          end: selectedDateRange.end,
        );
      } else {
        DateTime newDateTime = DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
        ).add(Duration(days: 1, seconds: -1));
        selectedDateRange = DateTimeRange(
          start: selectedDateRange.start,
          end: newDateTime,
        );
      }

      return selectedDateRange;
    }

    return null;
  }
}
