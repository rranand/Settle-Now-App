import 'package:settlenow/model/model_core.dart';

class PersonalExpenseTransactionModel extends BaseTransactionModel {
  String category;
  RoomLinkedModel roomData;

  PersonalExpenseTransactionModel({
    required super.id,
    required super.amount,
    required super.description,
    required super.createdBy,
    required super.createdOn,
    required super.modifiedOn,
    required this.category,
    required this.roomData,
  });

  PersonalExpenseTransactionModel.empty()
    : category = "",
      roomData = RoomLinkedModel.empty(),
      super.empty();

  @override
  PersonalExpenseTransactionModel copyWith({
    String? id,
    double? amount,
    String? description,
    String? category,
    String? createdBy,
    DateTime? createdOn,
    DateTime? modifiedOn,
    RoomLinkedModel? roomData,
  }) {
    return PersonalExpenseTransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdOn: createdOn ?? this.createdOn,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      category: category ?? this.category,
      roomData: roomData ?? this.roomData,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...super.toMap(),
      category: category,
      'room_data': roomData.toMap(),
    };
  }

  factory PersonalExpenseTransactionModel.fromBaseObject(
    BaseTransactionModel baseData, {
    String? category,
    RoomLinkedModel? roomLinkedData,
  }) {
    return PersonalExpenseTransactionModel(
      id: baseData.id,
      amount: baseData.amount,
      description: baseData.description,
      createdBy: baseData.createdBy,
      createdOn: baseData.createdOn,
      modifiedOn: baseData.modifiedOn,
      category: category ?? "",
      roomData: roomLinkedData ?? RoomLinkedModel.empty(),
    );
  }

  factory PersonalExpenseTransactionModel.fromMap(Map<String, dynamic> map) {
    final data = BaseTransactionModel.fromMap(map);

    return PersonalExpenseTransactionModel.fromBaseObject(
      data,
      category: map['category'],
      roomLinkedData:
          map['room_data'] != null
              ? RoomLinkedModel.fromMap(map['room_data'])
              : RoomLinkedModel.empty(),
    );
  }

  @override
  Map<String, dynamic> toCreateExpenseJson() {
    return <String, dynamic>{
      ...super.toCreateExpenseJson(),
      "category": category,
    };
  }

  @override
  Map<String, dynamic> toUpdateExpenseJson() {
    return <String, dynamic>{
      ...super.toUpdateExpenseJson(),
      "category": category,
    };
  }

  @override
  String toString() {
    return 'PersonalExpenseTransactionModel(id: $id, amount: $amount, description: $description, category: $category, createdOn: $createdOn, modifiedOn: $modifiedOn, roomData: $roomData)';
  }

  @override
  bool operator ==(covariant PersonalExpenseTransactionModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.amount == amount &&
        other.description == description &&
        other.category == category &&
        other.createdOn == createdOn &&
        other.roomData == roomData;
  }

  @override
  int get hashCode {
    return super.hashCode ^ category.hashCode ^ roomData.hashCode;
  }
}
