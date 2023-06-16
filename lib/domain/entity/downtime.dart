import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/user.dart';

class Downtime {
  final String id;
  final Line line;
  bool planned;
  bool controlled;
  String description;
  String preset;
  DateTime startTime;
  DateTime endTime;
  final User updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Downtime._({
    this.controlled = false,
    required this.createdAt,
    this.description = "",
    this.preset = "",
    required this.endTime,
    required this.id,
    required this.line,
    this.planned = false,
    required this.startTime,
    required this.updatedAt,
    required this.updatedBy,
  });

  @override
  String toString() {
    return line.name + " - " + startTime.toLocal().toString() + " - " + endTime.toLocal().toString();
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "controlled": controlled,
      "created_at": createdAt,
      "description": description,
      "preset": preset,
      "end_time": endTime,
      "id": id,
      "planned": planned,
      "line": line.toJSON(),
      "start_time": startTime,
      "updated_at": updatedAt,
      "updated_by": updatedBy.toJSON(),
    };
  }

  static Future<Downtime> fromJSON(Map<String, dynamic> jsonObject) async {
    late Downtime downtime;

    await appStore.userApp.getUser(jsonObject["updated_by_username"]).then((udpatedByResponse) async {
      await appStore.lineApp.getLine(jsonObject["line_id"]).then((lineResponse) async {
        downtime = Downtime._(
          createdAt: DateTime.parse(jsonObject["created_at"]),
          endTime: jsonObject["end_time"].toString().toUpperCase() == "NULL"
              ? DateTime.parse("2099-12-31T23:59:59Z")
              : DateTime(
                  DateTime.parse(jsonObject["end_time"]).toLocal().year,
                  DateTime.parse(jsonObject["end_time"]).toLocal().month,
                  DateTime.parse(jsonObject["end_time"]).toLocal().day,
                  DateTime.parse(jsonObject["end_time"]).toLocal().hour,
                  DateTime.parse(jsonObject["end_time"]).toLocal().minute,
                  0,
                ),
          id: jsonObject["id"],
          line: await Line.fromJSON(lineResponse["payload"]),
          startTime: DateTime(
            DateTime.parse(jsonObject["start_time"]).toLocal().year,
            DateTime.parse(jsonObject["start_time"]).toLocal().month,
            DateTime.parse(jsonObject["start_time"]).toLocal().day,
            DateTime.parse(jsonObject["start_time"]).toLocal().hour,
            DateTime.parse(jsonObject["start_time"]).toLocal().minute,
            0,
          ),
          updatedAt: DateTime.parse(jsonObject["updated_at"]),
          updatedBy: await User.fromJSON(udpatedByResponse["payload"]),
          planned: jsonObject["planned"],
          controlled: jsonObject["controlled"],
          description: jsonObject["description"] ?? "",
          preset: jsonObject["preset"] ?? "",
        );
      });
    });

    return downtime;
  }
}
