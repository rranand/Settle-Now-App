part of 'filter_cubit.dart';

class FilterState {
  final String? id;
  final SortBy? sortBy;
  final SortRules? sortRule;
  final Set<int> selectedCategories;
  final RangeValues? amountRange;
  final DateTimeRange? dateRange;
  final Set<String> createdByUsers;
  final String? splitType;
  final Set<String> selectedRoom;
  final bool isFilterApplied;
  final List<dynamic> data;

  const FilterState({
    this.id,
    this.sortBy,
    this.sortRule,
    this.selectedCategories = const {},
    this.selectedRoom = const {},
    this.amountRange,
    this.dateRange,
    this.createdByUsers = const {},
    this.splitType,
    this.isFilterApplied = false,
    this.data = const [],
  });

  FilterState copyWith({
    String? id,
    SortBy? sortBy,
    SortRules? sortRule,
    Set<int>? selectedCategories,
    Set<String>? selectedRoom,
    RangeValues? amountRange,
    DateTimeRange? dateRange,
    Set<String>? createdByUsers,
    String? splitType,
    bool? isFilterApplied,
    List<dynamic>? data,
  }) {
    return FilterState(
      id: id ?? this.id,
      sortBy: sortBy ?? this.sortBy,
      sortRule: sortRule ?? this.sortRule,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      amountRange: amountRange ?? this.amountRange,
      dateRange: dateRange ?? this.dateRange,
      createdByUsers: createdByUsers ?? this.createdByUsers,
      splitType: splitType ?? this.splitType,
      isFilterApplied: isFilterApplied ?? this.isFilterApplied,
      data: data ?? this.data,
    );
  }

}
