import 'package:oees/domain/entity/task.dart';
import 'package:oees/domain/entity/user.dart';

class TaskBatch {
  final String id;
  final Task task;
  final String batchNumber;
  final DateTime startTime;
  DateTime endTime;
  bool complete = false;
  double batchSize;
  final User createdBy;
  final DateTime createdAt;
  final User updatedBy;
  final DateTime updatedAt;

  TaskBatch({
    required this.batchNumber,
    required this.complete,
    required this.createdAt,
    required this.createdBy,
    required this.endTime,
    required this.id,
    required this.batchSize,
    required this.startTime,
    required this.task,
    required this.updatedAt,
    required this.updatedBy,
  });

  @override
  String toString() {
    return task.job.code + " - " + batchNumber;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{};
  }

  factory TaskBatch.fromJSON(Map<String, dynamic> jsonObject) {
    TaskBatch taskBatch = TaskBatch(
      batchNumber: jsonObject["batch_number"],
      complete: jsonObject["complete"],
      createdAt: DateTime.parse(jsonObject["created_at"]),
      createdBy: User.fromJSON(jsonObject["created_by"]),
      endTime: DateTime.parse(jsonObject["end_time"] ?? "2099-12-31T23:59:59Z").toLocal(),
      id: jsonObject["id"],
      batchSize: double.parse(jsonObject["batch_size"].toString()),
      startTime: DateTime.parse(jsonObject["start_time"]),
      task: Task.fromJSON(jsonObject["task"]),
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      updatedBy: User.fromJSON(jsonObject["created_by"]),
    );
    return taskBatch;
  }
}
