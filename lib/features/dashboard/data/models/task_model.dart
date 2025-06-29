import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
class TaskModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String details;

  @HiveField(3)
  final DateTime endDate;

  @HiveField(4)
  final String editedBy;

  @HiveField(5)
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.details,
    required this.endDate,
    required this.editedBy,
    this.isCompleted = false,
  });
}