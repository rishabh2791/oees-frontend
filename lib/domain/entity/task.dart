import 'package:oees/domain/entity/job.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/shift.dart';
import 'package:oees/domain/entity/user.dart';

class Task {
  final String id;
  final Job job;
  final Line line;
  DateTime scheduledDate;
  final Shift shift;
  DateTime startTime;
  DateTime endTime;
  final User createdBy;
  final DateTime createdAt;
  final User updatedBy;
  final DateTime updatedAt;
  final int plan;
  final int actual;
  bool selected = false;
  bool complete = false;
  bool running = false;

  Task({
    required this.job,
    required this.createdAt,
    required this.createdBy,
    required this.endTime,
    required this.id,
    required this.line,
    required this.startTime,
    required this.updatedAt,
    required this.updatedBy,
    required this.plan,
    required this.actual,
    required this.scheduledDate,
    required this.shift,
    required this.complete,
  });

  @override
  String toString() {
    return job.code + "_" + job.sku.code + "_" + job.sku.description;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "actual": actual,
      "job": job.toJSON(),
      "created_at": createdAt,
      "created_by": createdBy.toJSON(),
      "end_time": endTime,
      "id": id,
      "line": line.toJSON(),
      "scheduled_date": scheduledDate,
      "shift": shift,
      "plan": plan,
      "start_time": startTime,
      "updated_at": updatedAt,
      "updated_by": updatedBy.toJSON(),
    };
  }

  factory Task.fromJSON(Map<String, dynamic> jsonObject) {
    Task task = Task(
      actual: int.parse(jsonObject["actual"].toString()),
      job: Job.fromJSON(jsonObject["job"]),
      scheduledDate: DateTime.parse(jsonObject["scheduled_date"]),
      shift: Shift.fromJSON(jsonObject["shift"]),
      createdAt: DateTime.parse(jsonObject["created_at"]),
      createdBy: User.fromJSON(jsonObject["created_by"]),
      endTime: DateTime.parse(jsonObject["end_time"] ?? "2099-12-31T23:59:59Z").toLocal(),
      id: jsonObject["id"],
      line: Line.fromJSON(jsonObject["line"]),
      plan: int.parse(jsonObject["plan"].toString()),
      startTime: DateTime.parse(jsonObject["start_time"] ?? "1900-01-01T00:00:00Z").toLocal(),
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      updatedBy: User.fromJSON(jsonObject["updated_by"]),
      complete: jsonObject["complete"],
    );
    if ((jsonObject["end_time"] ?? "").isEmpty && (jsonObject["start_time"] ?? "").isNotEmpty) {
      task.running = true;
    }
    return task;
  }
}
