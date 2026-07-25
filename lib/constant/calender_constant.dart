class CalenderConstant {
  static final List<String> monthName = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  static final List<String> monthNameInLowerCase = [
    "january",
    "february",
    "march",
    "april",
    "may",
    "june",
    "july",
    "august",
    "september",
    "october",
    "november",
    "december",
  ];

  static int getIndexOfMonth(String monthName) {
    return CalenderConstant.monthNameInLowerCase.indexOf(
      monthName.toLowerCase(),
    );
  }
}
