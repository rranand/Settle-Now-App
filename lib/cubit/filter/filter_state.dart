// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'filter_cubit.dart';

class FilterState {
  final String? id;
  final SortBy? sortBy;
  final SortRules? sortRule;
  final LendenType? lendenType;
  final Set<int> selectedCategories;
  final RangeValues? amountRange;
  final DateTimeRange? dateRange;
  final Set<String> selectedUsers;
  final String? splitType;
  final Set<String> selectedRoom;
  final bool isFilterApplied;
  final List<dynamic> data;

  const FilterState({
    this.id,
    this.sortBy,
    this.sortRule,
    this.lendenType,
    this.selectedCategories = const {},
    this.selectedRoom = const {},
    this.amountRange,
    this.dateRange,
    this.selectedUsers = const {},
    this.splitType,
    this.isFilterApplied = false,
    this.data = const [],
  });

  FilterState copyWith({
    String? id,
    SortBy? sortBy,
    SortRules? sortRule,
    LendenType? lendenType,
    Set<int>? selectedCategories,
    Set<String>? selectedRoom,
    RangeValues? amountRange,
    DateTimeRange? dateRange,
    Set<String>? selectedUsers,
    String? splitType,
    bool? isFilterApplied,
    List<dynamic>? data,
  }) {
    return FilterState(
      id: id ?? this.id,
      sortBy: sortBy ?? this.sortBy,
      sortRule: sortRule ?? this.sortRule,
      lendenType: lendenType ?? this.lendenType,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      amountRange: amountRange ?? this.amountRange,
      dateRange: dateRange ?? this.dateRange,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      splitType: splitType ?? this.splitType,
      isFilterApplied: isFilterApplied ?? this.isFilterApplied,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'FilterState(id: $id, sortBy: $sortBy, sortRule: $sortRule, lendenType: $lendenType, selectedCategories: $selectedCategories, amountRange: $amountRange, dateRange: $dateRange, selectedUsers: $selectedUsers, splitType: $splitType, selectedRoom: $selectedRoom, isFilterApplied: $isFilterApplied, data: $data)';
  }
}
