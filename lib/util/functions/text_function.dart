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
