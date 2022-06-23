import 'package:oees/domain/entity/user.dart';

class Plant {
  final String code;
  final String description;
  final User createdBy;
  final DateTime createdAt;
  final User updatedBy;
  final DateTime updatedAt;
  bool selected = false;

  Plant({
    required this.code,
    required this.createdAt,
    required this.createdBy,
    required this.description,
    required this.updatedAt,
    required this.updatedBy,
  });

  @override
  String toString() {
    return code + " - " + description;
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "code": code,
      "description": description,
      "created_by": createdBy.toJSON(),
      "created_at": createdAt,
      "updated_by": updatedBy.toJSON(),
      "updated_at": updatedAt,
    };
  }

  factory Plant.fromJSON(Map<String, dynamic> jsonObject) {
    Plant plant = Plant(
      code: jsonObject["code"].toString(),
      createdAt: DateTime.parse(jsonObject["created_at"]),
      createdBy: User.fromJSON(jsonObject["created_by"]),
      description: jsonObject["description"],
      updatedAt: DateTime.parse(jsonObject["updated_at"]),
      updatedBy: User.fromJSON(jsonObject["updated_by"]),
    );
    return plant;
  }
}
