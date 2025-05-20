class RouterConstants {
  //Auth Route
  static const String loginRouteName = '/login';
  static const String signupRouteName = '/signup';

  //Dashboard Route
  static const String dashboardRouteName = '/';
  static const String roomRouteName = '/room';
  static const String personalExpenseRouteName = '/personal';
  static const String lendenRouteName = '/lenden';
  static const String analysis = '/analysis';

  //Personal Expense Route
  static const String personalExpenseAddExpenseRouteName = '/add';
  static const String personalExpenseEditExpenseRouteName = '/edit';

  //Quicksplit
  static const String quickSplitAddExpenseRouteName = '/quicksplit/add';
  static const String quickSplitEditExpenseRouteName = '/quicksplit/edit';

  //Profile Route
  static const String profileRouteName = '/profile';
  static const String profileEditRouteName = '/edit';
  static const String loginActivityRouteName = '/logInactivity';

  //Error Route
  static const String errorPageRouteName = '/404';

  //Deep Link
  static const String deepLinkJoinRoom = '/room';
  static const String deepLinkJoinLend = '/lend';
}
