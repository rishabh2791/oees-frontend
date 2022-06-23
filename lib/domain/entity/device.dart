import 'package:oees/domain/entity/line.dart';
import 'package:oees/domain/entity/user.dart';

class Device {
  final String id;
  final String deviceType;
  final Line line;
  final String code;
  final String description;
  final User createdBy;
  final DateTime createdAt;
  final User updatedBy;
  final DateTime updatedAt;
  final bool useForOEE;
  bool selected = false;

  Device({
    required this.code,
    required this.createdAt,
    required this.createdBy,
    required this.description,
    required this.deviceType,
    required this.id,
    required this.line,
    required this.updatedAt,
    required this.updatedBy,
    required this.useForOEE,
  });

  @override
  String toString() {
    return code + " - " + description;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "code": code,
      "created_at": createdAt,
      "created_by": createdBy.toJSON(),
      "description": description,
      "device_type": deviceType,
      "id": id,
      "line": line.toJSON(),
      "updated_at": updatedAt,
      "updated_by": updatedBy.toJSON(),
      "use_for_oee": useForOEE,
    };
  }

  factory Device.fromJSON(Map<String, dynamic> jsonObject) {
    Device device = Device(
      code: jsonObject["code"],
      createdAt: DateTime.parse(jsonObject["created_at"]),
      createdBy: User.fromJSON(jsonObject["created_by"]),
      description: jsonObject["description"],
      deviceType: jsonObject["device_type"],
      id: jsonObject["id"],
      line: Line.fromJSON(jsonObject["line"]),
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      updatedBy: User.fromJSON(jsonObject["updated_by"]),
      useForOEE: jsonObject["use_for_oee"],
    );
    return device;
  }
}
