import 'package:intl/intl.dart';
import 'package:moment_dart/moment_dart.dart';

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

String convertDateTimeFormat(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dateOnly = DateTime(date.year, date.month, date.day);

  if (dateOnly == today) {
    return 'Today, ${DateFormat.jm().format(date)}';
  } else if (dateOnly == today.subtract(Duration(days: 1))) {
    return 'Yesterday, ${DateFormat.jm().format(date)}';
  } else if (now.difference(date).inDays < 7 && now.year == date.year) {
    return '${DateFormat.E().format(date)} ${DateFormat.jm().format(date)}';
  } else if (now.year == date.year) {
    return '${DateFormat.MMMd().format(date)} ${DateFormat.jm().format(date)}';
  } else {
    return '${DateFormat.yMMMd().format(date)} ${DateFormat.jm().format(date)}';
  }
}

String convertInDateFormat(DateTime date) {
  return DateFormat.yMMMd().format(date);
}

DateTime? convertFromDateFormat(String date) {
  return DateFormat.yMMMd().tryParse(date);
}
