import 'package:hive/hive.dart';

part 'category_type.g.dart';

/// Defines how a category can be used in the app.
/// This keeps income and expense categories explicitly separated.
@HiveType(typeId: 1)
enum CategoryType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,

  @HiveField(2)
  both,
}