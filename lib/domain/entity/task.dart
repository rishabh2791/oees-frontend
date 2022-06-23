import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/sku.dart';
import 'package:oees/domain/entity/user.dart';

class Task {
  final String id;
  final String code;
  final SKU sku;
  final Line line;
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
    required this.code,
    required this.createdAt,
    required this.createdBy,
    required this.endTime,
    required this.id,
    required this.line,
    required this.sku,
    required this.startTime,
    required this.updatedAt,
    required this.updatedBy,
    required this.plan,
    required this.actual,
  });

  @override
  String toString() {
    return code;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "actual": actual,
      "code": code,
      "created_at": createdAt,
      "created_by": createdBy.toJSON(),
      "end_time": endTime,
      "id": id,
      "line": line.toJSON(),
      "plan": plan,
      "sku": sku.toJSON(),
      "start_time": startTime,
      "updated_at": updatedAt,
      "updated_by": updatedBy.toJSON(),
    };
  }

  factory Task.fromJSON(Map<String, dynamic> jsonObject) {
    Task task = Task(
      actual: int.parse(jsonObject["actual"].toString()),
      code: jsonObject["code"],
      createdAt: DateTime.parse(jsonObject["created_at"]),
      createdBy: User.fromJSON(jsonObject["created_by"]),
      endTime: DateTime.parse(jsonObject["end_time"] ?? "2099-12-31T23:59:59Z").toLocal(),
      id: jsonObject["id"],
      line: Line.fromJSON(jsonObject["line"]),
      plan: int.parse(jsonObject["plan"].toString()),
      sku: SKU.fromJSON(jsonObject["sku"]),
      startTime: DateTime.parse(jsonObject["start_time"]).toLocal(),
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      updatedBy: User.fromJSON(jsonObject["updated_by"]),
    );
    if ((jsonObject["end_time"] ?? "").isEmpty) {
      task.running = true;
    }
    if ((jsonObject["start_time"] ?? "").isNotEmpty && (jsonObject["end_time"] ?? "").isNotEmpty) {
      task.complete = true;
    }
    return task;
  }
}
