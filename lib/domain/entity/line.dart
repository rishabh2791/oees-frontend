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

  Line({
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

  factory Line.fromJSON(Map<String, dynamic> jsonObject) {
    Line line = Line(
      code: jsonObject["code"],
      createdAt: DateTime.parse(jsonObject["created_at"]),
      createdBy: User.fromJSON(jsonObject["created_by"]),
      id: jsonObject["id"],
      speedType: int.parse(jsonObject["speed_type"].toString()),
      ipAddress: jsonObject["ip_address"] ?? "",
      name: jsonObject["name"],
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      updatedBy: User.fromJSON(jsonObject["updated_by"]),
    );
    return line;
  }
}
