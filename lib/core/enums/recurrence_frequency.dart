import 'package:hive/hive.dart';

part 'recurrence_frequency.g.dart';

/// Defines how often a recurring transaction repeats.
@HiveType(typeId: 6)
enum RecurrenceFrequency {
  @HiveField(0)
  weekly,

  @HiveField(1)
  monthly,
}