import 'package:settlenow/model/model_core.dart';

class UserFinancialData extends BaseUserModel {
  final double contribution;
  final double spent;

  UserFinancialData({
    required super.id,
    required super.name,
    required super.profilePic,
    required this.contribution,
    required this.spent,
  });

  factory UserFinancialData.fromRoomUserModel(RoomUserModel data) {
    return UserFinancialData(
      id: data.id,
      name: data.name,
      profilePic: data.profilePic,
      contribution: data.contribution,
      spent: data.spent,
    );
  }

  @override
  bool operator ==(covariant UserFinancialData other) {
    if (identical(this, other)) return true;

    return super.id == id &&
        other.contribution == contribution &&
        other.spent == spent;
  }

  @override
  int get hashCode {
    return super.hashCode ^ contribution.hashCode ^ spent.hashCode;
  }
}
