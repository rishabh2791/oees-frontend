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

  UserRoleAccess({
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

  factory UserRoleAccess.fromJSON(Map<String, dynamic> jsonObject) {
    UserRoleAccess userRoleAccess = UserRoleAccess(
      accessCode: jsonObject["access_code"].toString(),
      createdAt: DateTime.parse(jsonObject["created_at"]),
      createdBy: User.fromJSON(jsonObject["created_by"]),
      id: jsonObject["id"],
      table: jsonObject["tablename"],
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      updatedBy: User.fromJSON(jsonObject["updated_by"]),
      userRole: UserRole.fromJSON(jsonObject["user_role"]),
    );
    return userRoleAccess;
  }
}
