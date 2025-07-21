import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class FilterWidget {
  static Widget buildEnumRadioGroup<T extends Enum>(
    String displayValue,
    T enumValue,
    ValueNotifier<T> valueNotifier,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(displayValue),
      leading: Radio<T>(
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
    T value,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(displayValue),
      leading: Checkbox(
        checkColor: Colors.white,
        activeColor: Colors.deepPurpleAccent,
        value: valueNotifier.value.contains(value),
        onChanged: (bool? selected) {
          if (selected != null) {
            final updated = Set<T>.from(valueNotifier.value);
            if (selected) {
              updated.add(value);
            } else {
              updated.remove(value);
            }
            valueNotifier.value = updated;
          }
        },
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
