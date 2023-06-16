import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/user.dart';

class Line {
  final String id;
  final String code;
  String ipAddress;
  int speedType;
  final String name;
  final User createdBy;
  final DateTime createdAt;
  final User updatedBy;
  final DateTime updatedAt;
  bool selected = false;

  Line._({
    required this.code,
    required this.createdAt,
    required this.createdBy,
    required this.id,
    required this.speedType,
    required this.ipAddress,
    required this.name,
    required this.updatedAt,
    required this.updatedBy,
  });

  @override
  String toString() {
    return name;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "code": code,
      "created_at": createdAt,
      "created_by": createdBy.toJSON(),
      "id": id,
      "speed_type": speedType,
      "ip_address": ipAddress,
      "name": name,
      "updated_at": updatedAt,
      "updated_by": updatedBy.toJSON(),
    };
  }

  static Future<Line> fromJSON(Map<String, dynamic> jsonObject) async {
    late Line line;

    await appStore.userApp.getUser(jsonObject["created_by_username"]).then((createdByResponse) async {
      await appStore.userApp.getUser(jsonObject["updated_by_username"]).then((udpatedByResponse) async {
        line = Line._(
          code: jsonObject["code"],
          createdAt: DateTime.parse(jsonObject["created_at"]),
          createdBy: await User.fromJSON(createdByResponse["payload"]),
          id: jsonObject["id"],
          speedType: jsonObject["speed_type"],
          ipAddress: jsonObject["ip_address"],
          name: jsonObject["name"],
          updatedAt: DateTime.parse(jsonObject["updated_at"]),
          updatedBy: await User.fromJSON(udpatedByResponse["payload"]),
        );
      });
    });

    return line;
  }
}
