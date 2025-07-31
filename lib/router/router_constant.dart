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

  //Lenden Route
  static const String lendenAddExpenseRouteName = '/add';
  static const String lendenEditExpenseRouteName = '/edit';

  //Room Route
  static const String roomAddExpenseRouteName = '/add';
  static const String roomEditExpenseRouteName = '/edit';
  static const String roomSettleAddRouteName = '/add-settle';
  static const String roomSettleEditRouteName = '/edit-settle';

  //Quicksplit
  static const String quickSplitAddExpenseRouteName = '/add-quicksplit';
  static const String quickSplitEditExpenseRouteName = '/edit-quicksplit';

  //Profile Route
  static const String profileRouteName = '/profile';
  static const String profileEditRouteName = '/edit';
  static const String loginActivityRouteName = '/logInactivity';

  //Invite Friend
  static const String inviteMember = '/invite';

  //Setting Page
  static const String settingPage = '/setting';

  //Setting Page
  static const String updatePage = '/update';

  //Maintenance Page
  static const String maintenancePage = '/maintenance';

  //About Us Page
  static const String aboutUsPage = '/about-us';

  //Error Route
  static const String errorPageRouteName = '/404';

  //Deep Link
  static const String deepLinkJoinRoom = '/room';
  static const String deepLinkJoinLend = '/lend';
}
