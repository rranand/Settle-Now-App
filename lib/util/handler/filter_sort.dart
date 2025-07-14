class FilterSort {
  static List<T> filteredSearchText<T>(
    String searchText,
    List<T> arr,
    String Function(T) getName,
  ) {
    if (searchText.isEmpty) {
      return arr;
    }
    searchText = searchText.trim().toLowerCase();
    return arr
        .where((ele) => getName(ele).toLowerCase().contains(searchText))
        .toList();
  }
}
