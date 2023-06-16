import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/user.dart';
import 'package:oees/domain/entity/user_role.dart';

class UserRoleAccess {
  final String id;
  final UserRole userRole;
  final String table;
  final String accessCode;
  final User createdBy;
  final DateTime createdAt;
  final User updatedBy;
  final DateTime updatedAt;

  UserRoleAccess._({
    required this.accessCode,
    required this.createdAt,
    required this.createdBy,
    required this.id,
    required this.table,
    required this.updatedAt,
    required this.updatedBy,
    required this.userRole,
  });

  @override
  String toString() {
    return userRole.description + " - " + table + " - " + accessCode;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "access_code": accessCode,
      "created_at": createdAt,
      "created_by": createdBy.toJSON(),
      "id": id,
      "table": table,
      "updated_at": updatedAt,
      "updated_by": updatedBy.toJSON(),
      "user_role": userRole.toJSON(),
    };
  }

  static Future<UserRoleAccess> fromJSON(Map<String, dynamic> jsonObject) async {
    late UserRoleAccess userRoleAccess;

    await appStore.userApp.getUser(jsonObject["created_by_username"]).then((createdByResponse) async {
      await appStore.userApp.getUser(jsonObject["updated_by_username"]).then((udpatedByResponse) async {
        await appStore.userRoleApp.getUserRole(jsonObject["user_role_id"]).then((userRoleResponse) async {
          userRoleAccess = UserRoleAccess._(
            accessCode: jsonObject["access_code"],
            createdAt: DateTime.parse(jsonObject["created_at"]),
            createdBy: await User.fromJSON(createdByResponse["payload"]),
            id: jsonObject["id"],
            table: jsonObject["tablename"],
            updatedAt: DateTime.parse(jsonObject["updated_at"]),
            updatedBy: await User.fromJSON(udpatedByResponse["payload"]),
            userRole: await UserRole.fromJSON(userRoleResponse["payload"]),
          );
        });
      });
    });

    return userRoleAccess;
  }
}
