import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/user.dart';

class Shift {
  final String id;
  final String code;
  final String description;
  final String startTime;
  final String endTime;
  final User createdBy;
  final DateTime createdAt;
  final User updatedBy;
  final DateTime updatedAt;
  bool selected = false;

  Shift._({
    required this.code,
    required this.createdAt,
    required this.createdBy,
    required this.description,
    required this.endTime,
    required this.id,
    required this.startTime,
    required this.updatedAt,
    required this.updatedBy,
  });

  @override
  String toString() {
    return description;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "code": code,
      "created_at": createdAt,
      "created_by": createdBy.toJSON(),
      "description": description,
      "end_time": endTime,
      "id": id,
      "start_time": startTime,
      "updated_at": updatedAt,
      "updated_by": updatedBy.toJSON(),
    };
  }

  static Future<Shift> fromJSON(Map<String, dynamic> jsonObject) async {
    late Shift shift;

    await appStore.userApp.getUser(jsonObject["created_by_username"]).then((createdByResponse) async {
      await appStore.userApp.getUser(jsonObject["updated_by_username"]).then((udpatedByResponse) async {
        shift = Shift._(
          code: jsonObject["code"],
          createdAt: DateTime.parse(jsonObject["created_at"]),
          createdBy: await User.fromJSON(createdByResponse["payload"]),
          description: jsonObject["description"],
          endTime: jsonObject["end_time"],
          id: jsonObject["id"],
          startTime: jsonObject["start_time"],
          updatedAt: DateTime.parse(jsonObject["updated_at"]),
          updatedBy: await User.fromJSON(udpatedByResponse["payload"]),
        );
      });
    });

    return shift;
  }
}
