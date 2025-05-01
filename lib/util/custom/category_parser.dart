import 'package:flutter/material.dart';

class CategoryParser {
  static final List<String> expenseCategories = [
    'Utilities',
    'Food',
    'Household',
    'Entertainment',
    'Personal',
    'HealthCare',
    'Investment',
    'Debt Payments',
    'Education',
    'Travel',
    'Gifts/Donation',
    'Pet',
    'Insurance',
    'Miscellaneous',
  ];
  static final List<IconData> expenseCategoryIcons = [
    Icons.lightbulb_outline, // 💡 Utilities
    Icons.fastfood, // 🍔 Food
    Icons.home, // 🏠 Household
    Icons.movie, // 🎬 Entertainment
    Icons.person, // 🧴 Personal
    Icons.local_hospital, // 🏥 HealthCare
    Icons.trending_up, // 📈 Investment
    Icons.credit_card, // 💳 Debt Payments
    Icons.school, // 📚 Education
    Icons.flight, // ✈️ Travel
    Icons.card_giftcard, // 🎁 Gifts/Donation
    Icons.pets, // 🐕 Pet
    Icons.security, // 🛡️ Insurance
    Icons.category, // 📦 Miscellaneous
  ];

  static final Map<String, int> _categoryToIndex = {
    'Utilities': 0,
    'Food': 1,
    'Household': 2,
    'Entertainment': 3,
    'Personal': 4,
    'HealthCare': 5,
    'Investment': 6,
    'Debt Payments': 7,
    'Education': 8,
    'Travel': 9,
    'Gifts/Donation': 10,
    'Pet': 11,
    'Insurance': 12,
    'Miscellaneous': 13,
  };

  static List<String> getCategoryList() {
    return expenseCategories;
  }

  static IconData getCategoryIconByCategory(String category) {
    return getCategoryIconByIndex(_categoryToIndex[category]!);
  }

  static int indexOfCategory(String category) {
    return _categoryToIndex[category] ?? 0;
  }

  static IconData getCategoryIconByIndex(int categoryIndex) {
    return expenseCategoryIcons[categoryIndex];
  }
}
