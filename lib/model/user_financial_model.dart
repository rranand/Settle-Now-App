import 'package:settlenow/model/model_core.dart';

class UserFinancialData {
  final UserModel user;
  final double contribution;
  final double spent;

  UserFinancialData({
    required this.user,
    required this.contribution,
    required this.spent,
  });

  factory UserFinancialData.fromRoomUserModel(RoomUserModel data) {
    return UserFinancialData(
      user: data.user,
      contribution: data.contribution,
      spent: data.spent,
    );
  }

  @override
  bool operator ==(covariant UserFinancialData other) {
    if (identical(this, other)) return true;

    return other.user == user &&
        other.contribution == contribution &&
        other.spent == spent;
  }

  @override
  int get hashCode {
    return user.hashCode ^ contribution.hashCode ^ spent.hashCode;
  }
}
