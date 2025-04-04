import 'package:flutter/material.dart';

class CategoryParser {
  static final Map<String, String> _categoryToEmoji = {
    'Utilities': '💡',
    'Food': '🍔',
    'Household': '🏠',
    'Entertainment': '🎬',
    'Personal': '🧴',
    'HealthCare': '🏥',
    'Investment': '📈',
    'Debt Payments': '💳',
    'Education': '📚',
    'Travel': '✈️',
    'Gifts/Donation': '🎁',
    'Pet': '🐕',
    'Insurance': '🛡️',
    'Miscellaneous': '📦',
  };

  static List<String> getCategoryList() {
    return _categoryToEmoji.entries.map((entry) => entry.key).toList();
  }

  static String getCategoryEmoji(String category) {
    return _categoryToEmoji[category] ?? '❓';
  }

  static Widget getCategoryEmojiAsWidget(String category, {double size = 24}) {
    return Text(getCategoryEmoji(category), style: TextStyle(fontSize: size));
  }

  static Widget getAllCategoryEmojiAsWidget({double size = 24}) {
    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children:
          getCategoryList()
              .map(
                (eachCategory) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withAlpha(51)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      getCategoryEmojiAsWidget(eachCategory),
                      SizedBox(width: 8),
                      Text(eachCategory),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
