import 'package:oees/application/app_store.dart';
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

  TaskBatch._({
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

  static Future<TaskBatch> fromJSON(Map<String, dynamic> jsonObject) async {
    late TaskBatch taskBatch;

    await appStore.userApp.getUser(jsonObject["created_by_username"]).then((createdByResponse) async {
      await appStore.userApp.getUser(jsonObject["updated_by_username"]).then((udpatedByResponse) async {
        await appStore.taskApp.getTask(jsonObject["task_id"]).then((taskResponse) async {
          taskBatch = TaskBatch._(
            batchNumber: jsonObject["batch_number"],
            batchSize: double.parse(jsonObject["batch_size"].toString()),
            complete: jsonObject["complete"],
            createdAt: DateTime.parse(jsonObject["created_at"]),
            createdBy: await User.fromJSON(createdByResponse["payload"]),
            endTime: DateTime.parse(jsonObject["end_time"] ?? "2099-12-31T23:59:59Z").toLocal(),
            startTime: DateTime.parse(jsonObject["start_time"]),
            task: await Task.fromJSON(taskResponse["payload"]),
            id: jsonObject["id"],
            updatedAt: DateTime.parse(jsonObject["updated_at"]),
            updatedBy: await User.fromJSON(udpatedByResponse["payload"]),
          );
        });
      });
    });

    return taskBatch;
  }
}
