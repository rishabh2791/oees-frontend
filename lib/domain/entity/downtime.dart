import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/user.dart';

class Downtime {
  final String id;
  final Line line;
  final bool planned;
  final bool controlled;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final User updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Downtime(
      {required this.controlled,
      required this.createdAt,
      required this.description,
      required this.endTime,
      required this.id,
      required this.line,
      required this.planned,
      required this.startTime,
      required this.updatedAt,
      required this.updatedBy});

  @override
  String toString() {
    return line.name + " - " + startTime.toLocal().toString() + " - " + endTime.toLocal().toString();
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "controlled": controlled,
      "created_at": createdAt,
      "description": description,
      "end_time": endTime,
      "id": id,
      "planned": planned,
      "line": line.toJSON(),
      "start_time": startTime,
      "updated_at": updatedAt,
      "updated_by": updatedBy.toJSON(),
    };
  }

  factory Downtime.fromJSON(Map<String, dynamic> jsonObject) {
    Downtime downtime = Downtime(
      controlled: jsonObject["controlled"],
      createdAt: DateTime.parse(jsonObject["created_at"]),
      description: jsonObject["description"],
      endTime: DateTime.parse(jsonObject["end_time"] ?? "2099-12-31T23:59:59Z").toLocal(),
      id: jsonObject["id"],
      planned: jsonObject["planned"],
      line: Line.fromJSON(jsonObject["line"]),
      startTime: DateTime.parse(jsonObject["start_time"]).toLocal(),
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      updatedBy: User.fromJSON(jsonObject["updated_by"]),
    );
    return downtime;
  }
}
