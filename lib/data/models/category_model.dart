import 'package:hive/hive.dart';
import 'package:sovereign_ledger/core/enums/category_type.dart';

part 'category_model.g.dart';

/// Represents a transaction category such as Food, Transport, or Salary.
/// Stored locally with Hive for offline-first access.
@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
  /// Unique identifier used as the Hive key.
  @HiveField(0)
  final String id;

  /// Human-readable category name shown in the UI.
  @HiveField(1)
  final String name;

  /// Color stored as an integer so it can be persisted easily.
  @HiveField(2)
  final int colorValue;

  /// Icon reference key that will later map to a real Flutter icon.
  @HiveField(3)
  final String iconKey;

  /// Controls whether the category is used for income, expense, or both.
  @HiveField(4)
  final CategoryType categoryType;

  CategoryModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconKey,
    required this.categoryType,
  });
}