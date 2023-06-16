class UserRole {
  final String id;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool selected = false;

  UserRole._({
    required this.createdAt,
    required this.description,
    required this.id,
    required this.updatedAt,
  });

  @override
  String toString() {
    return description;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "id": id,
      "description": description,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }

  static Future<UserRole> fromJSON(Map<String, dynamic> jsonObject) async {
    UserRole userRole = UserRole._(
      createdAt: DateTime.parse(jsonObject["created_at"]),
      description: jsonObject["description"],
      id: jsonObject["id"],
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
    );

    return userRole;
  }
}
