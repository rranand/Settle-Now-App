class FilterSort {
  static List<T> filteredSearchText<T>(
    String searchText,
    List<T> arr,
    String Function(T) getText,
  ) {
    if (searchText.isEmpty) {
      return arr;
    }
    searchText = searchText.trim().toLowerCase();
    return arr.where((ele) => getText(ele).contains(searchText)).toList();
  }
}
