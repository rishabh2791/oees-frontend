import 'package:oees/application/app_store.dart';
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

  Device._({
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

  static Future<Device> fromJSON(Map<String, dynamic> jsonObject) async {
    late Device device;

    await appStore.userApp.getUser(jsonObject["created_by_username"]).then((createdByResponse) async {
      await appStore.userApp.getUser(jsonObject["updated_by_username"]).then((udpatedByResponse) async {
        await appStore.lineApp.getLine(jsonObject["line_id"]).then((lineResponse) async {
          device = Device._(
            code: jsonObject["code"],
            createdAt: DateTime.parse(jsonObject["created_at"]),
            createdBy: await User.fromJSON(createdByResponse["payload"]),
            description: jsonObject["description"],
            deviceType: jsonObject["device_type"],
            id: jsonObject["id"],
            line: await Line.fromJSON(lineResponse["payload"]),
            updatedAt: DateTime.parse(jsonObject["updated_at"]),
            updatedBy: await User.fromJSON(udpatedByResponse["payload"]),
            useForOEE: jsonObject["use_for_oee"],
          );
        });
      });
    });

    return device;
  }
}
