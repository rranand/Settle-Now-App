class FreshMessageModel {
  final String title;
  final String description;

  FreshMessageModel({required this.title, required this.description});
}

class FreshScreenMessageConstant {
  static final noRoomDashboard = FreshMessageModel(
    title: 'Start splitting expenses',
    description:
        'Create a room for group expenses, or join a room using an invite code.',
  );

  static final noCloseRoomDashboard = FreshMessageModel(
    title: 'No closed rooms yet',
    description: 'View past expenses and settlements from your closed rooms.',
  );

  static final noLendenDashboard = FreshMessageModel(
    title: 'Track money between friends',
    description:
        'Keep track of money you lend or borrow and always know who owes whom.',
  );

  static final noQuicksplitDashboard = FreshMessageModel(
    title: 'Split an expense instantly',
    description:
        'Split a one-time expense with friends without creating a room.',
  );

  static final noPersonalMonthlyDashboard = FreshMessageModel(
    title: 'Start tracking your expenses',
    description:
        'Record your everyday expenses and keep track of your monthly spending.',
  );

  static final noRoomTransaction = FreshMessageModel(
    title: 'No expenses yet',
    description:
        'Add your first group expense and we’ll keep track of who owes whom.',
  );

  static final noRoomSettlement = FreshMessageModel(
    title: 'No settlements yet',
    description:
        'Settlements between room members will appear here once someone pays another member.',
  );

  static final noLendenTransaction = FreshMessageModel(
    title: 'No transactions yet',
    description:
        'Record money you give or receive to keep your Len-Den balance up to date.',
  );

  static final noPersonalMonthlyTransaction = FreshMessageModel(
    title: 'No expenses this month',
    description: 'No transactions are recorded for this month yet.',
  );

  static final noRequestDashboard = FreshMessageModel(
    title: 'You’re all caught up',
    description: 'You don’t have any pending requests right now.',
  );

  static final noFriendsDashboard = FreshMessageModel(
    title: 'No friends yet',
    description: 'Add friends to easily split expenses.',
  );
}
