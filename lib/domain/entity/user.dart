import 'package:oees/domain/entity/user_role.dart';

class User {
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final UserRole userRole;
  final String email;
  final String profilePic;
  final bool active;
  final String secretKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool selected = false;

  User({
    required this.active,
    required this.createdAt,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.profilePic,
    required this.secretKey,
    required this.updatedAt,
    required this.userRole,
    required this.username,
  });

  @override
  String toString() {
    return username;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "active": active,
      "created_at": createdAt,
      "email": email,
      "first_name": firstName,
      "last_name": lastName,
      "password": password,
      "profile_pic": profilePic,
      "secret_key": secretKey,
      "updated_at": updatedAt,
      "user_role": userRole.toJSON(),
      "username": username,
    };
  }

  factory User.fromJSON(Map<String, dynamic> jsonObject) {
    User user = User(
      active: jsonObject["active"],
      createdAt: DateTime.parse(jsonObject["created_at"]),
      email: jsonObject["email"],
      firstName: jsonObject["first_name"],
      lastName: jsonObject["last_name"],
      password: jsonObject["password"],
      profilePic: jsonObject["profile_pic"],
      secretKey: jsonObject["secret_key"],
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      userRole: UserRole.fromJSON(jsonObject["user_role"]),
      username: jsonObject["username"],
    );
    return user;
  }
}
