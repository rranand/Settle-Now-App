import 'package:intl/intl.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';

String capatilizeFirstLetter(String inputText) {
  if (inputText.isEmpty) {
    return inputText;
  }

  String formattedString = inputText[0].toUpperCase();

  for (int i = 1; i < inputText.length; i++) {
    if (inputText[i - 1] == " ") {
      formattedString += inputText[i].toUpperCase();
    } else {
      formattedString += inputText[i];
    }
  }
  return formattedString;
}

String convertToMoment(DateTime dateTime) {
  String momentStr = dateTime.toMoment().fromNow();
  momentStr = momentStr
      .replaceAll("seconds", "Secs")
      .replaceAll("minutes", "Mins")
      .replaceAll("a few", "Few")
      .replaceAll("about", "~");

  return capatilizeFirstLetter(momentStr);
}

String convertDateTimeFormat(DateTime dateTime) {
  return DateFormat(UiConstant.expenseDatetimeFormat).format(dateTime);
}
