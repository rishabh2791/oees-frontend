import 'package:oees/application/app_store.dart';
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

  Task._({
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

  static Future<Task> fromJSON(Map<String, dynamic> jsonObject) async {
    late Task task;

    await appStore.userApp.getUser(jsonObject["created_by_username"]).then((createdByResponse) async {
      await appStore.userApp.getUser(jsonObject["updated_by_username"]).then((udpatedByResponse) async {
        await appStore.lineApp.getLine(jsonObject["line_id"]).then((lineResponse) async {
          Map<String, dynamic> conditions = {
            "LIKE": {
              "Field": "id",
              "Value": jsonObject["job_id"],
            }
          };
          await appStore.jobApp.list(conditions).then((jobResponse) async {
            await appStore.shiftApp.getShift(jsonObject["shift_id"]).then((shiftResponse) async {
              task = Task._(
                job: await Job.fromJSON(jobResponse["payload"][0]),
                createdAt: DateTime.parse(jsonObject["created_at"]),
                createdBy: await User.fromJSON(createdByResponse["payload"]),
                endTime: DateTime.parse(jsonObject["end_time"] ?? "2099-12-31T23:59:59Z").toLocal(),
                id: jsonObject["id"],
                line: await Line.fromJSON(lineResponse["payload"]),
                startTime: DateTime.parse(jsonObject["start_time"] ?? "1900-01-01T00:00:00Z").toLocal(),
                updatedAt: DateTime.parse(jsonObject["updated_at"]),
                updatedBy: await User.fromJSON(udpatedByResponse["payload"]),
                plan: int.parse(jsonObject["plan"].toString()),
                actual: int.parse(jsonObject["actual"].toString()),
                scheduledDate: DateTime.parse(jsonObject["scheduled_date"]),
                shift: await Shift.fromJSON(shiftResponse["payload"]),
                complete: jsonObject["complete"],
              );
            });
          });
        });
      });
    });

    return task;
  }
}
